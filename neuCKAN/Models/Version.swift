//
//  Version.swift
//  neuCKAN
//
//  Created by you on 20-07-02.
//  Copyleft © 2020 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import Foundation

///	A version type capable of representing the abstract extremities.
///
///	This is equivalent to a unified representation of the ["spec\_version"]["spec\_version" attribute], ["version"]["version" attribute], ["ksp\_version"]["ksp\_version" attribute], ["ksp\_version\_min"]["ksp\_version\_min" attribute], ["ksp\_version\_max"]["ksp\_version\_max" attribute], and ["ksp\_version\_strict"]["ksp\_version\_strict" attribute] attributes in a `.ckan` file.
///
///	When comparing two versions, the compiler synthesizes the comparison order that `.infinitesimal` \< `.ordinal` \< `.infinity`. When both versions are `.ordinal`, they are compared by their associated values: first the `epoch` of each are compared, then the `quasiSemanticVersion` if epoch is equal.The epoches are compared numerically; the quasi-semantic version is compared lexicographically precedingly. For more details, check `OrdinalVersion`'s `Comparable` conformance in the source code.
///
///	- Important: Special treatments apply to the `"any"` value and the `"ksp_version"` attribute:
///	  - The `"any"` value is decoded as `Version.infinitesimal...Version.infinity` directly.
///	  - The `"ksp_version"` attribute is frst decoded as a `Version` instance, then coverted to the smallest open range. For example, the key-value pair `"ksp_version": "69.42"` becomes `Version("69.42")..<Version("69.43")`.
///
///	["spec\_version" attribute]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#spec_version
///	["version" attribute]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#version
///	["ksp\_version" attribute]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#ksp_version
///	["ksp\_version\_min" attribute]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#ksp_version_min
///	["ksp\_version\_max" attribute]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#ksp_version_max
///	["ksp\_version\_strict" attribute]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#ksp_version_strict
///
///	[CKAN's version ordering algorithm]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#version-ordering
enum Version: Hashable {
	/// Instanciates an ordinal version from the given version string.
	///	- Parameter versionString: The version string as defined by the CKAN metadata specification.
	/// - Throws: A `VersionError` instance.
	init(_ versionString: String) throws {
		self = .ordinal(version: try OrdinalVersion(versionString))
	}
	///	A theoretical version before even the earliest version, given the assumption that there is no version `0.0.0`.
	///
	///	A version range that starts with this version denotes perfect backward-compatibility.
	case infinitesimal
	///	An actual version number that a mod uses for versioning releases.
	///
	///	An ordinal version number is comparable, and always resides between the infinitesimal and infinity versions. It differs from the mathematical sense of ordinality.
	case ordinal(version: OrdinalVersion)
	///	The theoretically latest version.
	///
	///	A version range that ends with this version denotes perfect forward-compatibility.
	case infinity
}

//	MARK: - Codable Conformance
extension Version: Codable {
	
	/// Initialises a `Version` instance by decoding from the given `decoder`.
	/// - Parameter decoder: The decoder to read data from.
	/// - Throws: A `DecodingError` or `VersionError` instance.
	init(from decoder: Decoder) throws {
		self = .ordinal(version: try decoder.singleValueContainer().decode(OrdinalVersion.self))
	}
	
	/// Encodes a `Version` instance`.
	/// - Parameter encoder: The encoder to encode data to.
	/// - Throws: `EncodingError.invalidValue`.
	func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		switch self {
		case let .ordinal(version: ordinalVersion):
			try container.encode(ordinalVersion)
		default:
			throw EncodingError.invalidValue(self, .init(codingPath: encoder.codingPath, debugDescription: "Only the '.ordinal' case can be encoded as a 'Version' instance. All other cases must be encoded as 'Range<Version>' instances."))
		}
	}
}

//	MARK: - Comparable Conformance
extension Version: Comparable {}

//	MARK: - CustomStringConvertible Conformance
extension Version: CustomStringConvertible {
	///	A textual representation of the version.
	var description: String {
		switch self {
		case .infinitesimal:
			return "0"
		case .ordinal(version: let ordinalVersion):
			return String(describing: ordinalVersion)
		case .infinity:
			return "∞"
		}
	}
}
