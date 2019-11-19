//
//  ModRelation.swift
//  neuCKAN
//
//  Created by you on 19-11-06.
//  Copyleft © 2019 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import AppKit
import Foundation
import SwiftUI

/**
The mod's relationship to another other mod.

This is equivalent to an instance in the **Relationship** ["type"][0] in a .ckan file.

`ModRelation` instances are building blocks for the relationship fields in `ModRelease` instances. The relationship fields can be used to ensure that a mod is installed with one of its graphics packs, or two mods which conflicting functionality are not installed at the same time.

At its most basic, a **Relationship** field in a .ckan file is an array of instances, each being a name and identifier:

```
"depends" : [
{ "name" : "ModuleManager" },
{ "name" : "RealFuels" },
{ "name" : "RealSolarSystem" }
]
```

Each relationship is an array of entries, each entry must have a `name` field in a .ckan file.

The optional fields `min_version`, `max_version`, and `version` in a .ckan file may more precisely describe which versions are needed:

```
"depends" : [
{ "name" : "ModuleManager",   "min_version" : "2.1.5" },
{ "name" : "RealSolarSystem", "min_version" : "7.3"   },
{ "name" : "RealFuels" }
]
```

It is an error to mix `version` (which specifies an exact version) with either `min_version` or `max_version` in the same instance in a .ckan file.

The `ModRelation` struct translate a single instance in .ckan files' **Relationship** field, following the same principle.

neuCKAN must respect the optional version fields if present.

[0]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#relationships
*/
struct ModRelation: Hashable, Codable, Identifiable {
	//	mandatory field
	
	/**
	The globally unique identifier for the mod.
	
	This is equivalent to the **identifier** [attribute][0] in a .ckan file.
	
	This is how the mod will be referred to by other CKAN documents. It may only consist of ASCII-letters, ASCII-digits and `-` (dash).
	
	For example:
	- "FAR"
	- "RealSolarSystem".
	
	The identifier is used whenever the mod is referenced (by `dependsOn`, `conflictsWith`, and elsewhere).
	
	The identifier is both case sensitive for machines, and unique regardless of capitalization for human consumption and case-ignorant systems. For example: the hypothetical identifier `"MyMod"` must always be expressed as `"MyMod"` everywhere, but another module cannot assume the `"mymod"` identifier.
	
	- Attention: If the mod would generate a `FOR` pass in ModuleManager, then the identifier should be same as the `"ModuleManager"` name. For most mods, this means the identifier should be the name of the directory in `GameData/` in which the mod would be installed, or the name of the `.dll` with any version and the ".dll" suffix removed.
	
	[0]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#identifier
	*/
	let id: String
	
	//	optional fields
	
	/**
	Mod version.
	
	This is equivalent to the **version** [attribute][0] in a .ckan file.
	
	In a .ckan file, this is formatted as `"[epoch:]mod_version"`.
	
	[0]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#version
	*/
	let version: Version?
	
	/**
	Mod minimum version.
	
	This is equivalent to the **min_version** attribute in a .ckan file.
	
	In a .ckan file, this is formatted as `"[epoch:]mod_version"`.
	*/
	let versionMin: Version?
	
	/**
	Mod maximum version.
	
	This is equivalent to the **max_version** attribute in a .ckan file.
	
	In a .ckan file, this is formatted as `"[epoch:]mod_version"`.
	*/
	let versionMax: Version?
}
