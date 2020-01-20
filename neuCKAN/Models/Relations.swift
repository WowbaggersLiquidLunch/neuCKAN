//
//	Relations.swift
//	neuCKAN
//
//	Created by you on 19-11-06.
//	Copyleft © 2019 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import Foundation
import os.log

/**
The mod's relationship to other mods.

This is equivalent to a ["Relationship" type][0] in a .ckan file.

`Relations` instances are for the relationship fields in `Release` instances. The relationship fields can be used to ensure that a mod is installed with one of its graphics packs, or two mods which conflicting functionality are not installed at the same time.

At its most basic, a `Relationship` field in a .ckan file is an array of instances, each being a name and identifier:

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

It is an error to mix `"version"` (which specifies an exact version) with either `"min_version"` or `"max_version"` in the same instance in a .ckan file.

CKAN clients implementing CKAN metadata specification version v1.26 or later must support an alternate form of relationship consisting of an `"any_of"` key with a value containing an array of relationships. This relationship is considered satisfied if any of the specified modules are installed. It is intended for situations in which a module supports multiple ways of providing functionality, which are not in themselves mutually compatible enough to use the `"provides"` property.

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
	
	//	MARK: - Codable Conformance
	
	/**
	Initialises a `Relations` instance by decoding from the given `decoder`.
	
	- Parameter decoder: The decoder to read data from.
	*/
	init(from decoder: Decoder) throws {
		var relationsSet = try decodeRelations(from: decoder)
		
		if relationsSet.count == 1 {
			self = relationsSet.popFirst()!
		} else {
			self = .allOfRelations(relationsSet)
		}
	}
	
	/**
	Encodes a `Relations` instance`.
	
	- Parameter encoder: The encoder to encode data to.
	*/
	func encode(to encoder: Encoder) throws {
		var container = encoder.unkeyedContainer()
		switch self {
		case .leafRelation(let relation):
			try container.encode(relation)
		case .allOfRelations(let relations):
			try container.encode(contentsOf: relations)
		case .anyOfRelations(let relations):
			try container.encode(IntermediateRelationsService(Relations.anyOfRelations(relations)))
		}
	}
	
	//	MARK: - Enumeration Cases
	
	/**
	A `Relation` instance.
	*/
	case leafRelation(Relation)
	
	/**
	A set of `Relations` instances with an "OR" relationship
	
	This represents an `"any_of"` array in a .ckan file.
	*/
	case anyOfRelations(Set<Relations>)
	
	/**
	A set of `Relations` instances with an "AND" relationship
	*/
	case allOfRelations(Set<Relations>)
	
	//	MARK: - Instance Method
	
	/**
	A logic expression describing the `Relations` instance.
	*/
	var logicExpression: String {
		switch self {
		case let .leafRelation(relation):
			return String(describing: relation)
		case let .anyOfRelations(relations):
			return "(\(relations.map { String(describing: $0) }.joined(separator: " ∨ ")))"
		case let .allOfRelations(relations):
			return "(\(relations.map { String(describing: $0) }.joined(separator: " ∧ ")))"
		}
	}
}


//	MARK: - CustomStringConvertible Conformance

extension Relations: CustomStringConvertible {
	var description: String { logicExpression }
}


//	MARK: -

/**
A service struct that for intermediate `"any_of"` JSON values.
*/
struct IntermediateRelationsService: Codable {
	
	/**
	Initialises a `Relations` instance by decoding from the given `decoder`.
	
	- Parameter decoder: The decoder to read data from.
	*/
	init(from decoder: Decoder) throws {
		var relationsSet = try decodeRelations(from: decoder)
		
		if relationsSet.count == 1 {
			relations = relationsSet.popFirst()!
		} else {
			relations = Relations.anyOfRelations(relationsSet)
		}
	}
	
	/**
	Encodes a `Relations` instance`.
	
	- Parameter encoder: The encoder to encode data to.
	*/
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(relations, forKey: .relations)
	}
	
	/**
	A memberwise initialiser.
	*/
	init(_ relations: Relations) {
		self.relations = relations
	}
	
	let relations: Relations
	
	private enum CodingKeys: String, CodingKey {
		case relations = "any_of"
	}
}


/**
Decodes a set of `Relations` from the given decoder.

- Parameter decoder: The decoder to read data from.

- Returns: An instance of `Set<Relations>` decoded from the given decoder.
*/
fileprivate func decodeRelations(from decoder: Decoder) throws -> Set<Relations> {
	var relationsSet: Set<Relations> = []
	
	//	Create an unkeyed container holding the current level of JSON values.
	var unkeyedValues = try decoder.unkeyedContainer()
	
	//	"Loop" through values in the unkeyed container.
	//	The unkeyed container does not conform to the `Sequence` protocol, but its `currentIndex` property grows by 1 every time when a value is decoded successfully.
	while unkeyedValues.count! > unkeyedValues.currentIndex {
		let containerIndexBeforeLoop = unkeyedValues.currentIndex
		
		if let relation = try? unkeyedValues.decode(Relation.self) {
			relationsSet.insert(Relations.leafRelation(relation))
		} else if let intermediateRelations = try? unkeyedValues.decode(IntermediateRelationsService.self) {
			relationsSet.insert(intermediateRelations.relations)
		} else if let relations = try? unkeyedValues.decode(Relations.self) {
			relationsSet.insert(relations)
		}
		
		//	If the unkeyed container's current index didn't increase by 1 during this loop, then the the unkeyed value at the current index was not decoded, and will not be in future loops. There is no way to increment the index manually, so the unkeyed container will keep trying for the same value. The best choice is to break out of the loop.
		if unkeyedValues.currentIndex <= containerIndexBeforeLoop {
			//	TODO: Include the corresponding JSON value in the log.
			os_log("Unable to decode value #%d in unkeyed container.", type: .debug, unkeyedValues.currentIndex)
			break
		}
	}
	
	return relationsSet
}
