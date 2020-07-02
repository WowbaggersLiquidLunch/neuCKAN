//
//	OrdinalVersion.swift
//	neuCKAN
//
//	Created by you on 19-11-05.
//	Copyleft © 2019 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import Foundation

///	An ordinal version consisting of an epoch, a quasi-semantic versioning sequence, a release annotation, and a metadata annotation.
///
///	This is equivalent to a unified representation of the ["spec\_version"]["spec\_version" attribute], ["version"]["version" attribute], ["ksp\_version"]["ksp\_version" attribute], ["ksp\_version\_min"]["ksp\_version\_min" attribute], ["ksp\_version\_max"]["ksp\_version\_max" attribute], and ["ksp\_version\_strict"]["ksp\_version\_strict" attribute] attributes in a `.ckan` file.
///
///	When comparing two ordinal version numbers, first the `epoch` of each are compared, then the `quasiSemanticVersion` if epoches are equal. The epoches are compared numerically; the quasi-semantic version is compared lexicographically precedingly. For more details, check `OrdinalVersion`'s `Comparable` conformance in the source code.
///
///	- Important: Special treatments apply to the `"any"` value and the `"ksp_version_strict"` attribute:
///	  - The `"any"` value is decoded as `Version.infinitesimal...Version.infinity` directly.
///	  - The `"ksp_version"` attribute is frst decoded as a `Version` instance, then coverted to the smallest open range. For example, the key-value pair `"ksp_version": "69.42"` becomes `Version("69.42")..<Version("69.43")`.
///
///	["spec\_version" attribute]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#spec_version
///	["version" attribute]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#version
///	["ksp\_version" attribute]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#ksp_version
///	["ksp\_version\_min" attribute]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#ksp_version_min
///	["ksp\_version\_max" attribute]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#ksp_version_max
///	["ksp\_version\_strict" attribute]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#ksp_version_strict
///	[CKAN's version ordering algorithm]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#version-ordering
struct OrdinalVersion: Hashable {
	
	//	MARK: Policies
	
	///	An array of alternating strings and integers.
	///
	///	An instance of this type represents the entirety or a part of the ordinal version compoent separated by dots.
	typealias QuasiSemanticVersionSegment = [MinimalComparableUnit]
	
	///	A labeled tuple of ordinal version components.
	private typealias OrdinalVersionComponents = (
		epoch: Int?,
		quasiSemanticVersion: [QuasiSemanticVersionSegment],
		releaseSuffix: String?,
		metadataSuffix: String?
	)
	
	//	MARK: - Initialisers
	
	/// Instanciates an ordinal version from the given version string.
	/// - Parameter versionString: The version string as defined by the CKAN metadata specification.
	/// - Throws: A `VersionError` instance.
	init(_ versionString: String) throws {
		assert(versionString != "any", "'any' versions require special handling, and shouldn't be passed in 'OrdinalVersion.init_)'")
		guard !versionString.isEmpty else {
			throw VersionError.stringEmpty
		}
		originalString = versionString
		(epoch, quasiSemanticVersion, releaseSuffix, metadataSuffix) = try Self.deconstruct(from: versionString)
	}
	
	/// Instanciates an ordinal version from its individual and unprocessed components.
	/// - Parameters:
	///   - epoch: The version's epoch, a fail-safe insurance to the versioning sequence..
	///   - quasiSemanticVersionString: The mandatory quasi-semantic version component that serves as the primary versioning information.
	///   - releaseSuffix: The version's release suffix.
	///   - metadataSuffix: The version's metadata suffix.
	/// - Throws: A `VersionError` instance.
	init(
		epoch: Int?,
		quasiSemanticVersionString: String,
		releaseSuffix: String?,
		metadataSuffix: String?
	) throws {
		//	Catch the error before deconstruct(from:) does. deconstruct(from:) won't have enough information to reconstuct the full version string.
		guard !quasiSemanticVersionString.isEmpty else {
			//	Reconstruct the version string as it would appear in a CKAN metadata file, so as to give the error thrown a context.
			var reconstructedVersionString = ""
			if let epoch = epoch { reconstructedVersionString += "\(epoch): " }
			if let releaseSuffix = releaseSuffix { reconstructedVersionString += "-\(releaseSuffix)" }
			if let metadataSuffix = metadataSuffix { reconstructedVersionString += "+\(metadataSuffix)" }
			throw VersionError.quasiSemanticVersionNotFound(versionString: reconstructedVersionString)
		}
		try self.init(
			ordinalVersionComponents: (
				epoch: epoch,
				quasiSemanticVersion: try Self.deconstruct(from: quasiSemanticVersionString).quasiSemanticVersion,	//	Use deconstruct(from:) here because quasiSemanticVersionString can be considered as a version string without epoch, release suffix, and metadata suffix.
				releaseSuffix: releaseSuffix,
				metadataSuffix: metadataSuffix
			)
		)
	}
	
	/// Instanciates an ordinal version from its grouped and processed components.
	/// - Parameter ordinalVersionComponents: The ordinal version's components.
	/// - Throws: A `VersionError` instance.
	private init(ordinalVersionComponents: OrdinalVersionComponents) throws {
		var reconstructedVersionString = ""
		
		if let epoch = ordinalVersionComponents.epoch {
			reconstructedVersionString += "\(epoch): "
		}
		
		reconstructedVersionString += ordinalVersionComponents.quasiSemanticVersion.map { quasiSemanticVersionSegment in
			quasiSemanticVersionSegment.map { minimalComparableUnit in
				String(describing: minimalComparableUnit)
			} .joined()
		} .joined(separator: ".")
		
		if let releaseSuffix = ordinalVersionComponents.releaseSuffix {
			reconstructedVersionString += "-\(releaseSuffix)"
		}
		
		if let metadataSuffix = ordinalVersionComponents.metadataSuffix {
			reconstructedVersionString += "+\(metadataSuffix)"
		}
		
		guard !ordinalVersionComponents.quasiSemanticVersion.isEmpty else {
			throw VersionError.quasiSemanticVersionNotFound(versionString: reconstructedVersionString)
		}
		
		self.originalString = reconstructedVersionString
		(self.epoch, self.quasiSemanticVersion, self.releaseSuffix, self.metadataSuffix) = ordinalVersionComponents
	}
	
	//	Initialisation from numbers is disabled, incompliance with the CKAN metadata specification.
	//	///	Instanciate an ordinal version instance from the given version number.
	//	///
	//	///	This initialiser takes care of CKAN metadata files that do not respect the current specification, and use numbers for versions.
	//	///
	//	///	- Parameter versionDigits: The version number that doesn't abide in form by the CKAN metadata specification.
	//	init(_ versionDigits: Double) {
	//		//	Create a string representation of the digits, and remove trailing 0s.
	//		self.init(String(format: "%f", versionDigits).replacingOccurrences(of: "\\.*0+$", with: "", options: .regularExpression))
	//	}
	
	//	MARK: - Instance Properties
	
	///	The original version string verbatim from the .ckan file.
	let originalString: String
	
	///	The fail-safe insurance to the versioning sequence.
	///
	///	`epoch` is a single (generally small) integer. It may be omitted, in which case zero is assumed. CKAN provides it to allow mistakes in the version numbers of older versions of a package, and also a package's previous version numbering schemes, to be left behind.
	///
	///	- Note: The purpose of epochs is to allow CKAN to leave behind mistakes in version numbering, and to cope with situations where the version numbering scheme changes. It is not intended to cope with version numbers containing strings of letters which the package management system cannot interpret (such as ALPHA or pre-), or with silly orderings.
	private let epoch: Int?
	
	///	The primary versioning sequence.
	///
	///	This is equivalent to the ["mod_version" attribute][mod version] in a .ckan file.
	///
	///	`quasiSemanticVersion` is the main part of the version number. In application to mods, it is usually the version number of the original mod from which the CKAN file is created. Usually this will be in the same format as that specified by the mod author(s); however, it may need to be reformatted to fit into the package management system's format and comparison scheme.
	///
	///	[mod version]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#ksp_version_max
	private let quasiSemanticVersion: [QuasiSemanticVersionSegment]
	
	///	The release version suffix.
	///
	///	This is mostly used for denoting a pre-release version. The string follows a `"-"`, and is composed of alphsnumerical characters and `"."`, such as `"alpha"`, `"1337"`, or practically anything. For more information, see [semantic versioning][0]
	///
	///	[0]: https://semver.org/#spec-item-9
	private let releaseSuffix: String?
	
	///	The metadata suffix.
	///
	///	The string follows a `"+"`, and is composed of alphsnumerical characters and `"."`, such as `"alpha"`, `"1337"`, or practically anything. For more information, see [semantic versioning][0]
	///
	///	[0]: https://semver.org/#spec-item-10
	let metadataSuffix: String?
	
	//	MARK: - Nested Types
	
	///	The smallest comparable unit in CKAN's version comparison algorithm.
	///
	///	CKAN metadata specification [specifies][version ordering] that each contiguous chunk of non-numeric or numeric characters in a version string should be evaluated collectively.
	///
	///	- See Also: `QuasiSemanticVersionSegment`
	///
	///	[version ordering]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#version-ordering
	enum MinimalComparableUnit: Hashable {
		case numerical(UInt)
		case nonNumerical(String)
	}
	
	//	MARK: - Static Methods
	
	/// Extracts the epoch, quasi-semantic version, release suffix, and metadata suffix components from the given complete ordinal version string.
	/// - Parameter versionString: The complete ordinal version string to deconstruct.
	/// - Returns: The ordinal version's components.
	/// - Throws: A `VersionError` instance.
	private static func deconstruct(from versionString: String) throws -> OrdinalVersionComponents {
		//	Split the version string into its components by their distinctive markers ":", "+", and "-" before processing them.
		let versionStringSplitByColons: [Substring] = versionString.split(separator: ":")
		let versionStringRemainderSplitByPluses: [Substring] = versionStringSplitByColons.last?.split(separator: "+") ?? []
		let versionStringRemainderSplitByMinuses: [Substring] = versionStringRemainderSplitByPluses.first?.split(separator: "-") ?? []	//	technically hyphen-minus
		let versionStringRemainderSplitByDots: [Substring] = versionStringRemainderSplitByMinuses.first?.split(separator: ".") ?? []
		
		//	The quasi-semantic version component cannot be empty.
		//	In practice, all version-related operations (e.g. version comparison) will do just fine without it, even if the entire original version string is empty. However, CKAN metadata specification implicitly demands a non-empty value for the quasi-semantic version. Thus, for the sake of specification-compliance and maintining a consistent behaviour across all CKAN client, version strings without the quasi-semantic version component are disallowed.
		guard !versionStringRemainderSplitByDots.isEmpty else {
			throw VersionError.quasiSemanticVersionNotFound(versionString: versionString)
		}
		
		//	TODO: Refactor getNonNumericalLeadingCluster(from:) and getNumericalLeadingCluster(from:); DRY.
		//	TODO: Replace ~= (pattern:value:) with .contains(_:).
		//	TODO: Find ways to instanciate UInt derectly using Substring.
		
		//	Both nonNumericalLeadingComparableUnits(of:) and numericalLeadingComparableUnits(of:) use substrings heavily for time, memory, and energy efficiency.
		
		/// Parses a non-numerical characters-leading ordinal version segments cluster from the given partial version string.
		/// - Parameter versionSegmentSubString: The partial version string to parse.
		/// - Returns: A non-numerical characters-leading ordinal version segments.
		/// - Throws: `VersionError.minimalComparableUnitOversize`.
		func nonNumericalLeadingComparableUnits(of versionSegmentSubString: String) throws -> QuasiSemanticVersionSegment {
			var versionSegment: QuasiSemanticVersionSegment = []
			let nextComparableUnit = versionSegmentSubString.prefix(while: { !("0"..."9" ~= $0) } )
			let remainingVersionSegmentSubString = versionSegmentSubString.suffix(from: nextComparableUnit.endIndex)
			versionSegment.append(MinimalComparableUnit.nonNumerical(String(nextComparableUnit)))
			if !remainingVersionSegmentSubString.isEmpty {
				versionSegment.append(contentsOf: try numericalLeadingComparableUnits(of: String(remainingVersionSegmentSubString)))
			}
			return versionSegment
		}
		
		/// Parses a numerical characters-leading ordinal version segments cluster from the given partial version string.
		/// - Parameter versionSegmentSubString: The partial version string to parse.
		/// - Returns: A numerical characters-leading ordinal version segments.
		/// - Throws: `VersionError.minimalComparableUnitOversize`.
		func numericalLeadingComparableUnits(of versionSegmentSubString: String) throws -> QuasiSemanticVersionSegment {
			var versionSegment: QuasiSemanticVersionSegment = []
			let nextComparableUnit = versionSegmentSubString.prefix(while: { "0"..."9" ~= $0 } )
			let remainingVersionSegmentSubString = versionSegmentSubString.suffix(from: nextComparableUnit.endIndex)
			let nextComparableUnitString = String(nextComparableUnit)
			//	The project's CKAN metadata-parsing logic ensures that, at this point, integer overflow is the only possible cause for failure of unsigned integer initialisation from string.
			guard let nextNumericalComparableUnit = UInt(nextComparableUnitString) else {
				throw VersionError.minimalComparableUnitOversize(comparableUnitString: nextComparableUnitString, versionString: versionString)
			}
			versionSegment.append(MinimalComparableUnit.numerical(nextNumericalComparableUnit))
			if !remainingVersionSegmentSubString.isEmpty {
				versionSegment.append(contentsOf: try nonNumericalLeadingComparableUnits(of: String(remainingVersionSegmentSubString)))
			}
			return versionSegment
		}
		
		return (
			epoch: versionStringSplitByColons.count > 1 ? Int(versionStringSplitByColons[0]) : nil,
			quasiSemanticVersion: try versionStringRemainderSplitByDots.map { try nonNumericalLeadingComparableUnits(of: String($0)) },
			releaseSuffix: versionStringRemainderSplitByMinuses.count > 1 ? String(versionStringRemainderSplitByMinuses.last!) : nil,
			metadataSuffix: versionStringRemainderSplitByPluses.count > 1 ? String(versionStringRemainderSplitByPluses.last!) : nil
		)
	}
}

//	MARK: - Codable Conformance
extension OrdinalVersion: Codable {
	
	/// Initialises a `OrdinalVersion` instance by decoding from the given `decoder`.
	/// - Parameter decoder: The decoder to read data from.
	/// - Throws: A `DecodingError` or `VersionError` instance.
	init(from decoder: Decoder) throws {
		let versionString = try decoder.singleValueContainer().decode(String.self)
		self = try Self(versionString)
	}
	
	/// Encodes a `OrdinalVersion` instance`.
	/// - Parameter encoder: The encoder to encode data to.
	/// - Throws: An `EncodingError` instance, which shouldn't happen.
	func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(originalString)
	}
}

//	MARK: - Comparable Conformance
extension OrdinalVersion: Comparable {
	//	Compares ordinal verisons exactly how the CKAN metadata specification wants it, but with a twist (perhaps better) by favoring semantic versioning when in face of ambiguity.
	static func < (lhs: Self, rhs: Self) -> Bool {
		//	TODO: Replace if-else with switch-case.
		if let lhsEpoch = lhs.epoch, let rhsEpoch = rhs.epoch {
			//	Compare epoches, if present.
			return lhsEpoch < rhsEpoch
		} else {
			//	Compare the rest, if without epoches.
			if lhs.quasiSemanticVersion != rhs.quasiSemanticVersion {
				//	Compare the quasi-semantic components, if they are not equal.
				return lhs.quasiSemanticVersion.lexicographicallyPrecedes(rhs.quasiSemanticVersion)
			} else {
				//	If the quasi-semantic components are equal, check the release suffixes.
				if let lhsReleaseSuffix = lhs.releaseSuffix, let rhsReleaseSuffix = rhs.releaseSuffix, lhsReleaseSuffix != rhsReleaseSuffix {
					//	Compare the release suffixes, if they are present and unequal.
					return lhsReleaseSuffix < rhsReleaseSuffix
				} else if lhs.releaseSuffix == nil && rhs.releaseSuffix != nil {
					//	Left-hand side > right-hand side, if left-hand side has no release suffix but right-hand side does.
					return false
				} else if lhs.releaseSuffix != nil && rhs.releaseSuffix == nil {
					//	Left-hand side < right-hand side, if left-hand side has release suffix but right-hand side doesn't.
					return true
				} else {
					//	As the last resort, compare the original version strings directly.
					return lhs.originalString < rhs.originalString
				}
			}
		}
	}
}

extension OrdinalVersion.QuasiSemanticVersionSegment: Comparable {
	public static func < (lhs: Self, rhs: Self) -> Bool {
		lhs.lexicographicallyPrecedes(rhs)
	}
	
	
}

extension OrdinalVersion.MinimalComparableUnit: Comparable {
	//	Swift has synthetic Comparable conformance since version 5.3, so a custom implementation is no longer necessary.
	//	The only caveat is that with the synthetic Comparable conformance, all .numerical cases now precede .nonNumerical cases. This behaviour is not necessarily bad, but it's not necessarily good either. It's just something to note here, and to keep in mind of.
	//	static func < (lhs: Self, rhs: Self) -> Bool {
	//		switch (lhs, rhs) {
	//		case (.numerical(let lhs), .numerical(let rhs)):
	//			return lhs < rhs
	//		case (.nonNumerical(let lhs), .nonNumerical(let rhs)):
	//			return lhs < rhs
	//		default:
	//	//	This line is faulty. It could inadvertently result in a never-ending comparison.
	//			return false
	//		}
	//	}
}

//	MARK: - Collection Conformance
extension OrdinalVersion: Collection {
	
	typealias Index = Array<QuasiSemanticVersionSegment>.Index
	
	///	The position of the first dot-separated segment in a nonempty version.
	///
	///	If the version is empty, `startIndex` is equal to `endIndex`.
	var startIndex: Index { quasiSemanticVersion.startIndex }
	
	///	The version’s “past the end” position—i.e. the position one greater than the last valid subscript argument.
	///
	///	When you need a range that includes the last dot-separated segment of the version, use the half-open range operator (`..<`) with `endIndex`. The `..<` operator creates a range that doesn’t include the upper bound, so it’s always safe to use with `endIndex`.
	///
	///	If the version is empty, `endIndex` is equal to `startIndex`.
	var endIndex: Index { quasiSemanticVersion.endIndex }
	
	///	Returns the position immediately after the given index.
	///
	///	- Parameter position: A valid index of the version. `i` must be less than `endIndex`.
	///	- Returns: The index value immediately after `i.`
	func index(after i: Index) -> Index { quasiSemanticVersion.index(after: i) }
	
	///	Accesses the version segment string at the specified position.
	///
	///	This subscript provides read-only access.
	///
	///	- Parameter position: The position of the version segment to access. `position` must be a valid index of the version that is not equal to the `endIndex` property.
	///	- Returns: The version segment string at the specified index.
	subscript(position: Index) -> String { quasiSemanticVersion[position].description }
	
	///	Accesses the version string of the specified range.
	///	- Parameter bounds: The range of the version segments to access.
	///	- Returns: The version string of the specified range.
	subscript(bounds: Range<Index>) -> String { bounds.map { self[$0] }.joined(separator: ".") }
	
	///	Accesses the version string of the specified range in the given range expression.
	///	- Parameter r: The range expression describing the range of the version segments to access.
	///	- Returns: The version string of the specified range.
	subscript<R>(r: R) -> String where R : RangeExpression, R.Bound == Index { self[r.relative(to: self)] }
}

////	MARK: - ExpressibleByStringLiteral Conformance
//extension OrdinalVersion: ExpressibleByStringLiteral {
//	init(stringLiteral value: String) {
//		self.init(value)
//	}
//}
//
////	MARK: ExpressibleByExtendedGraphemeClusterLiteral Conformance
//extension OrdinalVersion: ExpressibleByExtendedGraphemeClusterLiteral {
//	public init(extendedGraphemeClusterLiteral value: String) {
//		self.init(stringLiteral: value)
//	}
//}
//
////	MARK: ExpressibleByUnicodeScalarLiteral Conformance
//extension OrdinalVersion: ExpressibleByUnicodeScalarLiteral {
//	public init(unicodeScalarLiteral value: String) {
//		self.init(stringLiteral: value)
//	}
//}

//	MARK: - CustomStringConvertible Conformance
extension OrdinalVersion: CustomStringConvertible {
	///	A textual representation of the ordinal version.
	var description: String {
		var quasiSemanticVersionString = quasiSemanticVersion.map { quasiSemanticVersionSegment in
			quasiSemanticVersionSegment.map { minimalComparableUnit in
				String(describing: minimalComparableUnit)
			}
			.joined()
		}
		.joined(separator: ".")
		if quasiSemanticVersionString.first == "v" {
			quasiSemanticVersionString.removeFirst()
		}
		return quasiSemanticVersionString
	}
}

//	FIXME: Fix String(describing: QuasiSemanticVersionSegment).
//extension OrdinalVersion.QuasiSemanticVersionSegment: CustomStringConvertible {
//	///	A textual representation of the version segment.
//	var description: String { self.map { String(describing: $0) }.joined() }
//}

extension OrdinalVersion.MinimalComparableUnit: CustomStringConvertible {
	///	A textual representation of the lowest, indivisible comparable unit.
	var description: String {
		switch self {
		case .nonNumerical(let string):
			return string
		case .numerical(let number):
			return String(number)
		}
	}
}

//	TODO: Add LosslessStringConvertible conformance.
//	MARK: - LosslessStringConvertible Conformance
//extension OrdinalVersion.QuasiSemanticVersionSegment: LosslessStringConvertible {
//
//}
//
//extension OrdinalVersion.MinimalComparableUnit: LosslessStringConvertible {
//
//}
