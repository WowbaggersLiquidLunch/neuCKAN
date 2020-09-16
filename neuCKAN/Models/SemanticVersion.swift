//
//	SemanticVersion.swift
//	neuCKAN
//
//	Created by you on 20-09-15.
//	Copyleft © 2020 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import os.log
import Interval

///	A version according to the semantic versioning specification.
///
///	A semantic version consists of three period-separated integers, e.g. `1.0.0`. The semantic versioning specification proposes a set of rules and requirements that dictate how version numbers are assigned and incremented. To learn more about the semantic versioning specification, visit [semver.org](www.semver.org).
///
///	**The Major Version**
///
///	The first digit of a version, or  _major version_, signifies breaking changes to the API that require updates to existing clients. For example, the semantic versioning specification considers renaming an existing type, removing a method, or changing a method's signature breaking changes. This also includes any backward-incompatible bug fixes or behavioral changes of the existing API.
///
///	**The Minor Version**
///
///	Update the second digit of a version, or _minor version_, if you add functionality in a backward-compatible manner. For example, the semantic versioning specification considers adding a new method or type without changing any other API to be backward-compatible.
///
///	**The Patch Version**
///
///	Increase the third digit of a version, or _patch version_, if you are making a backward-compatible bug fix. This allows clients to benefit from bugfixes to your package without incurring any maintenance burden.
///
///	- Remark: `SemanticVersion`'s implementation is adapted from Swift Package Manager's `Version`. They're largely identical.
struct SemanticVersion: Hashable {
	
	///	Creates a version with the provided components of a semantic version.
	///
	///	- Parameters:
	///	  - major: The major version numner.
	///	  - minor: The minor version number.
	///	  - patch: The patch version number.
	///	  - prereleaseIdentifiers: The pre-release identifier.
	///	  - buildMetaDataIdentifiers: Build metadata that identifies a build.
	init(
		_ major: Int,
		_ minor: Int = 0,
		_ patch: Int = 0,
		prereleaseIdentifiers: [String] = [],
		buildMetadataIdentifiers: [String] = []
	) {
		precondition(major >= 0 && minor >= 0 && patch >= 0, "Negative versioning is invalid.")
		self.major = major
		self.minor = minor
		self.patch = patch
		self.prereleaseIdentifiers = prereleaseIdentifiers
		self.buildMetadataIdentifiers = buildMetadataIdentifiers
	}
	
	///	The dummy version that serves as a placeholder.
	static let dummy: Self = "0.0.0"
	
	///	The major version according to the semantic versioning standard.
	let major: Int
	
	///	The minor version according to the semantic versioning standard.
	let minor: Int
	
	///	The patch version according to the semantic versioning standard.
	let patch: Int
	
	///	The pre-release identifier according to the semantic versioning standard, such as `-beta.1`.
	let prereleaseIdentifiers: [String]
	
	///	The build metadata of this version according to the semantic versioning standard, such as a commit hash.
	let buildMetadataIdentifiers: [String]
	
}

extension SemanticVersion {
	///	Creates a semantic version with the provided version string.
	///	- Parameter versionString: A version string to use for creating a new version struct.
	init(_ versionString: String) {
		let prereleaseStartIndex = versionString.firstIndex(of: "-")
		let metadataStartIndex = versionString.firstIndex(of: "+")
		
		let requiredEndIndex = prereleaseStartIndex ?? metadataStartIndex ?? versionString.endIndex
		let requiredCharacters = versionString.prefix(upTo: requiredEndIndex)
		let requiredComponents = requiredCharacters
			.split(separator: ".", maxSplits: 2, omittingEmptySubsequences: false)
			.map(String.init)
			.compactMap({ Int($0) })
			.filter({ $0 >= 0 })
		
		guard requiredComponents.count >= 1 && requiredComponents.count <= 3 else {
			self = Self.dummy
			os_log("Unable to create a semantic version from string \"%@\". A dummy version 0.0.0 is used as a placeholder.", log: .default, type: .error, versionString)
			return
		}
		
		self.major = requiredComponents[0]
		self.minor = requiredComponents.count >= 2 ? requiredComponents[1] : 0
		self.patch = requiredComponents.count >= 3 ? requiredComponents[2] : 0
		
		func identifiers(start: String.Index?, end: String.Index) -> [String] {
			guard let start = start else { return [] }
			let identifiers = versionString[versionString.index(after: start)..<end]
			return identifiers.split(separator: ".").map(String.init)
		}
		
		self.prereleaseIdentifiers = identifiers(
			start: prereleaseStartIndex,
			end: metadataStartIndex ?? versionString.endIndex)
		self.buildMetadataIdentifiers = identifiers(start: metadataStartIndex, end: versionString.endIndex)
	}
}

//	MARK: - Codable Conformance
extension SemanticVersion: Codable {
	
	///	Creates a semantic version by decoding from the given `decoder`.
	///	- Parameter decoder: The decoder to read data from.
	///	- Throws: A `DecodingError` instance.
	init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		let versionString = try container.decode(String.self)
		self.init(versionString)
	}
	
	///	Serialise a semantic version into the given `encoder`.
	///	- Parameter encoder: The encoder to write data to.
	///	- Throws: An `EncondingError` instance.
	func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(description)
	}
	
}

//	MARK: - Comparable Conformance
extension SemanticVersion: Comparable {
	static func < (lhs: Self, rhs: Self) -> Bool {
		let lhsComparators = [lhs.major, lhs.minor, lhs.patch]
		let rhsComparators = [rhs.major, rhs.minor, rhs.patch]
		
		if lhsComparators != rhsComparators {
			return lhsComparators.lexicographicallyPrecedes(rhsComparators)
		}
		
		guard lhs.prereleaseIdentifiers.count > 0 else {
			return false //	Non-prerelease lhs >= potentially prerelease rhs
		}
		
		guard rhs.prereleaseIdentifiers.count > 0 else {
			return true //	Prerelease lhs < non-prerelease rhs
		}
		
		let zippedIdentifiers = zip(lhs.prereleaseIdentifiers, rhs.prereleaseIdentifiers)
		for (lhsPrereleaseIdentifier, rhsPrereleaseIdentifier) in zippedIdentifiers {
			if lhsPrereleaseIdentifier == rhsPrereleaseIdentifier {
				continue
			}
			
			let typedLhsIdentifier: Any = Int(lhsPrereleaseIdentifier) ?? lhsPrereleaseIdentifier
			let typedRhsIdentifier: Any = Int(rhsPrereleaseIdentifier) ?? rhsPrereleaseIdentifier
			
			switch (typedLhsIdentifier, typedRhsIdentifier) {
			case let (int1 as Int, int2 as Int): return int1 < int2
			case let (string1 as String, string2 as String): return string1 < string2
			case (is Int, is String): return true	//	Int prereleases < String prereleases
			case (is String, is Int): return false
			default:
				return false
			}
		}
		
		return lhs.prereleaseIdentifiers.count < rhs.prereleaseIdentifiers.count
	}
}

//	MARK: - CustomStringConvertible Conformance
extension SemanticVersion: CustomStringConvertible {
	///	A textual description of the version instance.
	var description: String {
		var base = "\(major).\(minor).\(patch)"
		if !prereleaseIdentifiers.isEmpty {
			base += "-" + prereleaseIdentifiers.joined(separator: ".")
		}
		if !buildMetadataIdentifiers.isEmpty {
			base += "+" + buildMetadataIdentifiers.joined(separator: ".")
		}
		return base
	}
}

//	MARK: - ExpressibleByStringLiteral Conformance
extension SemanticVersion: ExpressibleByStringLiteral {
	
	///	Creates a semantic version with the provided string literal.
	///	- Parameter versionString: A string literal to use for creating a new version struct.
	init(stringLiteral versionString: String) {
		self.init(versionString)
	}
	
	///	Creates a semantic version with the provided extended grapheme cluster.
	///	- Parameter versionString: An extended grapheme cluster to use for creating a new version struct.
	init(extendedGraphemeClusterLiteral versionString: String) {
		self.init(stringLiteral: versionString)
	}
	
	///	Creates a semantic version with the provided Unicode string.
	///	- Parameter versionString: A Unicode string to use for creating a new version struct.
	init(unicodeScalarLiteral versionString: String) {
		self.init(stringLiteral: versionString)
	}
	
}

//	MARK: - IntervalMember Conformance
extension SemanticVersion: IntervalMember {}
