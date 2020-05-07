//
//	Requirements.swift
//	neuCKAN
//
//	Created by you on 19-11-06.
//	Copyleft © 2019 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import Foundation
import os.log

//	FIXME: Find a more appropriate name than "Requirements".

///	A group of mod releases that form a certain relationship with the mod release.
///
///	This is equivalent to an object in a ["Relationship" field][0] in CKAN metadata.
///
///	`Requirements` instances are for the relationship fields in `Release` instances. The relationship fields can be used to ensure that a mod is installed with one of its graphics packs, or two mods which conflicting functionality are not installed at the same time.
///
///	- Note: It is an error to mix `"version"` (which specifies an exact version) with either `"min_version"` or `"max_version"` in the same instance in a .ckan file.
///	- See Also: `Requirement`
///
///	[0]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#relationships
indirect enum Requirements: Hashable {
	
	///	A `Relation` instance.
	case leaf(Requirement)
	
	///	A set of `Requirements` instances with an "OR" relationship.
	///
	///	This represents an `"any_of"` array in a CKAN metadata.
	///
	///	CKAN metadata specification since version v1.26 specifies an alternate form of relationship consisting of an `"any_of"` key with a value containing an array of relationships. This relationship is considered satisfied if any of the specified modules are installed. It is intended for situations in which a module supports multiple ways of providing functionality, which are not in themselves mutually compatible enough to use the `"provides"` property.
	///
	///	For example:
	///
	///		"depends": [
	///			{
	///				"any_of": [
	///					{ "name": "TextureReplacer"          },
	///					{ "name": "TextureReplacerReplaced"  },
	///					{ "name": "SigmaReplacements-Skybox" },
	///					{ "name": "DiRT"                     }
	///				]
	///			}
	///		]
	case disjunction(Set<Requirements>)
	
	///	A set of `Requirements` instances with an "AND" relationship
	case conjunction(Set<Requirements>)
	
	///	A logic expression describing the `Requirements` instance.
	var logicExpression: String {
		switch self {
		case let .leaf(requirement):
			return String(describing: requirement)
		case let .disjunction(requirements):
			return requirements.map { "(\(String(describing: $0)))" }.joined(separator: " ∨ ")
		case let .conjunction(requirements):
			return requirements.map { "(\(String(describing: $0)))" }.joined(separator: " ∧ ")
		}
	}
}

//	MARK: - CustomStringConvertible Conformance
extension Requirements: CustomStringConvertible {
	var description: String { logicExpression }
}

//	MARK: - Codable Conformance
extension Requirements: Codable {
	
	///	Initialises a `Requirements` instance by decoding from the given `decoder`.
	///	- Parameter decoder: The decoder to read data from.
	init(from decoder: Decoder) throws {
		var requirementsSet = try Requirements.decodeRequirements(from: decoder)
		
		if requirementsSet.count == 1 {
			self = requirementsSet.popFirst()!
		} else {
			self = .conjunction(requirementsSet)
		}
	}
	
	///	Encodes a `Requirements` instance`.
	///	- Parameter encoder: The encoder to encode data to.
	func encode(to encoder: Encoder) throws {
		var container = encoder.unkeyedContainer()
		switch self {
		case .leaf(let requirement):
			try container.encode(requirement)
		case .conjunction(let requirements):
			try container.encode(contentsOf: requirements)
		case .disjunction(let requirements):
			try container.encode(IntermediateDisjunctionService(Requirements.disjunction(requirements)))
		}
	}
	
	/**
	A service struct that for intermediate `"any_of"` JSON values.
	*/
	private struct IntermediateDisjunctionService: Codable {
		
		///	A memberwise initialiser.
		init(_ requirements: Requirements) {
			self.requirements = requirements
		}
		
		///	Initialises a `Requirements` instance by decoding from the given `decoder`.
		///	- Parameter decoder: The decoder to read data from.
		init(from decoder: Decoder) throws {
			var requirementsSet = try decodeRequirements(from: decoder)
			
			if requirementsSet.count == 1 {
				requirements = requirementsSet.popFirst()!
			} else {
				requirements = Requirements.disjunction(requirementsSet)
			}
		}
		
		///	Encodes a `Requirements` instance`.
		///	- Parameter encoder: The encoder to encode data to.
		func encode(to encoder: Encoder) throws {
			var container = encoder.container(keyedBy: CodingKeys.self)
			try container.encode(requirements, forKey: .requirements)
		}
		
		let requirements: Requirements
		
		private enum CodingKeys: String, CodingKey {
			case requirements = "any_of"
		}
	}
	
	///	Decodes a set of `Requirements` from the given decoder.
	///	- Parameter decoder: The decoder to read data from.
	///	- Returns: An instance of `Set<Requirements>` decoded from the given decoder.
	private static func decodeRequirements(from decoder: Decoder) throws -> Set<Requirements> {
		var requirementsSet: Set<Requirements> = []
		
		//	Create an unkeyed container holding the current level of JSON values.
		var unkeyedValues = try decoder.unkeyedContainer()
		
		//	"Loop" through values in the unkeyed container.
		//	The unkeyed container does not conform to the `Sequence` protocol, but its `currentIndex` property grows by 1 every time when a value is decoded successfully.
		while unkeyedValues.count! > unkeyedValues.currentIndex {
			let containerIndexBeforeLoop = unkeyedValues.currentIndex
			
			if let requirement = try? unkeyedValues.decode(Requirement.self) {
				requirementsSet.insert(Requirements.leaf(requirement))
			} else if let intermediateDisjunction = try? unkeyedValues.decode(IntermediateDisjunctionService.self) {
				requirementsSet.insert(intermediateDisjunction.requirements)
			} else if let requirements = try? unkeyedValues.decode(Requirements.self) {
				requirementsSet.insert(requirements)
			}
			
			//	If the unkeyed container's current index didn't increase by 1 during this loop, then the the unkeyed value at the current index was not decoded, and will not be in future loops. There is no way to increment the index manually, so the unkeyed container will keep trying for the same value. The best choice is to break out of the loop.
			if unkeyedValues.currentIndex <= containerIndexBeforeLoop {
				//	TODO: Include the corresponding JSON value in the log.
				os_log("Unable to decode value #%d in unkeyed container.", type: .debug, unkeyedValues.currentIndex)
				break
			}
		}
		
		return requirementsSet
	}
}
