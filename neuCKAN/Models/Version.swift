//
//	Version.swift
//	neuCKAN
//
//	Created by you on 19-11-05.
//	Copyleft © 2019 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import Foundation

/**
A version type containing both an epoch and a semantic versioning sequence.

This is equivalent to the ["version" attribute][0] in a .ckan file.

It translates a .ckan file's `"[epoch:]version"` version string into a `epoch` constant of `Int?` type, and an `version` constant of `[Int]` type.

When comparing two version numbers, first the `epoch` of each are compared, then the `version` if epoch is equal. epoch is compared numerically. The `version` is compared in sequence of its elements.

[0]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#version
*/
struct Version: Hashable {
	
	/**
	Initialises a `Version` instance from the given version string.
	
	- Parameter versionString: The version string as defined by the CKAN metadata specification.
	*/
	init(from versionString: String) {
		let finalVersionString = versionString == "any" ? Version.versionlessVersionString : versionString
		self.originalString = finalVersionString
		let deconstructedVersion = Version.deconstruct(from: finalVersionString)
		self.epoch = deconstructedVersion.epoch
		self.quasiSemanticVersion = deconstructedVersion.quasiSemanticVersion
		self.releaseSuffix = deconstructedVersion.releaseSuffix
		self.metadataSuffix = deconstructedVersion.metadataSuffix
	}
	
	/**
	Initialises a `Version` instance from the given version number.
	
	This initialiser takes care of CKAN metadata files that do not respect the current specification, and use numbers for versions.
	
	- Parameter versionDigits: The version number that doesn't abide in form by the CKAN metadata specification.
	*/
	init(from versionDigits: Double) {
		//	Create a string representation of the digits, and remove trailing 0s.
		self.init(from: String(format: "%f", versionDigits).replacingOccurrences(of: "\\.*0+$", with: "", options: .regularExpression))
	}
	
	/**
	A nerdy and mathematically incorrect expression for CKAN metadata's `"any"` version.
	*/
	static private let versionlessVersionString: String = "∀x∈ℍ.∀x∈ℍ.∀x∈ℍ"
	
	/**
	The original version string verbatim from the .ckan file.
	*/
	let originalString: String
	
	/**
	The fail-safe insurance to the versioning sequence.
	
	`epoch` is a single (generally small) integer. It may be omitted, in which case zero is assumed. CKAN provides it to allow mistakes in the version numbers of older versions of a package, and also a package's previous version numbering schemes, to be left behind.
	
	- Note: The purpose of epochs is to allow CKAN to leave behind mistakes in version numbering, and to cope with situations where the version numbering scheme changes. It is not intended to cope with version numbers containing strings of letters which the package management system cannot interpret (such as ALPHA or pre-), or with silly orderings.
	*/
	private let epoch: Int?
	
	/**
	The primary versioning sequence.
	
	This is equivalent to the ["mod_version" attribute][mod version] in a .ckan file.
	
	`quasiSemanticVersion` is the main part of the version number. In application to mods, it is usually the version number of the original mod from which the CKAN file is created. Usually this will be in the same format as that specified by the mod author(s); however, it may need to be reformatted to fit into the package management system's format and comparison scheme.
	
	[mod version]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#ksp_version_max
	*/
	private let quasiSemanticVersion: [VersionSegment]
	
	/**
	The release version suffix.
	
	This is mostly used for denoting a pre-release version. The string follows a `"-"`, and is composed of alphsnumerical characters and `"."`, such as `"alpha"`, `"1337"`, or practically anything. For more information, see [semantic versioning][0]
	
	[0]: https://semver.org/#spec-item-9
	*/
	private let releaseSuffix: String?
	
	/**
	The metadata suffix.
	
	The string follows a `"+"`, and is composed of alphsnumerical characters and `"."`, such as `"alpha"`, `"1337"`, or practically anything. For more information, see [semantic versioning][0]
	
	[0]: https://semver.org/#spec-item-10
	*/
	let metadataSuffix: String?
	
	/**
	A series of alternating strings and integers.
	
	An instance of this type represents a part of the content separated by dots in a version string.
	
	- See Also: `CKANVersionSmallestComparableUnit`
	*/
	private typealias VersionSegment = [CKANVersionSmallestComparableUnit]
	
	/**
	The smallest comparable unit in CKAN metadata's `"mod_version"` attribute.
	
	CKAN metadata specification [specifies][version ordering] that each contiguous chunk of non-numeric or numeric characters in a version string should be evaluated collectively.
	
	- See Also: `VersionSegment`
	
	[version ordering]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#version-ordering
	*/
	fileprivate enum CKANVersionSmallestComparableUnit: Hashable, Comparable {
		case numerical(Int)
		case nonNumerical(String)
		
		//	Comparable conformance
		static func < (lhs: Version.CKANVersionSmallestComparableUnit, rhs: Version.CKANVersionSmallestComparableUnit) -> Bool {
			switch (lhs, rhs) {
			case (.numerical(let lhs), .numerical(let rhs)):
				return lhs < rhs
			case (.nonNumerical(let lhs), .nonNumerical(let rhs)):
				return lhs < rhs
			default:
				return false
			}
		}
	}
	
	/**
	Extracts the epoch, quasi-semantic version, release suffix, and metadata suffic parts from the given complete version string.
	*/
	private static func deconstruct(from versionString: String) -> (epoch: Int?, quasiSemanticVersion: [VersionSegment], releaseSuffix: String?, metadataSuffix: String?) {
		//	FIXME: Find a way to use Substrings instead, for efficienccy.
		let versionStringSplitByColons: [String] = versionString.components(separatedBy: ":")
		let versionStringRemainSplitByPluses: [String] = versionStringSplitByColons.last?.components(separatedBy: "+") ?? []
		let versionStringRemainSplitByMinuses: [String] = versionStringRemainSplitByPluses.first?.components(separatedBy: "-") ?? []
		let versionStringRemainSplitByDots: [String] = versionStringRemainSplitByMinuses.first?.components(separatedBy: ".") ?? []
		
		//	TODO: Refactor getNonNumericalLeadingCluster(from:) and getNumericalLeadingCluster(from:); DRY.
		
		/**
		Returns a non-numerical characters-leading version segments cluster parsed from the given version string.
		*/
		func nonNumericalLeadingComparableUnits(of versionSegmentSubString: String) -> VersionSegment {
			var versionSegment: VersionSegment = []
			let nextComparableUnit = versionSegmentSubString.prefix(while: { !("0"..."9" ~= $0) })
			let remainingVersionSegmentSubString = versionSegmentSubString.suffix(from: nextComparableUnit.endIndex)
			versionSegment.append(CKANVersionSmallestComparableUnit.nonNumerical(String(nextComparableUnit)))
			if !remainingVersionSegmentSubString.isEmpty {
				versionSegment.append(contentsOf: numericalLeadingComparableUnits(of: String(remainingVersionSegmentSubString)))
			}
			return versionSegment
		}
		
		/**
		Returns a numerical characters-leading version segments cluster parsed from the given version string.
		*/
		func numericalLeadingComparableUnits(of versionSegmentSubString: String) -> VersionSegment {
			var versionSegment: VersionSegment = []
			let nextComparableUnit = versionSegmentSubString.prefix(while: { ("0"..."9" ~= $0) })
			let remainingVersionSegmentSubString = versionSegmentSubString.suffix(from: nextComparableUnit.endIndex)
			versionSegment.append(CKANVersionSmallestComparableUnit.numerical(Int(String(nextComparableUnit))!))
			if !remainingVersionSegmentSubString.isEmpty {
				versionSegment.append(contentsOf: nonNumericalLeadingComparableUnits(of: String(remainingVersionSegmentSubString)))
			}
			return versionSegment
		}
		
		let epoch: Int? = versionStringSplitByColons.count > 1 ? Int(versionStringSplitByColons[0]) : nil
		let metadataSuffix: String? = versionStringRemainSplitByPluses.count > 1 ? versionStringRemainSplitByPluses.last : nil
		let releaseSuffix: String? = versionStringRemainSplitByMinuses.count > 1 ? versionStringRemainSplitByMinuses.last : nil
		let quasiSemanticVersion: [VersionSegment] = versionStringRemainSplitByDots.map { nonNumericalLeadingComparableUnits(of: $0) }
		
		return (epoch: epoch, quasiSemanticVersion: quasiSemanticVersion, releaseSuffix: releaseSuffix, metadataSuffix: metadataSuffix)
	}
}

//	MARK: - Codable Conformance
extension Version: Codable {

	/**
	Initialises a `Version` instance by decoding from the given `decoder`.
	
	- Parameter decoder: The decoder to read data from.
	*/
	init(from decoder: Decoder) throws {
		if let versionString = try? decoder.singleValueContainer().decode(String.self) {
			self = Version(from: versionString)
		} else if let versionDigits = try? decoder.singleValueContainer().decode(Double.self) {
			self = Version(from: versionDigits)
		} else {
			self = Version(from: String.defaultInstance)
		}
	}
	
	/**
	Encodes a `Version` instance`.
	
	- Parameter encoder: The encoder to encode data to.
	*/
	func encode(to encoder: Encoder) throws {
		var encoder = encoder.singleValueContainer()
		try encoder.encode(originalString)
	}
}

//	MARK: - Comparable Conformance
extension Version: Comparable {
	//	Compares verisons exactly how the CKAN metadata specification wants it, but better, but favors semantic versioning when in face of ambiguity.
	static func < (lhs: Version, rhs: Version) -> Bool {
		if let lhs = lhs.epoch, let rhs = rhs.epoch {
			return lhs < rhs
		} else {
			for i in 0..<min(lhs.quasiSemanticVersion.count, rhs.quasiSemanticVersion.count) {
				if lhs.quasiSemanticVersion[i] != rhs.quasiSemanticVersion[i] {
					return lhs.quasiSemanticVersion[i] < rhs.quasiSemanticVersion[i]
				}
			}
			if lhs.quasiSemanticVersion.count == rhs.quasiSemanticVersion.count {
				if let lhs = lhs.releaseSuffix, let rhs = rhs.releaseSuffix {
					return lhs < rhs
				} else {
					return lhs.originalString < rhs.originalString
				}
			} else {
				return lhs.quasiSemanticVersion.count < rhs.quasiSemanticVersion.count
			}
		}
	}
}

//	Extends Array, so it knows how to compare 2 CKANVersionSmallestComparableUnit instances.
fileprivate extension Array where Element == Version.CKANVersionSmallestComparableUnit {
	static func < (lhs: [Element], rhs: [Element]) -> Bool {
		for i in 0..<Swift.min(lhs.count, rhs.count) {
			if lhs[i] < rhs[i] {
				return true
			}
		}
		return lhs.count < rhs.count
	}
}

//	Extendes Optional for String? comparison.
extension Optional: Comparable where Wrapped == String {
	public static func < (lhs: Optional<Wrapped>, rhs: Optional<Wrapped>) -> Bool {
		if let lhs = lhs {
			if let rhs = rhs {
				return lhs < rhs
			} else {
				return false
			}
		} else {
			return rhs != nil
		}
	}
}
