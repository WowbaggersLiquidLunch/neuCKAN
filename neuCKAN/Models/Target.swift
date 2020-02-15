//
//  Target.swift
//  neuCKAN
//
//  Created by you on 20-01-13.
//  Copyleft © 2020 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import Foundation
import Cocoa

struct Target: Hashable {
	
	init(version: Version, path: URL) {
		self.version = version
		self.path = path
		self.badge = NSImage(named: "KSP \(version[..<2]) Patch") ?? NSImage(named: "KSP Logo Red")!
	}
	
	var filterDidChange: Bool = false
	//	TODO: Add stored array of mods.
	//	Stored because of faster runtime.
	//	TODO: Add stored filter with didset observer.
	//	The mods array changes when filter changes.
	var mods: [Mod] { Array(Synecdoche.mods) }
	let version: Version
	let badge: NSImage
	let path: URL
	var gameDataPath: URL {
		path.appendingPathComponent("GameData")
	}
}

extension Target {
	
	init(version: String, path: URL) {
		self.init(version: Version(version), path: path)
	}
	
	init(version: Double, path: URL) {
		self.init(version: Version(version), path: path)
	}
	
	init(version: String, path: String) {
		self.init(version: Version(version), path: URL(fileURLWithPath: path))
	}
	
	init(version: Double, path: String) {
		self.init(version: Version(version), path: URL(fileURLWithPath: path))
	}
	
	init(version: Version, path: String) {
		self.init(version: version, path: URL(fileURLWithPath: path))
	}
}

//	MARK: - Comparable Comformance
extension Target: Comparable {
	static func < (lhs: Target, rhs: Target) -> Bool {
		(lhs.version < rhs.version || lhs.path.absoluteString < rhs.path.absoluteString) && !(lhs.version > rhs.version)
	}
}
