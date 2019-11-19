//
//  ModRelations.swift
//  neuCKAN
//
//  Created by you on 19-11-06.
//  Copyleft © 2019 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import AppKit
import Foundation
import SwiftUI

/**
The mod's relationship to other mods.

This is equivalent to a **Relationship** ["type"][0] in a .ckan file.

`ModRelations` objects are for the relationship fields in `ModRelease` objects. The relationship fields can be used to ensure that a mod is installed with one of its graphics packs, or two mods which conflicting functionality are not installed at the same time.

At its most basic, a **Relationship** field in a .ckan file is an array of objects, each being a name and identifier:

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

It is an error to mix `version` (which specifies an exact version) with either `min_version` or `max_version` in the same object in a .ckan file.

CKAN clients implementing CKAN metadata specification version v1.26 or later must support an alternate form of relationship consisting of an `any_of` key with a value containing an array of relationships. This relationship is considered satisfied if any of the specified modules are installed. It is intended for situations in which a module supports multiple ways of providing functionality, which are not in themselves mutually compatible enough to use the `"provides"` property.

For example:

```
"depends": [
	{
		"any_of": [
			{ "name": "TextureReplacer"          },
			{ "name": "TextureReplacerReplaced"  },
			{ "name": "SigmaReplacements-Skybox" },
			{ "name": "DiRT"                     }
		]
	}
]
```

The `ModRelations` struct is designed to translate and handle the above `any_of` feature.

[0]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#relationships
*/
indirect enum ModRelations: Hashable {
	
	/**
	A set of `ModRelation` instances.
	*/
	case leafRelations(Set<ModRelation>)
	
	/**
	A set of `ModRelations` instances with an "OR" relationship
	
	This represents an **any_of** array in a .ckan file.
	*/
	case anyOfRelations(Set<ModRelations>)
	
	/**
	A set of `ModRelations` instances with an "AND" relationship
	*/
	case allOfRelations(Set<ModRelations>)
}
