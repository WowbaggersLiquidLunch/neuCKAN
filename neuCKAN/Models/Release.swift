//
//	Release.swift
//	neuCKAN
//
//	Created by you on 19-11-01.
//	Copyleft © 2019 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import Foundation

/**
A single _mod release_.

A mod release is a version or distribution of a mod released to public on [CKAN][0]. Each mod release has a version number unique from its sibling releases of the same mod. For example, the following are 3 releases of the same mod "Farram Aerospace Reseach":
- [Ferram Aerospace Research v0.15.9.1	"Liepmann"][1]
- [Ferram Aerospace Research v0.15.9	"Liebe"][2]
- [Ferram Aerospace Research v0.15.8.1	"Lewis"][3]

A `Release` instance contains all metadata of a mod release, as made available on [the CKAN metadata repository][4]. In a way of speech, the structure of a `Release` instance conforms to [the CKAN metadate specification][5] \(currently v1.27), which is put concisely in [the specification's json schema][6].

[0]: https://github.com/KSP-CKAN/CKAN
[1]: https://github.com/ferram4/Ferram-Aerospace-Research/releases/tag/v0.15.9.1_Liepmann
[2]: https://github.com/ferram4/Ferram-Aerospace-Research/releases/tag/v0.15.9_Liebe
[3]: https://github.com/ferram4/Ferram-Aerospace-Research/releases/tag/v0.15.8.1_Lewis
[4]: https://github.com/KSP-CKAN/CKAN-meta
[5]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md
[6]: https://github.com/KSP-CKAN/CKAN/blob/master/CKAN.schema
*/
struct Release: Hashable {
	
	//	MARK: - Mandatory Fields
	
	/**
	The version number of the CKAN specification used to create this .ckan file.
	
	This is equivalent to the ["spec_version" attribute][0] in a .ckan file.
	
	In a .ckan file, the value is formatted as `vx.x` string (eg: `"v1.2"`), and it's the minimum version of the reference CKAN client that will read this file. For compatibility with CKAN pre-release clients, and the CKAN v1.0 client, the special integer 1 is encouraged by CKAN project.
	
	[0]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#spec_version
	*/
	let ckanMetadataSpecificationVersion: Version
	
	/**
	The mod's name.
	
	This is the human readable name of the mod, and may contain any printable characters.
	
	This is equivalent to the ["name" attribute][0] in a .ckan file.
	
	For example:
	- "Ferram Aerospace Research (FAR)"
	- "Real Solar System".
	
	[0]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#name
	*/
	let name: String
	
	/**
	A short, one line description of the mod and what it does.
	
	This is equivalent to the ["abstract" attribute][0] in a .ckan file.
	
	[0]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#abstract
	*/
	let abstract: String
	
	/**
	The mod's globally unique identifier.
	
	This is equivalent to the ["identifier" attribute][0] in a .ckan file.
	
	For example:
	- "FAR"
	- "RealSolarSystem".
	
	The identifier is used whenever the mod is referenced (by `dependencies`, `conflicts`, and elsewhere).
	
	The identifier is both case sensitive for machines, and unique regardless of capitalization for human consumption and case-ignorant systems. For example: the hypothetical identifier `"MyMod"` must always be expressed as `"MyMod"` everywhere, but another module cannot assume the `"mymod"` identifier.
	
	[0]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#identifier
	*/
	let modID: String
	
	/**
	A fully formed URL, indicating where the described version of the mod may be downloaded.
	
	This is equivalent to the ["download" attribute][0] in a .ckan file.
	
	- Note: This field is not required if `self.kind` is `"metapackage"`.
	
	[0]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#download
	*/
	let downloadLink: URL
	
	/**
	The licence(s), under which the mod is released.
	
	This is equivalent to the ["license" attribute][0] in a .ckan file.
	
	The CKAN project limits allowable mod licences to the same rules as per the [Debian licence specification][1], with the following modifications:
	- The `"MIT"` licence is always taken to mean [the Expat licence][2].
	- The creative commons licences are permitted without a version number, indicating the author did not specify which version applies.
	- Stripping of trailing zeros is not recognised.
	- `"WTFPL"` is recognised as a valid licence. (Since CKAN Metadata Specification v1.2)
	- `"Unlicence"` is recognised as a valid licence. (Since CKAN Metadata Specification v1.18)
	
	The following licence strings are also valid and indicate other licensing not described above:
	- `"open-source"`: Other Open Source Initiative (OSI) approved licence.
	- `"restricted"`: Requires special permission from copyright holder.
	- `"unrestricted"`: Not an OSI approved licence, but not restricted.
	- `"unknown"`: licence not provided in metadata
	
	A single licence (since CKAN v1.0) , or list of licences (since CKAN v1.8) may be provided for each mod release. In the following example, both values are valid, with the first describing a mod released under the BSD licence, the second under the user's choice of 2-Clause BSD or GPL 2.0 licences:
	
	```Swift
	let licences: [String] = ["BSD-2-clause"]
	let licences: [String] = ["BSD-2-clause", "GPL-2.0"]
	```
	
	A future version of the CKAN metadata specification may provide for per-file licensing declarations.
	
	[0]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#license
	[1]: https://www.debian.org/doc/packaging-manuals/copyright-format/1.0/#license-specification
	[2]: https://www.debian.org/legal/licenses/mit
	*/
	let licences: CKANFuckery<String>
	
	/**
	Mod version.
	
	This is equivalent to the ["version" attribute][0] in a .ckan file.
	
	In a .ckan file, this is formatted as `"[epoch:]mod_version"`.
	
	[0]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#version
	*/
	let version: Version
	
	//	MARK: - Optional Fields
	//	All optional fields must be of Optional types.
	
	/**
	A list of installation directives for the mod release.
	
	This is equivalent to the ["install" attribute][0] in a .ckan file.
	
	[0]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#install
	*/
	let installationDirectives: [InstallationDirectives]?
	
	/**
	A comment field for the mod release.
	
	This is equivalent to the ["install" attribute][0] in a .ckan file.
	
	This is ignored. It is not displayed to users, nor used by neuCKAN. Its primarily used to convey information to humans examining the CKAN file manually
	
	[0]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#comment
	*/
//	private let comment: String?
	
	/**
	Author(s) of the mod release.
	
	This is equivalent to the ["author" attribute][0] in a .ckan file.
	
	[0]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#author
	*/
	let authors: CKANFuckery<String>?
	
	/**
	A free form, long text description of the mod release.
	
	This is equivalent to the ["description" attribute][0] in a .ckan file.
	
	It's suitable for displaying detailed information about the mod release.
	
	[0]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#description
	*/
	let description: String?
	
	/**
	The status of the mod release.
	
	This is equivalent to the ["release_status" attribute][0] in a .ckan file.
	
	The value can be one of `"stable"`, `"testing"` or `"development"`, in order of decreasing stability. If not specified, a value of `"stable"` is assumed.
	
	[0]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#release_status
	*/
	let status: String?
	
	/**
	The version of KSP release this mod release is targeting.
	
	This is equivalent to the ["ksp_version" attribute][0] in a .ckan file.
	
	In a .ckan file, this may be the string `"any"` which will be changed to` "∀x∈ℍ.∀x∈ℍ.∀x∈ℍ"` in neuCKAN internally, a number, e.g. `"0.23.5"`, or may contain only the first two parts of the version string, e.g. `"0.25"`. In the latter example, any release version starting with `"0.25"` is acceptable.
	
	[0]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#ksp_version
	*/
	let kspVersion: Version?
	
	/**
	The minimum version of KSP required by the mod release.
	
	This is equivalent to the ["ksp_version_min" attribute][0] in a .ckan file.
	
	It is an error to have both `kspVersionMin` and the `kspVersion` not `nil`.
	
	[0]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#ksp_version_min
	*/
	let kspVersionMin: Version?
	
	/**
	The maximum version of KSP required by the mod release.
	
	This is equivalent to the ["ksp_version_max" attribute][0] in a .ckan file.
	
	It is an error to have both `kspVersionMax` and the `kspVersion` not `nil`.
	
	[0]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#ksp_version_max
	*/
	let kspVersionMax: Version?
	
	/**
	Whether checks for KSP version verbatim.
	
	This is equivalent to the ["ksp_version_strict" attribute][0] in a .ckan file.
	
	If `true`, the mod will only be installed if the user's KSP version is exactly targeted by the mod.
	
	If `false`, the mod will be installed if the KSP version it targets is "generally recognised" as being compatible with the KSP version the user has installed. It is up to the neuCKAN to determine what is "generally recognised" as working. For example, a mod with a `kspVersion` of `"1.0.3"` will also install in KSP 1.0.4 (but not any other version) when `kspVersionVerbatim` is `false`.
	
	This field defaults to `false`.
	
	- Note: CKAN prior to metadata specification version 1.16 would only perform strict checking.
	
	[0]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#ksp_version_strict
	*/
	let kspVersionVerbatim: Bool?
	
	/**
	Tags for the mod release.
	
	This is equivalent to the ["tags" attribute][0] in a .ckan file.
	
	The `"tags"` field describes keywords that a user or program may use to classify or filter the mods in a list, but it's are not required. The keywords may include general descriptions of how the mod interacts with or alters KSP or specific descriptions of what has been added or changed from stock gameplay. Tags may contain lowercase alphanumeric characters or hyphens.
	
	For example:
	
	```
	let tags: [String]? = [
		"physics",
		"parts",
		"oceanic",
		"thermal",
		"science",
		"my-1-custom-tag"
	]
	```
	
	All included tags should be indexed and searchable.
	
	- Note: Tags have not yet been implemented in the CKAN as of 2019-11-05.
	
	[0]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#tags
	*/
	let tags: Set<String>?
	
	/**
	A list of locales for the mod release.
	
	This is equivalent to the ["localization" attribute][0] in a .ckan file.
	
	The locales are coded in KSP's naming convention:
	
	```
	let locales: [String]? = [
		"en-us",
		"es-es",
		"fr-fr",
		"zh-cn",
		"ru"
	]
	```
	
	[0]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#localizations
	*/
	let locales: Set<String>?
	
	//	relationships (optional)
	
	/**
	Mod dependencies.
	
	This is equivalent to the ["depends" attribute][0] in a .ckan file.
	
	Dependencies must be installed along with the current mod release being installed.
	
	[0]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#depends
	*/
	let dependencies: Requirements?
	
	/**
	Other mods recommended by the mod release.
	
	This is equivalent to the ["recommends" attribute][0] in a .ckan file.
	
	This is a strong recommendation, and by default these mods will be installed unless the user requests otherwise through the preferences settings.
	
	[0]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#recommends
	*/
	let recommendedMods: Requirements?
	
	/**
	Other mods suggested by the mod release.
	
	This is equivalent to the ["suggests" attribute][0] in a .ckan file.
	
	This is a weak recommendation, and by default these mods will **not** be installed unless the user requests otherwise through the preferences settings.
	
	[0]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#suggests
	*/
	let suggestedMods: Requirements?
	
	/**
	Other mods supported by the mod release.
	
	This is equivalent to the ["supports" attribute][0] in a .ckan file.
	
	These supported mods may not interact or enhance the mod, but they will work correctly with it. These mods should not be installed, this is an informational field only.
	
	[0]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#supports
	*/
	let supportedMods: Requirements?
	
	/**
	Mod conflicts.
	
	This is equivalent to the ["conflicts" attribute][0] in a .ckan file.
	
	The current mod will not be installed if any of these mods are already on the system, unless forced by the user.
	
	[0]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#conflicts
	*/
	let conflicts: Requirements?
	
	/**
	The mod dies, and a new one is born.
	
	This is equivalent to the ["replaced-by" attribute][0] in a .ckan file.
	
	The current mod will not be installed if any of these mods are already on the system, unless forced by the user.
	
	This is a way to mark a specific mod identifier as being obsoleted and tell the client what it has been replaced by. It contains a single mod that should be selected for installation if a replace command is performed on this mod, while this mod is uninstalled. If this mod identifier is brought back to life, an epoch change should be applied. A `"replaced_by"` `Relationship` should be added to the .ckan file of the final release of the mod being replaced. The listed mod should include a `"provides"` relationship either to this mod, or one of this mod's listed `"provides"` in the .ckan file.
	
	A `replaced_by` field in a .ckan file differs from other `Relationship` fields in two ways:
	- It is not an array. Only a single mod can be defined as the replacement.
	- Only `"version"` and `"min_version"` options are permitted.
	
	[0]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#replaced-by
	*/
	let successors: Requirements?
		
	/**
	Mod resources.
	
	This is equivalent to the ["resources" attribute][0] in a .ckan file.
	
	[0]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#resources
	*/
	let resources: Resources?
	
	//	MARK: - Special-Use Fields (Optional)
	
	/**
	The type of package.
	
	This is equivalent to the ["kind" attribute][0] in a .ckan file.
	
	This field defaults to `"package"`, the other option (and presently the only time the field is explicitly declared) is `"metapackage"`.
	
	[0]:  https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#kind
	*/
	let kind: String?
	
	//	TODO: Recursively handle equivalents without running into an infinite loop.
	
	/**
	A list of identifiers, that this mod is equivalent to.
	
	This is equivalent to the ["provides" attribute][0] in a .ckan file.
	
	This field is intended for mods that require one of a selection of texture downloads, or one of a selection of mods which provide equivalent functionality. It is recommended that this field be used sparingly, as all mods with the same `equivalants` string are essentially declaring they can be used interchangeably.
	
	It is considered acceptable to use this field if a mod is renamed, and the old name of the mod is listed in the `equivalents` field. This allows for mods to be renamed without updating all other mods which depend upon it.
	
	A module may both be equivalent in functionality, and `conflict` with the same functionality. This allows relationships that ensure only one set of assets are installed. For example, CustomBiomesRSS and CustomBiomesKerbal both are equivalent in functionality and conflict with CustomBiomesData, ensuring that both cannot be installed at the same time.
	
	[0]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#provides
	*/
	let equivalents: [String]?
	
	//	TODO: Add instance property "archive" that include "size", "hash", and "cache"
	
	/**
	The mod's download's size.
	
	This is equivalent to the ["download_size" attribute][0] in a .ckan file.
	
	`archiveSize` is the number of bytes to expect when downloading from `downloadLink`.
	
	[0]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#download_size
	*/
	let archiveSize: Int?
	
	/**
	The mod's download's hash digests.
	
	This is equivalent to the ["download_hash" attribute][0] in a .ckan file.
	
	It's the SHA1 and SHA256 calculated hashes of the resulting file downloaded.
	
	[0]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#download_hash
	*/
	let archiveHash: Hash?
	
	/**
	Type of downloaded mod file.
	
	This is equivalent to the ["download_content_type" attribute][0] in a .ckan file.
	
	For example:
	
	```
	let fileType: String? = "application/zip"
	```
	
	[0]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#download_content_type
	*/
	let fileType: String?
}

//	MARK: - Identifiable Conformance
//	TODO: Uncomment Identifiable conformance once tuples have Hashable conformance
//extension Release: Identifiable {
//
//	var id: (String, Version) { (modID, version) }
//}

//	MARK: - Codable Conformance
extension Release: Codable {
	//	Maps between Swift names and JSON names; adds to Codable conformance.
	private enum CodingKeys: String, CodingKey {
		case ckanMetadataSpecificationVersion = "spec_version"
		case name
		case abstract
		case modID = "identifier"
		case downloadLink = "download"
		case licences = "license"
		case version
		case installationDirectives = "install"
		case authors
		case description
		case status = "release_status"
		case kspVersion = "ksp_version"
		case kspVersionMin = "ksp_version_min"
		case kspVersionMax = "ksp_version_max"
		case kspVersionVerbatim = "ksp_version_strict"
		case tags
		case locales = "localization"
		case dependencies = "depends"
		case recommendedMods = "recommends"
		case suggestedMods = "suggests"
		case supportedMods = "supports"
		case conflicts
		case successors = "replaced-by"
		case resources
		case kind
		case equivalents = "provides"
		case archiveSize = "download_size"
		case archiveHash = "download_hash"
		case fileType = "download_content_type"
	}
}
