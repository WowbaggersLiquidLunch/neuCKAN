//
//	Resources.swift
//	neuCKAN
//
//	Created by you on 19-11-06.
//	Copyleft © 2019 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import Foundation

/**
Mod resources.

This is equivalent to the ["resources" attribute][0] in a .ckan file.

The `Resources` struct describes additional information that a user or program may wish to know about the mod, but which are not required for its installation or indexing. Presently the following fields are described. Unless specified otherwise, these are `URL`s:
- `homepage` : The preferred landing page for the mod.
- `bugTracker` : The mod's bugtracker if it exists.
- `license` : The mod's license.
- `repository` : The repository where the module source can be found.
- `ci` : Continuous Integration (e.g. Jenkins) Server where the module is being built. x_ci is an alias used in netkan.
- `spacedock` : The mod on SpaceDock.
- `curse` : The mod on Curse.
- `manual` : The mod's manual, if it exists.

While all currently defined resources are `URL`s, future revisions of the CKAN metadata specification may provide for more complex types.

[0]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#resources
*/
struct Resources: Hashable {
	let homepage: URL?
	let bugTracker: URL?
//	let license: URL?
	let repository: URL?
	let ci: URL?
	let spaceDock: URL?
	let curseForge: URL?
	let manual: URL?
	let netkan: URL?
	let screenshot: URL?
}

//	MARK: - Codable Conformance
extension Resources: Codable {
	private enum CodingKeys: String, CodingKey {
		case homepage
		case bugTracker = "bugtracker"
//		case license
		case repository
		case ci
		case spaceDock = "spacedock"
		case curseForge = "curse"
		case manual
		case netkan = "metanetkan"
		case screenshot = "x_screenshot"
	}
}
