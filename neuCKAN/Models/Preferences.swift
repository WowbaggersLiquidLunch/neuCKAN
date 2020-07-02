//
//	Preferences.swift
//	neuCKAN
//
//	Created by you on 20-01-18.
//	Copyleft © 2020 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import Foundation

/**
Temporary location for storing some preferences.
*/
struct Preferences {
	static var databaseShouldReloadOnAppLaunching: Bool = true
	static var updateMetadataOnLaunch: Bool = true
	static var metadataParsingScheme: MetadataParsingScheme = .sequential
	enum MetadataParsingScheme {
		case sequential
		case concurrent
	}
}
