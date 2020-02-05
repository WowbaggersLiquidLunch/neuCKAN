//
//	Requirement.swift
//	neuCKAN
//
//	Created by you on 19-11-06.
//	Copyleft © 2019 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import Foundation

/**
A range of release versions of a mod.

This type serves as a building block of `Requirements`

- See Also: `Requirements`
*/
struct Requirement: Hashable, Codable {
	//	MARK: - Mandatory Field
	
	/**
	The globally unique identifier for the mod.
	
	This is equivalent to the ["identifier" attribute][0] in a .ckan file.
	
	This is how the mod will be referred to by other CKAN documents. It may only consist of ASCII-letters, ASCII-digits and `-` (dash).
	
	For example:
	- "FAR"
	- "RealSolarSystem".
	
	The identifier is used whenever the mod is referenced (by `dependsOn`, `conflictsWith`, and elsewhere).
	
	The identifier is both case sensitive for machines, and unique regardless of capitalization for human consumption and case-ignorant systems. For example: the hypothetical identifier `"MyMod"` must always be expressed as `"MyMod"` everywhere, but another module cannot assume the `"mymod"` identifier.
	
	- Attention: If the mod would generate a `FOR` pass in ModuleManager, then the identifier should be same as the `"ModuleManager"` name. For most mods, this means the identifier should be the name of the directory in `GameData/` in which the mod would be installed, or the name of the `.dll` with any version and the ".dll" suffix removed.
	
	[0]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#identifier
	*/
	var id: String?
	
	/**
	Mod name.
	
	This is the human readable name of the mod, and may contain any printable characters.
	
	This is equivalent to the ["name" attribute][0] in a .ckan file.
	
	For example:
	- "Ferram Aerospace Research (FAR)"
	- "Real Solar System".
	
	[0]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#name
	*/
	let name: String
	
	//	MARK: - Optional Fields
	
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
	
	//	MARK: -
	
	//	Maps between Swift names and JSON names; adds Codable conformance.
	private enum CodingKeys: String, CodingKey {
		case name
		case version
		case versionMin = "min_version"
		case versionMax = "max_version"
	}
}

//	MARK: - CustomStringConvertible Conformance

extension Requirement: CustomStringConvertible {
	/**
	A logic expression describing the relation.
	
	The value will be one of the following
	- `"mod's name"` if no versions are specified in the relation.
	- `"mod's name ( ≥ minimum version)"` if only the minimum version is specified.
	- `"mod's name ( ≤ maximum version)"` if only the maximum version is specified.
	- `"mod's name [minimum version, maximum version]"` if both the minimum and maximum versions are specified.
	*/
	var description: String {
		if let version = version {
			return self.name + " (\(version.originalString))"
		} else if let versionMin = versionMin, let versionMax = versionMax {
			return self.name + " [\(versionMin.originalString), \(versionMax.originalString)]"
		} else if let versionMin = versionMin {
			return self.name + " (≥ \(versionMin.originalString)"
		} else if let versionMax = versionMax {
			return self.name + " (≤ \(versionMax.originalString))"
		} else {
			return name
		}
	}
}
