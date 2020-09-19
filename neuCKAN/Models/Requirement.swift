//
//	Requirement.swift
//	neuCKAN
//
//	Created by you on 19-11-06.
//	Copyleft © 2019 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import Interval

//	FIXME: Find a more appropriate name than "Requirement".
//	Could be "ModVersionInterval" or "ModReleasesSlice".

///	A range of release versions of a mod.
///
///	This type serves as a building block of `Requirements`
///
///	- SeeAlso: `Requirements`
struct Requirement: Hashable {
	
	///	The mod's unique identifier.
	///
	///	This is equivalent to the ["identifier" attribute][0] in a .ckan file. The identifier is used whenever the mod is referenced (by `dependencies`, `conflicts`, and elsewhere).
	///
	///	The identifier is both case sensitive for machines, and unique regardless of capitalization for human consumption and case-ignorant systems. For example: the hypothetical identifier `"MyMod"` must always be expressed as `"MyMod"` everywhere, but another module cannot assume the `"mymod"` identifier.
	///
	///	[0]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#identifier
	let modID: String
	
	///	The mod's name.
	///
	///	This is the human readable name of the mod, and may contain any printable characters.
	///
	///	This is equivalent to the ["name" attribute][0] in a .ckan file.
	///
	///	For example:
	///	- "Ferram Aerospace Research (FAR)"
	///	- "Real Solar System".
	///
	///	[0]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#name
	///
	///	- ToDo: Replace the implementation's reliance on `Synecdoche`.
	var modName: String? { Synecdoche.shared.mods[modID]?.name }
	
	//	FIXME: Replace version, versionMin, and versionMax with Range<CKANMetadataVersion>.
	//	Thus avoid using universallyCompatibleVersionString, and avoid special treatment in Comparable conformance.
	///	An interval of mod versions.
	let versions: Interval<CKANMetadataVersion>
	
}

//	MARK: - CustomStringConvertible Conformance
extension Requirement: CustomStringConvertible {
	//	TODO: Recursively handle a release's equivalents without running into an infinite loop.
	///	A description the requirement.
	var description: String {
		guard let modName = modName else { return "mod by ID \(modID) not found" }
		return "\(modName) ∈ \(versions)"
	}
}

//	TODO: Add Encodable conformance.

//	MARK: - Decodable Conformance
extension Requirement: Decodable {
	
	///	Instantiate `Requirement` by decoding from the given `decoder`.
	///	- Parameter decoder: The decoder to read data from.
	///	- Throws: A `DecodingError` instance.
	init(from decoder: Decoder) throws {
		
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		modID = try container.decode(String.self, forKey: .id)
		
		if let exactVersion = try container.decodeIfPresent(CKANMetadataVersion.self, forKey: .exactVersion) {
			versions = exactVersion≤∙≤exactVersion
		} else {
			let minimalVersion = try container.decodeIfPresent(CKANMetadataVersion.self, forKey: .minimalVersion)
			let lowerBoundedVersions = minimalVersion?≤∙∙ ?? .unbounded
			//	TODO: Propose supporting optional chaining with prefix operators.
			var upperBoundedVersions = Interval<CKANMetadataVersion>.unbounded
			if let maximalVersion = try container.decodeIfPresent(CKANMetadataVersion.self, forKey: .maximalVersion) {
				upperBoundedVersions = ∙∙≤maximalVersion
			}
			versions = lowerBoundedVersions ∩ upperBoundedVersions
		}
		
	}
	
	///	A key for encoding and decoding a mod's requirement..
	private enum CodingKeys: String, CodingKey {
		case id = "name"
		case exactVersion = "version"
		case minimalVersion = "min_version"
		case maximalVersion = "max_version"
	}
	
}
