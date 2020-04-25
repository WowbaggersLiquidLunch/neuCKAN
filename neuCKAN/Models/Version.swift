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
	init(_ versionString: String) {
		let finalVersionString = versionString == "any" ? Version.universallyCompatibleVersionString : versionString
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
	init(_ versionDigits: Double) {
		//	Create a string representation of the digits, and remove trailing 0s.
		self.init(String(format: "%f", versionDigits).replacingOccurrences(of: "\\.*0+$", with: "", options: .regularExpression))
	}
	
	//	TODO: Find a better name for universallyCompatibleVersionString.
	/**
	A nerdy and mathematically incorrect expression for CKAN metadata's `"any"` version.
	*/
	static private let universallyCompatibleVersionString: String = "∀x∈ℍ.∀x∈ℍ.∀x∈ℍ"
	
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
	
	- See Also: `CKANVersionMinimalComparableUnit`
	*/
	private typealias VersionSegment = [CKANVersionMinimalComparableUnit]
	
	/**
	The smallest comparable unit in CKAN metadata's `"mod_version"` attribute.
	
	CKAN metadata specification [specifies][version ordering] that each contiguous chunk of non-numeric or numeric characters in a version string should be evaluated collectively.
	
	- See Also: `VersionSegment`
	
	[version ordering]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#version-ordering
	*/
	fileprivate enum CKANVersionMinimalComparableUnit: Hashable, Comparable {
		case numerical(Int)
		case nonNumerical(String)
		
		//	Comparable conformance
		static func < (lhs: Version.CKANVersionMinimalComparableUnit, rhs: Version.CKANVersionMinimalComparableUnit) -> Bool {
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
		let versionStringSplitByColons: [Substring] = versionString.split(separator: ":")
		let versionStringRemainSplitByPluses: [Substring] = versionStringSplitByColons.last?.split(separator: "+") ?? []
		let versionStringRemainSplitByMinuses: [Substring] = versionStringRemainSplitByPluses.first?.split(separator: "-") ?? []	//	technically hyphen-minus
		let versionStringRemainSplitByDots: [Substring] = versionStringRemainSplitByMinuses.first?.split(separator: ".") ?? []
		
		//	TODO: Refactor getNonNumericalLeadingCluster(from:) and getNumericalLeadingCluster(from:); DRY.
		
		/**
		Returns a non-numerical characters-leading version segments cluster parsed from the given version string.
		*/
		func nonNumericalLeadingComparableUnits(of versionSegmentSubString: String) -> VersionSegment {
			var versionSegment: VersionSegment = []
			let nextComparableUnit = versionSegmentSubString.prefix(while: { !("0"..."9" ~= $0) } )
			let remainingVersionSegmentSubString = versionSegmentSubString.suffix(from: nextComparableUnit.endIndex)
			versionSegment.append(CKANVersionMinimalComparableUnit.nonNumerical(String(nextComparableUnit)))
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
			let nextComparableUnit = versionSegmentSubString.prefix(while: { ("0"..."9" ~= $0) } )
			let remainingVersionSegmentSubString = versionSegmentSubString.suffix(from: nextComparableUnit.endIndex)
			versionSegment.append(CKANVersionMinimalComparableUnit.numerical(Int(String(nextComparableUnit))!))
			if !remainingVersionSegmentSubString.isEmpty {
				versionSegment.append(contentsOf: nonNumericalLeadingComparableUnits(of: String(remainingVersionSegmentSubString)))
			}
			return versionSegment
		}
		
		let epoch: Int? = versionStringSplitByColons.count > 1 ? Int(versionStringSplitByColons[0]) : nil
		let metadataSuffix: String? = versionStringRemainSplitByPluses.count > 1 ? String(versionStringRemainSplitByPluses.last!) : nil
		let releaseSuffix: String? = versionStringRemainSplitByMinuses.count > 1 ? String(versionStringRemainSplitByMinuses.last!) : nil
		let quasiSemanticVersion: [VersionSegment] = versionStringRemainSplitByDots.map { nonNumericalLeadingComparableUnits(of: String($0)) }
		
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
			self = Version(versionString)
		} else if let versionDigits = try? decoder.singleValueContainer().decode(Double.self) {
			self = Version(versionDigits)
		} else {
			self = Version(String.defaultInstance)
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

//	FIXME: Include universallyCompatibleVersionString in comparison.
//	MARK: - Comparable Conformance
extension Version: Comparable {
	//	Compares verisons exactly how the CKAN metadata specification wants it, but better, but favors semantic versioning when in face of ambiguity.
	static func < (lhs: Self, rhs: Self) -> Bool {
//		if universalCompatibilityExistsIn(lhs, rhs) {
//			return true
//		}
		if let lhsEpoch = lhs.epoch, let rhsEpoch = rhs.epoch {
			return lhsEpoch < rhsEpoch
		} else {
			if lhs.quasiSemanticVersion == rhs.quasiSemanticVersion {
				if let lhsReleaseSuffix = lhs.releaseSuffix, let rhsReleaseSuffix = rhs.releaseSuffix, lhsReleaseSuffix != rhsReleaseSuffix {
					return lhsReleaseSuffix < rhsReleaseSuffix
				} else {
					return lhs.originalString < rhs.originalString
				}
			} else {
				//	FIXME: Add Comparable conformance to VersionSegment.
				return lhs.quasiSemanticVersion.lexicographicallyPrecedes(rhs.quasiSemanticVersion, by: { lhsVersionSegment, rhsVersionSegment in
					lhsVersionSegment.lexicographicallyPrecedes(rhsVersionSegment)
				})
			}
		}
	}
//	static func > (lhs: Self, rhs: Self) -> Bool {
//		return universalCompatibilityExistsIn(lhs, rhs) || rhs < lhs
//	}
//	static func <= (lhs: Self, rhs: Self) -> Bool {
//		return universalCompatibilityExistsIn(lhs, rhs) || !(rhs < lhs)
//	}
//	static func >= (lhs: Self, rhs: Self) -> Bool {
//		return universalCompatibilityExistsIn(lhs, rhs) || !(lhs < rhs)
//	}
//	static func == (lhs: Self, rhs: Self) -> Bool {
//		return lhs >= rhs && lhs <= rhs
//	}
//	static func universalCompatibilityExistsIn(_ lhs: Self, _ rhs: Self) -> Bool {
//		return lhs.originalString == universallyCompatibleVersionString || rhs.originalString == universallyCompatibleVersionString
//	}
}

//	MARK: "Comparable Conformance" for [CKANVersionMinimalComparableUnit]
//	Extends Array, so it knows how to compare 2 CKANVersionMinimalComparableUnit instances.
fileprivate extension Array where Element == Version.CKANVersionMinimalComparableUnit {
	static func < (lhs: [Element], rhs: [Element]) -> Bool {
		for i in 0..<Swift.min(lhs.count, rhs.count) where lhs[i] < rhs[i] {
			return true
		}
		return lhs.count < rhs.count
	}
}

//	MARK: Comparable Conformance for String?
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

//	MARK: - Collection Conformance
extension Version: Collection {
	
	typealias Index = Array<Any>.Index
	
	/**
	The position of the first dot-separated segment in a nonempty version.
	
	If the version is empty, `startIndex` is equal to `endIndex`.
	
	- See Also: `endIndex`.
	*/
	var startIndex: Index { quasiSemanticVersion.startIndex }
	
	/**
	The version’s “past the end” position—i.e. the position one greater than the last valid subscript argument.
	
	When you need a range that includes the last dot-separated segment of the version, use the half-open range operator (`..<`) with `endIndex`. The `..<` operator creates a range that doesn’t include the upper bound, so it’s always safe to use with `endIndex`.
	
	If the version is empty, `endIndex` is equal to `startIndex`.
	
	- See Also: `startIndex`.
	*/
	var endIndex: Index { quasiSemanticVersion.endIndex }
	
	/**
	Returns the position immediately after the given index.
	
	- Parameter position: A valid index of the version. `i` must be less than `endIndex`.
	
	- Returns: The index value immediately after `i.`
	
	- See Also: `endIndex`.
	*/
	func index(after i: Index) -> Index { quasiSemanticVersion.index(after: i) }
	
	/**
	Accesses the version segment string at the specified position.
	
	This subscript provides read-only access.
	
	- Parameter position: The position of the version segment to access. `position` must be a valid index of the version that is not equal to the `endIndex` property.
	
	- Returns: The version segment string at the specified index.
	
	- See Also: `endIndex`.
	*/
	subscript(position: Index) -> String { quasiSemanticVersion[position].description }
	
	/**
	Accesses the version string of the specified range.
	
	- Parameter bounds: The range of the version segments to access.
	
	- Returns: The version string of the specified range.
	*/
	subscript(bounds: Range<Index>) -> String { bounds.map { self[$0] }.joined(separator: ".") }
	
	/**
	Accesses the version string of the specified range in the given range expression.
	
	- Parameter r: The range expression describing the range of the version segments to access.
	
	- Returns: The version string of the specified range.
	*/
	subscript<R>(r: R) -> String where R : RangeExpression, R.Bound == Index { self[r.relative(to: self)] }
}

//	MARK: - ExpressibleByStringLiteral Conformance
extension Version: ExpressibleByStringLiteral {
	init(stringLiteral value: String) {
		self.init(value)
	}
}

//	MARK: ExpressibleByExtendedGraphemeClusterLiteral Conformance
extension Version: ExpressibleByExtendedGraphemeClusterLiteral {
	public init(extendedGraphemeClusterLiteral value: String) {
		self.init(stringLiteral: value)
	}
}

//	MARK: - CustomStringConvertible Conformance
extension Version: CustomStringConvertible {
	///	A textual representation of the version.
	var description: String { String(originalString.split(separator: ":").last!.split(separator: "-").first!) }
}

//	FIXME: Fix String(describing: VersionSegment).
fileprivate extension Array where Element == Version.CKANVersionMinimalComparableUnit {
	///	A textual representation of the version segment.
	var description: String { self.map { String(describing: $0) }.joined() }
}

extension Version.CKANVersionMinimalComparableUnit: CustomStringConvertible {
	///	A textual representation of the smallest comparable unit.
	var description: String {
		switch self {
		case .nonNumerical(let string):
			return string
		case .numerical(let number):
			return String(number)
		}
	}
}
