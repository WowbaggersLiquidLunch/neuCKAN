//
//  Mod.swift
//  neuCKAN
//
//  Created by you on 19-11-01.
//  Copyleft © 2019 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import AppKit
import Foundation

/**
A _mod_.

A mod is defined by its ["identifier" attribute][identifier] in a .ckan file. The attribute is equivalent to the `id` field in a `Mod` struct.

A `Mod` struct aggregates all _releases_ of the same mod under/with the same `id`.

A mod release is a version or distribution of a mod released to public on [CKAN][0]. Each mod release has a version number unique from its sibling releases of the same mod. For example, the following are 3 releases of the same mod "Farram Aerospace Reseach":
- [Ferram Aerospace Research v0.15.9.1	"Liepmann"][1]
- [Ferram Aerospace Research v0.15.9	"Liebe"][2]
- [Ferram Aerospace Research v0.15.8.1	"Lewis"][3]

A `Release` instance contains all metadata of a mod release, as made available on [the CKAN metadata repository][4]. In a way of speech, the structure of a `Release` instance conforms to [the CKAN metadate specification][5] \(currently v1.26), which is put concisely in [the specification's json schema][6].

A `Mod` instance contains all releases of the same mod, as identified by the same `id`.

[identifier]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#identifier
[0]: https://github.com/KSP-CKAN/CKAN
[1]: https://github.com/ferram4/Ferram-Aerospace-Research/releases/tag/v0.15.9.1_Liepmann
[2]: https://github.com/ferram4/Ferram-Aerospace-Research/releases/tag/v0.15.9_Liebe
[3]: https://github.com/ferram4/Ferram-Aerospace-Research/releases/tag/v0.15.8.1_Lewis
[4]: https://github.com/KSP-CKAN/CKAN-meta
[5]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md
[6]: https://github.com/KSP-CKAN/CKAN/blob/master/CKAN.schema
*/
struct Mod: Hashable, Codable, Identifiable {
	
	/**
	Mod name.
	
	This is the human readable name of the mod, and may contain any printable characters.
	
	This is equivalent to the ["name" attribute][0] in a .ckan file.
	
	For example:
	- "Ferram Aerospace Research (FAR)"
	- "Real Solar System".
	
	- Note: This is a computed instance property from a stored `name` property in the corresponding instance of `Release` structure.
	
	[0]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#name
	*/
	var name: String { releases.max(by: { $0.version > $1.version })?.name ?? "mod name does not exist" }
	
	/**
	A short, one line description of the mod and what it does.
	
	This is equivalent to the ["abstract" attribute][0] in a .ckan file.
	
	- Note: This is a computed instance property from a stored `abstruct` property in the corresponding instance of `Release` structure.
	
	[0]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#abstract
	*/
	var abstract: String { releases.max(by: { $0.version > $1.version })?.abstract ?? "mod abstract dores not exist" }
	
	/**
	The globally unique identifier for the mod.
	
	This is equivalent to the ["identifier" attribute][0] in a .ckan file.
	
	This is how the mod will be referred to by other CKAN documents. It may only consist of ASCII-letters, ASCII-digits and `-` (dash).
	
	For example:
	- "FAR"
	- "RealSolarSystem".
	
	The identifier is used whenever the mod is referenced (by `dependencies`, `conflicts`, and elsewhere).
	
	The identifier is both case sensitive for machines, and unique regardless of capitalization for human consumption and case-ignorant systems. For example: the hypothetical identifier `"MyMod"` must always be expressed as `"MyMod"` everywhere, but another module cannot assume the `"mymod"` identifier.
	
	- Attention: If the mod would generate a `FOR` pass in ModuleManager, then the identifier should be same as the `"ModuleManager"` name. For most mods, this means the identifier should be the name of the directory in `GameData/` in which the mod would be installed, or the name of the `.dll` with any version and the ".dll" suffix removed.
	
	[0]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#identifier
	*/
	let id: String
	
	/**
	A collection of _mod releases_ of the same mod, with their associated _version numbers_.
	
	A mod release is a version or distribution of a mod released to public on [CKAN][0]. Each mod release has a version number unique from its sibling releases of the same mod. For example, the following are 3 releases of the same mod "Farram Aerospace Reseach":
	- [Ferram Aerospace Research v0.15.9.1	"Liepmann"][1]
	- [Ferram Aerospace Research v0.15.9	"Liebe"][2]
	- [Ferram Aerospace Research v0.15.8.1	"Lewis"][3]
	
	A `Release` instance contains all metadata of a mod release, as made available on [the CKAN metadata repository][4]. In a way of speech, the structure of a `Release` instance conforms to [the CKAN metadate specification][5] \(currently v1.26), which is put concisely in [the specification's json schema][6].
	
	[0]: https://github.com/KSP-CKAN/CKAN
	[1]: https://github.com/ferram4/Ferram-Aerospace-Research/releases/tag/v0.15.9.1_Liepmann
	[2]: https://github.com/ferram4/Ferram-Aerospace-Research/releases/tag/v0.15.9_Liebe
	[3]: https://github.com/ferram4/Ferram-Aerospace-Research/releases/tag/v0.15.8.1_Lewis
	[4]: https://github.com/KSP-CKAN/CKAN-meta
	[5]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md
	[6]: https://github.com/KSP-CKAN/CKAN/blob/master/CKAN.schema
	[7]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#version
	*/
	var releases: [Release] {
		didSet {
			self.releases.sort(by: { $0.version > $1.version })
		}
	}
}

