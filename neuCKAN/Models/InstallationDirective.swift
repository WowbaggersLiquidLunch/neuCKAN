//
//	InstallationDirective.swift
//	neuCKAN
//
//	Created by you on 19-11-05.
//	Copyleft © 2019 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import Foundation

/**
A list of installation directives for the mod.

This is equivalent to the ["install" attribute][0] in a .ckan file.

If no installation directives are provided, neuCKAN must find the top-most directory in the archive that matches the module identifier, which it shall install with `GameData/` as the target.

A typical set of installation directives only has `"file"` and `"install_to"` attributes in a .ckan file:

```
"install" : [
	{
		"file"       : "GameData/ExampleMod",
		"install_to" : "GameData"
	}
]
```

[0]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#install
*/
struct InstallationDirective: Hashable {
	
	//	MARK: Source Directive
	
	/**
	The source location from which the matched file(s) or directory(s) should be installed.
	*/
	let source: SourceDirective
	
	/**
	A representation of source directives as defined by the CKAN metadata specification.
	*/
	enum SourceDirective: Hashable {
		
		/**
		The file or directory root that this directive pertains to.
		
		This is equivalent to the `"file"` attribute in a .ckan file.
		
		All leading directories are stripped from the start of the filename during install. For example, `MyMods/KSP/Foo` will be installed into `GameData/Foo`.
		*/
		case absolutePath(String)
		
		/**
		The top-most directory that matches exactly the name specified. (since CKAN v1.4)
		
		This is equivalent to the `"find"` attribute in a .ckan file.
		
		This is particularly useful when distributions have structures that change by releases.
		*/
		case topMostMatch(String)
		
		/**
		The top-most directory that matches the specified regular expression string. (since CKAN v1.10)
		
		This is equivalent to the `"find_regexp"` attribute in a .ckan file.
		
		This is particularly useful when distributions have structures that change by releases, but `topMostMatch` is insufficient because multiple directories or files contain the same name. Directories' separators will have been normalised to forward-slashes first, and the trailing slash for each directory removed before the regular expression is run.
		
		- Warning: Use sparingly and with caution, regular expressions are prone to hard-to-spot mistakes.
		*/
		case topMostMatchByRegex(String)
		
		/**
		The `NSRegularExpression` instance representing a source directory.
		
		This is computed from `source`.
		*/
		var sourceDirectiveRegex: NSRegularExpression? {
			switch self {
			case .topMostMatchByRegex(let regexString):
				return try? NSRegularExpression(pattern: regexString, options: .caseInsensitive)
			default:
				return nil
			}
		}
	}
	
	//	MARK: - Destination Directive
	
	/**
	The target location to which the matched file(s) or directory(s) should be installed.
	
	This is equivalent to the `"install_to"` attribute in a .ckan file.
	
	Valid values for this entry are:
	- `"GameData"`
	- `"Missions"` (since CKAN v1.25)
	- `"Ships"`
	- `"Ships/SPH"` (since CKAN v1.12)
	- `"Ships/VAB"` (since CKAN v1.12)
	- `"Ships/@thumbs/VAB"` (since CKAN v1.16)
	- `"Ships/@thumbs/SPH"` (since CKAN v1.16)
	- `"Tutorial"`
	- `"Scenarios"` (since CKAN v1.14)
	- `"GameRoot"` which should be used sparingly with caution, if at all.
	
	A path to a given subfolder location can be specified only under `"GameData"`, e.g. `GameData/MyMod/Plugins`. nueCKAN must check this path and abort the install if any attempts to traverse up directories are found, e.g. `GameData/../bin`.
	
	Subfolder paths under a matched directory will be preserved, but directories will only be created when installing to `GameData/`, `Tutorial/`, or `Scenarios/`.
	*/
	let destination: String
	
	//	MARK: - Optional Directives
	
	/**
	The name to give to the matching directory(s) or file(s) when they're installed.
	
	This is equivalent to the `"as"` attribute in a .ckan file.
	
	This allows renaming directories and files on installation.
	*/
	let newPathNameOnInstallation: String?
	
	/**
	The single or multiple file(s) that should not be installed.
	
	This is equivalent to the `"filter"` attribute in a .ckan file.
	
	They must match a file or directory names, e.g. `"Thumbs.db"`, or `"Source"`. They're case-insensitive.
	*/
	let componentsExcluded: CKANFuckery<String>?
	
	/**
	The single or multiple regular expression string(s) that match against file parts that should not be installed.
	
	This is equivalent to the `"filter_regexp"` attribute in a .ckan file.
	*/
	let componentsExcludedByRegex: CKANFuckery<String>?
	
	/**
	The single or multiple`NSRegularExpression` instance(s) representing source files excluded from installation.
	
	This is computed from `componentsExcludedByRegex`.
	*/
	var componentsExclusionRegex: CKANFuckery<NSRegularExpression>? {
		CKANFuckery(items: componentsExcludedByRegex?.compactMap { try? NSRegularExpression(pattern: $0, options: .caseInsensitive) } )
	}
	/**
	The single or multiple file(s) that should be installed.
	
	This is equivalent to the `"include_only"` attribute in a .ckan file.
	
	They must match a file or directory names, e.g. `"Settings.cfg"`, or `"Plugin"`. They're case-insensitive.
	*/
	let componentsIncludedExclusively: CKANFuckery<String>?
	
	/**
	The single or multiple regular expression string(s) that match against file parts that should be installed.
	
	This is equivalent to the `"include_only_regexp"` attribute in a .ckan file.
	*/
	let componentsIncludedExclusivelyByRegex: CKANFuckery<String>?
	
	/**
	The single or multiple`NSRegularExpression` instance(s) representing source files exclusively included for installation.
	
	This is computed from `componentsIncludedExclusivelyByRegex`.
	*/
	var componentsExclusiveInclusionRegex: CKANFuckery<NSRegularExpression>? {
		CKANFuckery(items: componentsIncludedExclusivelyByRegex?.compactMap { try? NSRegularExpression(pattern: $0, options: .caseInsensitive) } )
	}
	
	/**
	Whether `topMostMatch` and `topMostMatchByRegex` matches files in addition to directories.
	
	This is equivalent to the `"find_matches_files"` attribute in a .ckan file.
	*/
	let sourceDirectiveMatchesFiles: Bool?
}

//	MARK: - Codable Conformance
extension InstallationDirective: Codable {
	/**
	Initialises a `InstallationDirectives` instance by decoding from the given `decoder`.
	
	- Parameter decoder: The decoder to read data from.
	*/
	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		
		//	MARK: Decode Source Directive
		if let directive = try? values.decode(String.self, forKey: .absolutePath) {
			source = .absolutePath(directive)
		} else if let directive = try? values.decode(String.self, forKey: .topMostMatch) {
			source = .topMostMatch(directive)
		} else if let directive = try? values.decode(String.self, forKey: .topMostMatchByRegex) {
			source = .topMostMatchByRegex(directive)
		} else {
			source = .absolutePath("")
		}
		
		//	MARK: Decode Destination Directive
		destination = try values.decode(String.self, forKey: .destination)
		
		//	MARK: Decode Optional Directive
		newPathNameOnInstallation = try? values.decode(String.self, forKey: .newPathNameOnInstallation)
		componentsExcluded = try? values.decode(CKANFuckery<String>.self, forKey: .componentsExcluded)
		componentsExcludedByRegex = try? values.decode(CKANFuckery<String>.self, forKey: .componentsExcludedByRegex)
		componentsIncludedExclusively = try? values.decode(CKANFuckery<String>.self, forKey: .componentsIncludedExclusively)
		componentsIncludedExclusivelyByRegex = try? values.decode(CKANFuckery<String>.self, forKey: .componentsIncludedExclusivelyByRegex)
		sourceDirectiveMatchesFiles = try? values.decode(Bool.self, forKey: .sourceDirectiveMatchesFiles)
	}
	
	/**
	Encodes a `InstallationDirectives` instance`.
	
	- Parameter encoder: The encoder to encode data to.
	*/
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		
		//	MARK: Encode Source Directive
		switch source {
		case .absolutePath(let directive):
			try container.encode(directive, forKey: .absolutePath)
		case .topMostMatch(let directive):
			try container.encode(directive, forKey: .topMostMatch)
		case .topMostMatchByRegex(let directive):
			try container.encode(directive, forKey: .topMostMatchByRegex)
		}
		
		//	MARK: Decode Destination Directive
		try container.encode(destination, forKey: .destination)
		
		//	MARK: Decode Optional Directive
		if let directive = newPathNameOnInstallation { try container.encode(directive, forKey: .newPathNameOnInstallation) }
		if let directive = componentsExcluded { try container.encode(directive, forKey: .componentsExcluded) }
		if let directive = componentsExcludedByRegex { try container.encode(directive, forKey: .componentsExcludedByRegex) }
		if let directive = componentsIncludedExclusively { try container.encode(directive, forKey: .componentsIncludedExclusively) }
		if let directive = componentsIncludedExclusivelyByRegex { try container.encode(directive, forKey: .componentsIncludedExclusivelyByRegex) }
		if let directive = sourceDirectiveMatchesFiles { try container.encode(directive, forKey: .sourceDirectiveMatchesFiles) }
	}
	
	//	Maps between Swift names and JSON names; adds to Codable conformance.
	private enum CodingKeys: String, CodingKey {
		case absolutePath = "file"
		case topMostMatch = "find"
		case topMostMatchByRegex = "find_regexp"
		case destination = "install_to"
		case newPathNameOnInstallation = "as"
		case componentsExcluded = "filter"
		case componentsExcludedByRegex = "filter_regexp"
		case componentsIncludedExclusively = "include_only"
		case componentsIncludedExclusivelyByRegex = "include_only_regexp"
		case sourceDirectiveMatchesFiles = "find_matches_files"
	}
}
