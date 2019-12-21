//
//  Relations.swift
//  neuCKAN
//
//  Created by you on 19-11-06.
//  Copyleft © 2019 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import AppKit
import Foundation
import os.log

/**
The mod's relationship to other mods.

This is equivalent to a **Relationship** ["type"][0] in a .ckan file.

`Relations` instances are for the relationship fields in `Release` instances. The relationship fields can be used to ensure that a mod is installed with one of its graphics packs, or two mods which conflicting functionality are not installed at the same time.

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

The `Relations` struct is designed to translate and handle the above `any_of` feature.

[0]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#relationships
*/
indirect enum Relations: Hashable, Codable {
	
	/**
	Initialises a `Relations` instance by decoding from the given `decoder`.
	*/
	init(from decoder: Decoder) throws {
		let relationsData = try? Data(from: decoder)
		let relations = relationsData!.parsed(by: relationsParser(parses:))
		self = relations!
	}
	
	/**
	Encodes a `Relations` instance`.
	*/
	func encode(to encoder: Encoder) throws {
		var container = encoder.unkeyedContainer()
		try container.encode(self.toJSON())
	}
	
	/**
	A `Relation` instance.
	*/
	case leafRelation(Relation)
	
	/**
	A set of `Relations` instances with an "OR" relationship
	
	This represents an **any_of** array in a .ckan file.
	*/
	case anyOfRelations(Set<Relations>)
	
	/**
	A set of `Relations` instances with an "AND" relationship
	*/
	case allOfRelations(Set<Relations>)
	
	/**
	Recursively provide a String representation for the `Relations` instance.
	
	- Returns: A String representation for the `Relations` instance.
	*/
	func toString() -> String {
		switch self {
		case let .leafRelation(relation):
			return relation.toString()
		case let .anyOfRelations(relations):
			return "(\(relations.map { $0.toString() }.joined(separator: " ∨ ")))"
		case let .allOfRelations(relations):
			return "(\(relations.map { $0.toString() }.joined(separator: " ∧ ")))"
		}
	}
	
	/**
	Recursively provide a String representation of a JSON representation for the `Relations` instance.
	
	- Returns: A String representation of a JSON representation for the `Relations` instance.
	*/
	func toJSON() -> String {
		switch self {
		case let .leafRelation(relation):
			return relation.toJSON()
		case let .anyOfRelations(relations):
			return "\"any_off\": [\(relations.map { $0.toJSON() }.joined(separator: ", "))]"
		case let .allOfRelations(relations):
			return "[\(relations.map { $0.toJSON() }.joined(separator: ", "))]"
		}
	}
}


extension Relations: CustomStringConvertible {
	var description: String { toString() }
}


//	Extends `Data` to enable flexible parsing
extension Data {
	
	/**
	Parses JSON data in this `Data` object by the given predicate.
	
	- Parameter jsonParser: A closure that parses `Data` into `Relations?`
	
	- Returns: A `Relations` instance from the JSON data in this `Data` object, or `nil` if an error orcurs or if the JSON data is empty.
	*/
	func parsed(by jsonParser: (Data) -> Relations?) -> Relations?{
		return jsonParser(self)
	}
}


//	Extendes `Relation` to provide a String representation of a JSON representation for the `Relation` instance.
extension Relation {
	
	/**
	Provide a String representation of a JSON representation for the `Relation` instance.
	
	- Returns: A String representation of a JSON representation for the `Relation` instance.
	*/
	func toJSON() -> String{
		var jsonObjectAsDictionary: [String: String] = ["name": name]
		
		if let version = version { jsonObjectAsDictionary["version"] = version.originalString }
		if let versionMin = versionMin { jsonObjectAsDictionary["min_version"] = versionMin.originalString }
		if let versionMax = versionMax { jsonObjectAsDictionary["max_version"] = versionMax.originalString }
		
		return "{ \(jsonObjectAsDictionary.map { "\($0.key): \($0.value)" }.joined(separator: ", ")) }"
	}
}
