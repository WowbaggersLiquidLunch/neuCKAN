//
//  GroundControl.swift
//  neuCKAN
//
//  Created by you on 20-02-06.
//  Copyleft © 2020 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import Foundation
import Combine
import Alamofire
import ZIPFoundation
import os.log

///	Acronym for Ground Control.
typealias GC = GroundControl

/**
The main controller for neuCKAN's non-view-specific data activities.

An instance of `GroundControl` serves to abstract out many common data-processing workloads that alters the application's state, such as adding new KSP installations and reloading CKAN metadata. Some file system-facing data activities are offloaded to `AirTrafficController`.

- Remark: The name is inspired by Apple's Grand Central Dispatch and David Bowie's _Space Oddity_. It's also quite apt, given neuCKAN being a KSP mod manager.

- TODO: Offload file system-facing data activities to `AirTrafficController`.
*/
class GroundControl {
	///	Initialises a `GroundControl` instance.
	private init() {}
	///	The shared, and only, `GroundControl` instance of this neuCKAN instance.
	static let shared = GC()
	
	/**
	Refreshes all data managable by `GroundControl`
	*/
	func refreshData() {
		reloadTargets()
		updateModsCache()
	}
	
	//	MARK: - Targets Management
	
	/**
	Adds the given KSP installations for neuCKAN to manage.
	
	When multiple new targets share the same inode, the first in order among them takes precedence.
	
	- Parameter targets: The new targets for neuCKAN to manage.
	*/
	func addTargets<T: Sequence>(_ targets: T) where T.Element == TargetConvertible? {
		var targetsCanUpdateWithoutConflicts: Bool = false
		ATC.shared.dataStateQueue.sync {
			guard !ATC.shared.targetsAdditionIsInProgress else { return }
			ATC.shared.targetsAdditionIsInProgress = true
			targetsCanUpdateWithoutConflicts = true
		}
		guard targetsCanUpdateWithoutConflicts else {return}
		defer { ATC.shared.dataStateQueue.async { ATC.shared.targetsAdditionIsInProgress = false } }
		ATC.shared.targetsUpdateQueue.sync { Synecdoche.shared.targets.insert(contentsOf: targets) }
	}
	
	/**
	Adds new KSP installations by their given file URLs for neuCKAN to manage.
	
	When multiple new targets share the same inode, the first in order among them takes precedence.
	
	- Parameter targets: The file URLs of the new targets for neuCKAN to manage.
	*/
	func addTargets<T: Sequence>(at targetURLs: T) where T.Element: FileURLConvertible {
		addTargets(targetURLs.map { $0.asTarget() } )
	}
	
	/**
	Reloads all targets.
	
	- TODO: Complete this method.
	*/
	func reloadTargets() {
		
		//	FIXME: Separate data state checking from data updating, to avoid accumulating backlog for updating.
		
		//	Check if the targets data is already being reloaded.
		//	Return without any further progress if it is.
		//	Set it to true and start checking for update if it is not.
		ATC.shared.dataStateQueue.async {
			guard !ATC.shared.targetsDataUpdateIsInProgress else { return }
			ATC.shared.targetsReloadIsInProgress = true
			//	FIXME: Fix paths being sandboxed.
			//		let applicationSupportPath = try! FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
			//		let steamKSPPath = applicationSupportPath.appendingPathComponent("Steam/steamapps/common/Kerbal Space Program")
//			let steamKSPPath = URL(fileURLWithPath: "~/Library/Application Support/Steam/steamapps/common/Kerbal Space Program")
//			Synecdoche.shared.targets = Targets(targets: [
//				Target(path: NSString(string: "~/Downloads/KSP_osx").expandingTildeInPath)!,
//				Target(path: "/Users/jizhuojie/Library/Application Support/Steam/steamapps/common/Kerbal Space Program")!
//			], groupingLevel: .root)
			
			ATC.shared.targetsReloadIsInProgress = false
		}
	}
	
	/**
	Records targets currently selected in targets view.
	
	- Parameter targets: The targets selected in targets view.
	*/
	func recordSelection<T: Sequence>(of targets: T) where T.Element == TargetConvertible? {
		Synecdoche.shared.selectedTargets = Targets(targets: targets)
	}
	
	//	MARK: - Mods Cache Management
	
	/**
	Check for update of CKAN metadata on its remote repository, and update the local database if need be.
	
	- Parameter webURL: CKAN metadata's remote repository location.
	
	- TODO: Use GitHub APIs to update changes only, instead of doing a full reload every time.
	*/
	func updateModsCache(from metadataRepository: URL = ckanMetadataArchiveURL) {
		
		//	Because a guard statement in a dispatch queue can not return from its contexts (it can only return from the queue), a 2nd indicator is needed to tell if metadata can update without confilcts.
		var metadataCanUpdateWithoutConflicts: Bool = false
		//	Check if the metadata database is already being updated.
		//	Return without any further progress if it is.
		//	Set it to true and start checking for update if it is not.
		ATC.shared.dataStateQueue.sync {
			guard !ATC.shared.metadataUpdateIsInProgress else { return }
			ATC.shared.metadataUpdateIsInProgress = true
			metadataCanUpdateWithoutConflicts = true
		}
		//	This is the check on aforementioned 2nd indicator.
		guard metadataCanUpdateWithoutConflicts else {return}
		//
		defer {
			//	Release lock when exiting the function.
			ATC.shared.dataStateQueue.async { ATC.shared.metadataUpdateIsInProgress = false }
		}
		//	TODO: Check for update here before updating/reloading everything.
		//	TODO: Check local data integrity.
		
		//	Check for new metadata on the remote database, then update the local database if necessary.
		ATC.shared.concurrentNetworkIOQueue.async {
			
			//	FIXME: Check internet connection first.
			AF.request(metadataRepository).validate().responseData(queue: ATC.shared.concurrentNetworkResponseQueue) { response in
				guard let responseData = response.data else {
					os_log("Failed to receive data from CKAN metadata repository.", type: .info)
					return
				}
				guard let ckanMetadataArchive = Archive(data: responseData, accessMode: .read) else { return }
				
				var temporaryMods: Mods = Synecdoche.shared.mods
				
				//	Currently, there are 2 schemes for parsing the metadata files: one-by-one sequentially, and all-at-once concurrently. The sequential scheme is the default, until the concurrent scheme becomes stable. The user will retain both of these options, until the sequential scheme is rendered completely obsolete.
				switch Preferences.metadataParsingScheme {
				case .sequential:
					ckanMetadataArchive.forEach { parseCKANMetadata(in: $0) }
				case .concurrent:
					//	TODO: Add progress bar.
					//	FIXME: Foundation.Data.CompressionError in ZIPFoundation domain.
					//	FIXME: Unstable behaviour: About ⅓ - ⅕ of all metadata fail to be parsed each time; results vary by run.
					ckanMetadataArchive.forEach { entry in
						ATC.shared.concurrentCKANMetadataParsingQueue.async(group: ATC.shared.metadataParsingGroup) {
							parseCKANMetadata(in: entry)
						}
					}
				}
				
				//	FIXME: Redundant data: Fix logic to render temporaryMods and data-copy unnecessary.
				//	Copy the temporary mods array to the struct's mods property. The whole temporaryMods shenanigans were to ensure the atomicity of the actual data update here. This is a temporary solution.
				ATC.shared.metadataParsingGroup.notify(queue: ATC.shared.modsUpdateQueue) { Synecdoche.shared.mods = temporaryMods }
				
				func parseCKANMetadata(in entry: Entry) {
					//	Ignore directories, symlinks, and top-level files.
					guard let standardisedEntryPath = URL(string: entry.path)?.standardized else {
						os_log("Unable to form an URL from entry path %@.", log: .default, type: .error, entry.path)
						return
					}
					guard entry.type == .file && standardisedEntryPath.deletingLastPathComponent().lastPathComponent != "CKAN-meta-master" else { return }
					do {
						_ = try ckanMetadataArchive.extract(entry, skipCRC32: true, progress: nil) { data in
							let release = try JSONDecoder().decode(Release.self, from: data)
							ATC.shared.modsAssemblyQueue.sync { temporaryMods.insert(release) }
						}
					} catch Archive.ArchiveError.unreadableArchive {
						os_log("Unable to extract %@: Archive file damaged or otherwise inaccessible.", type: .error, entry.path)
					} catch Archive.ArchiveError.invalidEntryPath {
						os_log("Unable to extract %@: Entry path invalid.", type: .error, entry.path)
					} catch Archive.ArchiveError.invalidCompressionMethod {
						os_log("Unable to extract %@: Compression method invalid.", type: .error, entry.path)
					} catch Archive.ArchiveError.cancelledOperation {
						os_log("Unable to extract %@: Extraction cancelled.", type: .error, entry.path)
					} catch DecodingError.dataCorrupted(let context) {
						os_log("Unable to decode %@: JSON data corrupted or otherwise invalid.\n\tThe decode call failed at %@.\n\tDetails: %@\n\tUnderlying error: %@.", type: .error, entry.path, context.codingPath.debugDescription, context.debugDescription, context.underlyingError?.localizedDescription ?? "Unspecified")
					} catch DecodingError.keyNotFound(let key, let context){
						os_log("Unable to decode for key %@ in %@: Key not found.\n\tThe decode call failed at %@.\n\tDetails: %@\n\tUnderlying error: %@.", type: .error, key.debugDescription, entry.path, context.codingPath.debugDescription, context.debugDescription, context.underlyingError?.localizedDescription ?? "Unspecified")
					} catch DecodingError.typeMismatch(let type, let context){
						os_log("Unable to decode for type %@ in %@: Type mismatch.\n\tThe decode call failed at %@.\n\tDetails: %@\n\tUnderlying error: %@.", type: .error, String(describing: type), entry.path, context.codingPath.debugDescription, context.debugDescription, context.underlyingError?.localizedDescription ?? "Unspecified")
					} catch DecodingError.valueNotFound(let type, let context){
						os_log("Unable to decode non-optional value of type %@ in %@: Value not found.\n\tThe decode call failed at %@.\n\tDetails: %@\n\tUnderlying error: %@.", type: .error, String(describing: type), entry.path, context.codingPath.debugDescription, context.debugDescription, context.underlyingError?.localizedDescription ?? "Unspecified")
					} catch let nsError as NSError {
						os_log("Unable to decude %@ due to error in domain %@: %@", type: .error, entry.path, nsError.domain, nsError.localizedDescription)
					} catch let error {
						os_log("Unable to decode %@ due to an error: %@.", type: .error, entry.path, error.localizedDescription)
					}
				}
			}
		}
	}
	
	//	MARK: - File Management
	
	/**
	Installs the given mod releases for the given targets.
	
	- Parameters:
		- releases: The mod releases to be installed.
		- targets: The targets to install for.
	*/
	func install<T: Sequence, U: Sequence>(_ releases: T, for targets: U) where T.Element == Release, U.Element: TargetConvertible {
		//	Check if the targets provided are valid. There is no point in doing anything if the targets are invalid.
		let targets = targets.compactMap { $0.asTarget() }
		guard !targets.isEmpty else {
			os_log("Invalid target(s):\n\t%@.", type: .error, String(describing: targets))
			return
		}
		//	TODO: Add locking mechanism.
		//	TODO: Block duplicate instructions.
		//	TODO: Resolve dependencies and conflicts.
		//	TODO: Uninstall before install.
		ATC.shared.concurrentNetworkIOQueue.async {
			releases.forEach { release in
				AF.request(release.downloadLink).validate().responseData(queue: ATC.shared.concurrentNetworkResponseQueue) { response in
					guard let responseData = response.data else {
						os_log("Failed to receive data from %@.", type: .info, release.downloadLink.absoluteString)
						return
					}
					
					guard let releaseArchive = Archive(data: responseData, accessMode: .read) else { return }
					
					//	TODO: Check installation directives don't traverse upwards out of KSP's scope.
					if let installationDirectives = release.installationDirectives {
						installationDirectives.forEach { installationDirective in
							switch installationDirective.source {
							case .absolutePath(let path):
								guard let rootEntry = releaseArchive[path] else {
									os_log("Invalid source path for %@ %@:\n\t%@.", type: .info, release.name, String(describing: release.version), path)
									return
								}
								unzip(releaseArchive, forEntriesUnder: rootEntry, using: installationDirective)
							case .topMostMatch(let name):
								guard let rootEntry = releaseArchive.first(where: { URL(fileURLWithPath: $0.path).lastPathComponent == name } ) else {
									os_log("Invalid source name for %@ %@:\n\t%@.", type: .info, release.name, String(describing: release.version), name)
									return
								}
								unzip(releaseArchive, forEntriesUnder: rootEntry, using: installationDirective)
							case .topMostMatchByRegex(let regexString):
								guard let rootEntry = releaseArchive.first(where: { entry in
									guard let topMostRegexMatch = installationDirective.source.regex?.firstMatch(in: entry.path, range: NSRange(entry.path.startIndex..., in: entry.path)) else {
										return false
									}
									let fullMatch = entry.path[Range(topMostRegexMatch.range(at: 0), in: entry.path)!]
									return entry.path == fullMatch
								}) else {
									os_log("Invalid source regex for %@ %@:\n\t%@.", type: .info, release.name, String(describing: release.version), regexString)
									return
								}
								unzip(releaseArchive, forEntriesUnder: rootEntry, using: installationDirective)
							}
						}
					} else {
						guard let rootEntry = releaseArchive.first(where: { URL(string: $0.path)?.lastPathComponent == release.modID } ) else {
							os_log("Invalid directory structure for %@ %@:\n\tNo GameData/ in lieu of installation directives.", type: .info, release.name, String(describing: release.version))
							return
						}
						unzip(releaseArchive, forEntriesUnder: rootEntry)
					}
				}
				
				//	TODO: Optimise.
				func unzip(_ archive: Archive, forEntriesUnder rootEntry: Entry, using directive: InstallationDirective? = nil) {
					guard let baseEntryPath = directive?.alias != nil ? rootEntry.path : URL(string: rootEntry.path)?.deletingLastPathComponent().path else {
						os_log("Unable to form an URL from entry path %@.", type: .error, rootEntry.path)
						return
					}
					archive.filter {
						//	TODO: Handle inclusions and exlustions in a installation directive.
						$0.path.hasPrefix(rootEntry.path)
					} .forEach { entry in
						var relativeEntryPath = entry.path.suffix(from: baseEntryPath.endIndex)
						if let alias = directive?.alias {
							relativeEntryPath = alias + relativeEntryPath
						} else if relativeEntryPath.hasPrefix("/") {
							relativeEntryPath = relativeEntryPath.dropFirst()
						}
						targets.forEach { target in
							do {
								_ = try archive.extract(entry, to: target.path.appendingPathComponent(directive?.destination ?? "GameData").appendingPathComponent(String(relativeEntryPath)).standardized.resolvingSymlinksInPath(), skipCRC32: true, progress: nil)
							} catch Archive.ArchiveError.unreadableArchive {
								os_log("Unable to extract %@ for %@ %@: Archive file damaged or otherwise inaccessible.", type: .error, entry.path, release.name, String(describing: release.version))
							} catch Archive.ArchiveError.invalidEntryPath {
								os_log("Unable to extract %@ for %@ %@: Entry path invalid.", type: .error, entry.path, release.name, String(describing: release.version))
							} catch Archive.ArchiveError.invalidCompressionMethod {
								os_log("Unable to extract %@ for %@ %@: Compression method invalid.", type: .error, entry.path, release.name, String(describing: release.version))
							} catch Archive.ArchiveError.cancelledOperation {
								os_log("Unable to extract %@ for %@ %@: Extraction cancelled.", type: .error, entry.path, release.name, String(describing: release.version))
							} catch let cocoaError as CocoaError {
								os_log("Unable to extract %@ for %@ %@ due to a cocoa error: %@.", type: .debug, entry.path, release.name, String(describing: release.version), cocoaError.localizedDescription)
							} catch let nsError as NSError {
								os_log("Unable to extract %@ for %@ %@ due to an error in domain %@: %@.", type: .debug, entry.path, release.name, String(describing: release.version), nsError.domain, nsError.localizedDescription)
							} catch let error {
								os_log("Unable to extract %@ for %@ %@ due to an error: %@.", type: .debug, entry.path, release.name, String(describing: release.version), error.localizedDescription)
							}
						}
					}
				}
			}
		}
	}
	
	/**
	Installs the given mod releases for selected targets.
	
	This initialiser exists because of [a problem with generic default parameters][generic default parameters problem].
	
	- Parameter releases: The mod releases to be installed.
	
	[generic default parameters problem]: https://stackoverflow.com/questions/38326992/default-parameter-as-generic-type
	*/
	func install<T: Sequence>(_ releases: T) where T.Element == Release {
		install(releases, for: Synecdoche.shared.selectedTargets)
	}
	
	/**
	Installs the given mod release for the given targets.
	
	- Parameters:
		- release: The mod release to be installed.
		- targets: The targets to install for.
	*/
	func install<T: Sequence>(_ release: Release, for targets: T) where T.Element: TargetConvertible {
		install([release], for: targets)
	}
	
	/**
	Installs the given mod release for selected targets.
	
	This initialiser exists because of [a problem with generic default parameters][generic default parameters problem].
	
	- Parameter release: The mod release to be installed.
	
	[generic default parameters problem]: https://stackoverflow.com/questions/38326992/default-parameter-as-generic-type
	*/
	func install(_ release: Release) {
		install(release, for: Synecdoche.shared.selectedTargets)
	}
	
	//	MARK: -
}
