//
//	Requirement.swift
//	neuCKAN
//
//	Created by you on 19-11-06.
//	Copyleft © 2019 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import Foundation

//	FIXME: Find a more appropriate name than "Requirement".

/**
A range of release versions of a mod.

This type serves as a building block of `Requirements`

- See Also: `Requirements`
*/
struct Requirement: Hashable {
	
	//	MARK: Mandatory Field
	
	/**
	The globally unique identifier for the mod.
	
	This is equivalent to the ["identifier" attribute][0] in a .ckan file. The identifier is used whenever the mod is referenced (by `dependencies`, `conflicts`, and elsewhere).
	
	The identifier is both case sensitive for machines, and unique regardless of capitalization for human consumption and case-ignorant systems. For example: the hypothetical identifier `"MyMod"` must always be expressed as `"MyMod"` everywhere, but another module cannot assume the `"mymod"` identifier.
	
	[0]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#identifier
	*/
	let id: String
	
	/**
	Mod name.
	
	This is the human readable name of the mod, and may contain any printable characters.
	
	This is equivalent to the ["name" attribute][0] in a .ckan file.
	
	For example:
	- "Ferram Aerospace Research (FAR)"
	- "Real Solar System".
	
	[0]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#name
	*/
	var name: String? {
		Synecdoche.shared.mods[id]?.name
	}
	
	//	MARK: - Optional Fields
	
	//	FIXME: Replace version, versionMin, and versionMax with Range<Version>.
	//	Thus avoid using universallyCompatibleVersionString, and avoid special treatment in Comparable conformance.
	
	//	TODO: Check for confict between version, versionMin, and versionMax.
	
	/**
	Mod version.
	
	This is equivalent to the ["version" attribute][0] in a .ckan file.
	
	In a .ckan file, this is formatted as `"[epoch:]mod_version"`.
	
	[0]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#version
	*/
	let version: Version?
	
	/**
	Mod minimum version.
	
	This is equivalent to the `"min_version"` attribute in a .ckan file.
	
	In a .ckan file, this is formatted as `"[epoch:]mod_version"`.
	*/
	let versionMin: Version?
	
	/**
	Mod maximum version.
	
	This is equivalent to the `"max_version"` attribute in a .ckan file.
	
	In a .ckan file, this is formatted as `"[epoch:]mod_version"`.
	*/
	let versionMax: Version?
}

//	MARK: - CustomStringConvertible Conformance
extension Requirement: CustomStringConvertible {
	//	TODO: Recursively handle a release's equivalents without running into an infinite loop.
	/**
	A logic expression describing the relation.
	
	The value will be one of the following
	- `"mod's name"` if no versions are specified in the relation.
	- `"mod's name ( ≥ minimum version)"` if only the minimum version is specified.
	- `"mod's name ( ≤ maximum version)"` if only the maximum version is specified.
	- `"mod's name [minimum version, maximum version]"` if both the minimum and maximum versions are specified.
	*/
	var description: String {
		var prefix: String = ""
		if id != "KSP" {
			guard let name = name else { return "mod by ID \(id) not found" }
			prefix = name + " "
		}
		if let version = version {
			return prefix + "\(version.originalString)"
		} else if let versionMin = versionMin, let versionMax = versionMax {
			return prefix + "∈ [\(versionMin.originalString), \(versionMax.originalString)]"
		} else if let versionMin = versionMin {
			return prefix + "≥ \(versionMin.originalString)"
		} else if let versionMax = versionMax {
			return prefix + "≤ \(versionMax.originalString)"
		} else {
			return prefix
		}
	}
}

//	MARK: - Codable Conformance
extension Requirement: Codable {
	//	Maps between Swift names and JSON names; adds Codable conformance.
	private enum CodingKeys: String, CodingKey {
		case id = "name"
		case version
		case versionMin = "min_version"
		case versionMax = "max_version"
	}
}
