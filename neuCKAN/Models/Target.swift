//
//  Target.swift
//  neuCKAN
//
//  Created by you on 20-01-13.
//  Copyleft © 2020 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import Foundation
import Cocoa
import os.log

struct Target: Hashable {
	
	init?(path: URL) {
		//	MARK: KSP Path
		///
		let standardisedPath = path.standardizedFileURL
		///
		let resolvedPath = standardisedPath.resolvingSymlinksInPath()
		//
		guard FileManager.default.fileExists(atPath: resolvedPath.absoluteString) else {
			os_log("Unable to create KSP target: %@ does not exist.", log: .default, type: .debug, path.absoluteString)
			return nil
		}
		//
		guard let kspDirectoryAttributes = try? FileManager.default.attributesOfItem(atPath: resolvedPath.absoluteString) else {
			os_log("Unable to retrieve file attributes of %@, which is after standardising and resolving symlinks in %@.", log: .default, type: .error, resolvedPath.absoluteString, path.absoluteString)
			return nil
		}
		//
		guard kspDirectoryAttributes[.type] as! FileAttributeType == .typeDirectory else {
			os_log("%@ is not a directory.", log: .default, type: .error, resolvedPath.absoluteString)
			return nil
		}
		
		//	MARK: KSP Version
		///
		let readmeFilePath = resolvedPath.appendingPathComponent("readme.txt")
		//
		guard FileManager.default.fileExists(atPath: readmeFilePath.absoluteString) else {
			os_log("Unable to determine KSP version: %@ does not exist.", log: .default, type: .error, readmeFilePath.absoluteString)
			return nil
		}
		//
		guard FileManager.default.isReadableFile(atPath: readmeFilePath.absoluteString) else {
			os_log("Unable to determine KSP version: %@ is not readable.", log: .default, type: .error, readmeFilePath.absoluteString)
			return nil
		}
		///
		var readmeFileEncoding: String.Encoding
		//
		guard let readmeFileContent = try? String(contentsOf: readmeFilePath, usedEncoding: &readmeFileEncoding) else {
			os_log("Unable to determine KSP version: Failed to read %@ using encoding %@.", log: .default, type: .error, readmeFilePath.absoluteString, readmeFileEncoding.description)
			return nil
		}
		//
		///
		let kspVersionRegex = try! NSRegularExpression(pattern: "version\\W*\\s*(\\d+(\\.\\d+)*)", options: .caseInsensitive)
		//
		guard let kspVersionRegexMatch = kspVersionRegex.firstMatch(in: readmeFileContent, range: NSRange(readmeFileContent.startIndex..., in: readmeFileContent)) else {
			os_log("Unable to determine KSP version: No match found in %@ encoded in %@.", log: .default, type: .error, readmeFilePath.absoluteString, readmeFileEncoding.description)
			return nil
		}
		//
		///
		let kspVersion = readmeFileContent[Range(kspVersionRegexMatch.range(at: 1), in: readmeFileContent)!]
		
		//	MARK: KSP Build ID
		///
		var kspBuildID: Substring
		///
		let buildIDFilePath = resolvedPath.appendingPathComponent("buildID.txt")
		//
		if FileManager.default.fileExists(atPath: buildIDFilePath.absoluteString) {
			guard FileManager.default.isReadableFile(atPath: buildIDFilePath.absoluteString) else {
				os_log("Unable to determine KSP build ID: %@ is not readable.", log: .default, type: .error, buildIDFilePath.absoluteString)
				return nil
			}
			///
			var buildIDFileEncoding: String.Encoding
			//
			guard let buildIDFileContent = try? String(contentsOf: buildIDFilePath, usedEncoding: &buildIDFileEncoding) else {
				os_log("Unable to determine KSP build ID: Failed to read %@ using encoding %@.", log: .default, type: .error, buildIDFilePath.absoluteString, buildIDFileEncoding.description)
				return nil
			}
			//
			///
			let kspVersionRegex = try! NSRegularExpression(pattern: "version\\W*\\s*(\\d+(\\.\\d+)*)", options: .caseInsensitive)
			//
			guard let kspbuildIDRegexMatch = kspVersionRegex.firstMatch(in: buildIDFileContent, range: NSRange(buildIDFileContent.startIndex..., in: buildIDFileContent)) else {
				os_log("Unable to determine KSP build ID: No match found in %@ encoded in %@.", log: .default, type: .error, buildIDFilePath.absoluteString, buildIDFileEncoding.description)
				return nil
			}
			//
			kspBuildID = buildIDFileContent[Range(kspbuildIDRegexMatch.range(at: 1), in: buildIDFileContent)!]
		} else {
			kspBuildID = ""
		}
		
		//	MARK: -
		self.path = standardisedPath
		self.inode = kspDirectoryAttributes[.systemFileNumber] as! Int
		self.version = Version("\(kspBuildID.isEmpty ? "" : "\(kspBuildID):")\(kspVersion)")
		self.badge = NSImage(named: "KSP \(version[..<2]) Patch") ?? NSImage(named: "KSP Logo Red")!
	}
	
	var filterDidChange: Bool = false
	//	TODO: Add stored array of mods.
	//	Stored because of faster runtime.
	//	TODO: Add stored filter with didset observer.
	//	The mods array changes when filter changes.
	//	TODO: Make mods private.
	var mods: [Mod] { Array(Synecdoche.mods) }
	let version: Version
	let badge: NSImage
	let path: URL
	var gameDataPath: URL { path.appendingPathComponent("GameData") }
	let inode: Int
}

extension Target {
	init?(path: String) {
		self.init(path: URL(fileURLWithPath: path))
	}
}

//	MARK: - Comparable Conformance
extension Target: Comparable {
	static func < (lhs: Target, rhs: Target) -> Bool {
		(lhs.version < rhs.version || lhs.inode < rhs.inode) && !(lhs.version > rhs.version)
	}
}

//	MARK: - Identifiable Conformance
extension Target: Identifiable {
	var id: Int { inode }
}
