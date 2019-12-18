//
//  InstallationDirectives.swift
//  neuCKAN
//
//  Created by you on 19-11-05.
//  Copyleft © 2019 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import AppKit
import Foundation

/**
A list of installation directives for the mod.

This is equivalent to the **install** [attribute][0] in a .ckan file.

If no installation directives are provided, neuCKAN must find the top-most directory in the archive that matches the module identifier, which it shall install with `GameData/` as the target.

A typical set of installation directives only has **file** and **install_to** attributes in a .ckan file:

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
struct InstallationDirectives: Hashable, Codable {
	//	MARK: - source directives
	
	/**
	The file or directory root that this directive pertains to.
	
	This is equivalent to the **file** attribute in a .ckan file.
	
	All leading directories are stripped from the start of the filename during install. For example, `MyMods/KSP/Foo` will be installed into `GameData/Foo`.
	*/
	let root: String?
	
	/**
	The top-most directory that matches exactly the name specified. (since CKAN v1.4)
	
	This is equivalent to the **find** attribute in a .ckan file.

	This is particularly useful when distributions have structures that change by releases.
	*/
	let fickleRoot: String?
	
	/**
	The top-most directory that matches the specified regular expression. (since CKAN v1.10)
	
	This is equivalent to the **find_regexp** attribute in a .ckan file.
	
	This is particularly useful when distributions have structures that change by releases, but `find` is insufficient because multiple directories or files contain the same name. Directories' separators will have been normalised to forward-slashes first, and the trailing slash for each directory removed before the regular expression is run.
	
	- Warning: Use sparingly and with caution, regular expressions are prone to hard-to-spot mistakes.
	*/
	let fickleRootByRegex: String?
	
	//	MARK: - destination directive
	
	/**
	The target location where the matched file(s) or directory(s) should be installed.
	
	This is equivalent to the **install_to** attribute in a .ckan file.
	
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
	
	//	optional directives
	
	/**
	The name to give to the matching directory(s) or file(s) when they're installed.
	
	This is equivalent to the **as** attribute in a .ckan file.
	
	This allows renaming directories and files on installation.
	*/
	let anonym: String?
	
	/**
	File parts that should not be installed.
	
	This is equivalent to the **filter** attribute in a .ckan file.
	
	They must match a file or directory names, e.g. `"Thumbs.db"`, or `"Source"`. They're case-insensitive.
	*/
	let exclusions: [String]?
	
	/**
	Regular expressions that match against file parts that should not be installed.
	
	This is equivalent to the **filter_regexp** attribute in a .ckan file.
	*/
	let exclusionsByRegex: [String]?
	
	/**
	File parts that should be installed.
	
	This is equivalent to the **include_only** attribute in a .ckan file.
	
	They must match a file or directory names, e.g. `"Settings.cfg"`, or `"Plugin"`. They're case-insensitive.
	*/
	let inclusions: [String]?
	
	/**
	Regular expressions that match against file parts that should be installed.
	
	This is equivalent to the **include_only_regexp** attribute in a .ckan file.
	*/
	let inclusionsByRegex: [String]?
	
	/**
	Whether `fickleRoot` and `fickleRootByRegex` matches files in addition to directories.
	
	This is equivalent to the **find_matches_files** attribute in a .ckan file.
	*/
	let findMatchesFiles: Bool
}

