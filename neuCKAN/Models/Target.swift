//
//	Target.swift
//	neuCKAN
//
//	Created by you on 20-01-13.
//	Copyleft © 2020 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import Foundation
import Cocoa
import os.log

//	TODO: Make Target initialisers throw errors.

/**
A KSP installation managable by neuCKAN.

A KSP installation is the enclosing directory of a `GameData/`. KSP installations with the same resolved path are treated as the same target.
*/
struct Target: Hashable {
	
	/**
	Initialise a KSP target from the given path.
	
	The initialiser returns `nil` if the path is invalid, or if no version informatino pertaining to the KSP installation is found.
	
	- Precondition: The path must be the KSP game files' enclosing directory.
	
	- Parameter path: The path to initiaise a target from.
	*/
	init?(path: FileURLConvertible) {
		//	MARK: KSP Path
		let kspURL = path.asFileURL()
		//	Clean out all possible "/./", "/../", and "//" in the path.
		let standardisedPath = kspURL.standardized
		//	Because there can only possibly be 1 KSP installation at each physical location, all symbolic links need to be resolved to reveal the actual location. This also helps with getting inode value later, which is used for identifying each KSP installation.
		let resolvedPath = standardisedPath.resolvingSymlinksInPath()
		do {
			let kspDirectoryAttributes = try FileManager.default.attributesOfItem(atPath: resolvedPath.path)
			guard kspDirectoryAttributes[.type] as! FileAttributeType == .typeDirectory else {
				os_log("Unable to create KSP target: %@ is not a directory.", type: .error, resolvedPath.path)
				return nil
			}
			//	Since kspDirectoryAttributes is initialised with no errors, this type casting is safe.
			self.inode = kspDirectoryAttributes[.systemFileNumber] as! Int
			//	Record the standardised path with all possible symbolics unresolved, for the user's convenience.
			self.path = standardisedPath
		} catch let cocoaError as CocoaError {
			os_log("Unable to create KSP target for %@ due to a cocoa error: %@.", type: .error, kspURL.path, cocoaError.localizedDescription)
			NSApplication.shared.presentError(cocoaError)
			return nil
		} catch let nsError as NSError {
			os_log("Unable to create KSP target for %@ due to an error in domain %@: %@.", type: .error, kspURL.path, nsError.domain, nsError.localizedDescription)
			NSApplication.shared.presentError(nsError)
			return nil
		} catch let error {
			os_log("Unable to create KSP target for %@ due to an error: %@.", type: .error, kspURL.path, error.localizedDescription)
			NSApplication.shared.presentError(error)
			return nil
		}
		
		//	MARK: KSP Version
		var kspVersion: Substring
		let readmeFilePath = resolvedPath.appendingPathComponent("readme.txt")
		do {
			//	Somehow the .utf8 option doesn't work.
			let readmeFileContent = try String(contentsOf: readmeFilePath, encoding: .ascii)
			//	Use case-insensitive, because the APFS is case-insensitive by default, and it makes regex matching easier.
			let kspVersionRegex = try NSRegularExpression(pattern: "version\\W*\\s*(\\d+(\\.\\d+)*)", options: .caseInsensitive)
			guard let kspVersionRegexMatch = kspVersionRegex.firstMatch(in: readmeFileContent, range: NSRange(readmeFileContent.startIndex..., in: readmeFileContent)) else {
				os_log("Unable to determine KSP version: No match found in %@ encoded in ASCII.", type: .error, readmeFilePath.path)
				return nil
			}
			kspVersion = readmeFileContent[Range(kspVersionRegexMatch.range(at: 1), in: readmeFileContent)!]
			//	Enforce semantic versioning.
			if kspVersion.split(separator: ".").count == 2 {
				kspVersion += ".0"
			}
		} catch let cocoaError as CocoaError {
			os_log("Unable to determine KSP version for %@ due to a cocoa error: %@.", type: .error, readmeFilePath.path, cocoaError.localizedDescription)
			NSApplication.shared.presentError(cocoaError)
			return nil
		} catch let nsError as NSError {
			os_log("Unable to determine KSP version for %@ due to an error in domain %@: %@.", type: .error, readmeFilePath.path, nsError.domain, nsError.localizedDescription)
			NSApplication.shared.presentError(nsError)
			return nil
		} catch let error {
			os_log("Unable to determine KSP version for %@ due to an error: %@.", type: .error, readmeFilePath.path, error.localizedDescription)
			NSApplication.shared.presentError(error)
			return nil
		}
		
		//	MARK: KSP Build ID
		var kspBuildID: Substring = ""
		let buildIDFilePath = resolvedPath.appendingPathComponent("buildID.txt")
		do {
			//	Somehow the .utf8 option doesn't work.
			let buildIDFileContent = try String(contentsOf: buildIDFilePath, encoding: .ascii)
			//	Use case-insensitive, because the APFS is case-insensitive by default, and it makes regex matching easier.
			let kspbuildIDRegex = try NSRegularExpression(pattern: "build\\W*id\\s*\\W*\\s*(\\d+)", options: .caseInsensitive)
			if let kspbuildIDRegexMatch = kspbuildIDRegex.firstMatch(in: buildIDFileContent, range: NSRange(buildIDFileContent.startIndex..., in: buildIDFileContent)) {
				kspBuildID = buildIDFileContent[Range(kspbuildIDRegexMatch.range(at: 1), in: buildIDFileContent)!] + ":"
			} else {
				os_log("Unable to determine KSP build ID: No match found in %@ encoded in ASCII.", type: .info, buildIDFilePath.path)
			}
		} catch let cocoaError as CocoaError {
			os_log("Unable to determine KSP build ID for %@ due to an acceptable cocoa error: %@.", type: .info, buildIDFilePath.path, cocoaError.localizedDescription)
		} catch let nsError as NSError {
			os_log("Unable to determine KSP build ID for %@ due to an acceptable error in domain %@: %@.", type: .info, buildIDFilePath.path, nsError.domain, nsError.localizedDescription)
		} catch let error {
			os_log("Unable to determine KSP build ID for %@ due to an error: %@.", type: .info, buildIDFilePath.path, error.localizedDescription)
		}
		
		//	KSP's build ID acts as its verion's epoch. Not all KSP versions ship with the build ID information. If no build ID is found prior to this step, kspBuildID is an empty substring. If build ID is found, kspBuildID is appended with ":".
		self.version = CKANMetadataVersion("\(kspBuildID)\(kspVersion)")
	}
	
	var filterDidChange: Bool = false
	//	TODO: Add stored array of mods.
	//	Stored because of faster runtime.
	//	TODO: Add stored filter with didset observer.
	//	The mods array changes when filter changes.
	//	TODO: Make mods private.
	var mods: Mods { Synecdoche.shared.mods }
	
	/**
	The target's version.
	
	The version can contain the target's build ID as its epoch.
	*/
	let version: CKANMetadataVersion
	
	/**
	The KSP logo correspoding to the target's version.
	
	If a logo does not exist for the target's version, a more general logo will be used. The most general logo matches to the target's major version. `logo` is `nil` if not even the most general logo exists.
	*/
	var logo: NSImage? {
		NSImage(named: "KSP \(version.description) Logo") ?? NSImage(named: "KSP \(version[..<2]) Logo") ?? NSImage(named: "KSP \(version[..<1]) Logo") ?? NSImage(named: "KSP Logo")
	}
	
	/**
	The absolute path to the target.
	
	- See Also: `gameDataPath`.
	*/
	let path: URL
	
	/**
	The absolute path to the target's `GameData/` directory.
	
	The `GameData/` directory serves as the root for all mod file managements.
	
	- See Also: `path`.
	*/
	var gameDataPath: URL { path.appendingPathComponent("GameData") }
	
	/**
	The target's root directory's inode value.
	
	The inode value is the KSP target's unique indentification. It survives aliases on macOS, and is attained after all symbolic links are resolved during the target's initialisation.
	
	- See Also: `id`.
	*/
	let inode: Int
}

//	MARK: - Identifiable Conformance
extension Target: Identifiable {
	/**
	The target's alternative, `Identifiable`-conforming unique identification.
	
	This is identical to `inode`.
	
	- See Also: `inode`.
	*/
	var id: Int { inode }
}

//	MARK: - TargetConvertible Conformance
extension Target: TargetConvertible {
	/**
	Returns `self`.
	
	- Returns: `self`.
	*/
	func asTarget() -> Target? { self }
}

//	MARK: -
//	TODO: Nest Error in Target.
//enum TargetError: Error {
//	case pathInvalid
//	case inodeClash
//}
