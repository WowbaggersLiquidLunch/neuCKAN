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

A **ModRelease** object contains all metadata of a mod release, as made available on [the CKAN metadata repository][4]. In a way of speech, the structure of a **ModRelease** object conforms to [the CKAN metadate specification][5] \(currently v1.26), which is put concisely in [the specification's json schema][6].

A `Mod` object contains all releases of the same mod, as identified by the same `id`.

[0]: https://github.com/KSP-CKAN/CKAN
[1]: https://github.com/ferram4/Ferram-Aerospace-Research/releases/tag/v0.15.9.1_Liepmann
[2]: https://github.com/ferram4/Ferram-Aerospace-Research/releases/tag/v0.15.9_Liebe
[3]: https://github.com/ferram4/Ferram-Aerospace-Research/releases/tag/v0.15.8.1_Lewis
[4]: https://github.com/KSP-CKAN/CKAN-meta
[5]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md
[6]: https://github.com/KSP-CKAN/CKAN/blob/master/CKAN.schema
*/
struct Mod: Hashable, Codable, Identifiable {
	let id: String
	let modReleases: [ModRelease]
}

