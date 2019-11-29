//
//  Mod.swift
//  neuCKAN
//
//  Created by you on 19-11-01.
//  Copyleft © 2019 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import AppKit
import Foundation
import SwiftUI

/**
A _mod_.

A mod is defined by its **identifier** attribute in a .ckan file. The attribute is equivalent to the `id` field in a `Mod` struct.

A `Mod` struct aggregates all _releases_ of the same mod under/with the same `id`.

A mod release is a version or distribution of a mod released to public on [CKAN][0]. Each mod release has a version number unique from its sibling releases of the same mod. For example, the following are 3 releases of the same mod "Farram Aerospace Reseach":
- [Ferram Aerospace Research v0.15.9.1	"Liepmann"][1]
- [Ferram Aerospace Research v0.15.9	"Liebe"][2]
- [Ferram Aerospace Research v0.15.8.1	"Lewis"][3]

A **ModRelease** instance contains all metadata of a mod release, as made available on [the CKAN metadata repository][4]. In a way of speech, the structure of a **ModRelease** instance conforms to [the CKAN metadate specification][5] \(currently v1.26), which is put concisely in [the specification's json schema][6].

A `Mod` instance contains all releases of the same mod, as identified by the same `id`.

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
	
	This is equivalent to the **name** [attribute][0] in a .ckan file.
	
	For example:
	- "Ferram Aerospace Research (FAR)"
	- "Real Solar System".
	
	- Note: This is a computed instance property from a stored `name` property in the corresponding instance of `ModRelease` structure.
	
	[0]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#name
	*/
	var name: String { modReleases[modReleases.keys.sorted(by: >)[0]]?.name ?? "mod name does not exist" }
	
	/**
	A short, one line description of the mod and what it does.
	
	This is equivalent to the **abstract** [attribute][0] in a .ckan file.
	
	- Note: This is a computed instance property from a stored `abstruct` property in the corresponding instance of `ModRelease` structure.
	
	[0]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#abstract
	*/
	var abstruct: String { modReleases[modReleases.keys.sorted(by: >)[0]]?.name ?? "mod description does not exist" }
	
	/**
	The globally unique identifier for the mod.
	
	This is equivalent to the **identifier** [attribute][0] in a .ckan file.
	
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
	
	A **ModRelease** instance contains all metadata of a mod release, as made available on [the CKAN metadata repository][4]. In a way of speech, the structure of a **ModRelease** instance conforms to [the CKAN metadate specification][5] \(currently v1.26), which is put concisely in [the specification's json schema][6].
	
	***
	
	A version number is a set of numbers that identify a unique evolution (i.e. release) of a mod.
	
	The `Version` structure that stores a version nymber is equivalent to the **version** [attribute][7] in a .ckan file. It translates a .ckan file's `"[epoch:]version"` version string into a `Int Optional`: `epoch`, and an `Int Array`: `version`.
	
	When comparing two version numbers, first the `epoch` of each are compared, then the `version` if epoch is equal. epoch is compared numerically. The `version` is compared in sequence of its elements.
	
	[0]: https://github.com/KSP-CKAN/CKAN
	[1]: https://github.com/ferram4/Ferram-Aerospace-Research/releases/tag/v0.15.9.1_Liepmann
	[2]: https://github.com/ferram4/Ferram-Aerospace-Research/releases/tag/v0.15.9_Liebe
	[3]: https://github.com/ferram4/Ferram-Aerospace-Research/releases/tag/v0.15.8.1_Lewis
	[4]: https://github.com/KSP-CKAN/CKAN-meta
	[5]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md
	[6]: https://github.com/KSP-CKAN/CKAN/blob/master/CKAN.schema
	[7]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#version
	*/
	var modReleases: [Version: ModRelease]
}

