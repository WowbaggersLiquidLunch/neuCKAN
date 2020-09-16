//
//  ExtendedVersion.swift
//  neuCKAN
//
//	Created by you on 20-09-15.
//	Copyleft © 2020 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import os.log
import Interval

///	An otherwise semantic version extended with a build.
///
///	An extended semantic version consists of three period-separated integers followed (after a space) by an optional build enclosed in a pair of parentheses, e.g. `1.0.0 (42)`.The build provides a potentially finer resolution than the semantic version, and can be used to reflect internal versioning.
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
///	**The Build**
///
///	Increase the build every time when (but not only when) the semantic version increases.
@dynamicMemberLookup
struct ExtendedSemanticVersion: Hashable {
	///	The semantic version.
	let semanticVersion: SemanticVersion
	///	The build.
	let build: Int?
	
	///	Returns the value at a given key path.
	///	- Parameter keyPath: The given key path to look up the value at.
	///	- Returns: the value at `keyPath`.
	subscript<T>(dynamicMember keyPath: KeyPath<SemanticVersion, T>) -> T {
		semanticVersion[keyPath: keyPath]
	}
}

extension ExtendedSemanticVersion {
	init(_ versionString: String) {
		let buildStartIndex = versionString.firstIndex(of: " ") ?? versionString.endIndex
		let semanticVersionString = versionString.prefix(upTo: buildStartIndex)
		let buildStringWithParentheses = versionString.suffix(from: buildStartIndex)
		let buildString = buildStringWithParentheses
			.suffix(from: buildStringWithParentheses.firstIndex(of: "(") ?? buildStringWithParentheses.startIndex)
			.prefix(upTo: buildStringWithParentheses.lastIndex(of: ")") ?? buildStringWithParentheses.endIndex)
		let build = Int(buildString)
		if build == nil {
			os_log("Unable to parse build value from string \"%@\"", log: .default, type: .error, versionString)
		}
		self.init(semanticVersion: SemanticVersion(String(semanticVersionString)), build: build)
	}
}

//	MARK: - Codable Conformance
extension ExtendedSemanticVersion: Codable {
	
	///	Creates an extended version by decoding from the given `decoder`.
	///	- Parameter decoder: The decoder to read data from.
	///	- Throws: A `DecodingError` instance.
	init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		let versionString = try container.decode(String.self)
		self.init(versionString)
	}
	
	///	Serialise a extended version into the given `encoder`.
	///	- Parameter encoder: The encoder to write data to.
	///	- Throws: An `EncondingError` instance.
	func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(description)
	}
	
}

//	MARK: - Comparable Conformance
extension ExtendedSemanticVersion: Comparable {
	static func < (lhs: Self, rhs: Self) -> Bool {
		guard let lhsBuild = lhs.build, let rhsBuild = rhs.build else {
			return lhs.semanticVersion < rhs.semanticVersion
		}
		return lhsBuild < rhsBuild
	}
}

//	MARK: - CustomStringConvertible Conformance
extension ExtendedSemanticVersion: CustomStringConvertible {
	var description: String {
		let semanticVersionString = String(describing: semanticVersion)
		guard let build = build else { return semanticVersionString }
		return "\(semanticVersionString) (\(build)"
	}
}

//	MARK: - ExpressibleByStringLiteral Conformance
extension ExtendedSemanticVersion: ExpressibleByStringLiteral {
	
	///	Creates a extended version with the provided string literal.
	///	- Parameter versionString: A string literal to use for creating a new version struct.
	init(stringLiteral versionString: String) {
		self.init(versionString)
	}
	
	///	Creates a extended version with the provided extended grapheme cluster.
	///	- Parameter versionString: An extended grapheme cluster to use for creating a new version struct.
	init(extendedGraphemeClusterLiteral versionString: String) {
		self.init(stringLiteral: versionString)
	}
	
	///	Creates a extended version with the provided Unicode string.
	///	- Parameter versionString: A Unicode string to use for creating a new version struct.
	init(unicodeScalarLiteral versionString: String) {
		self.init(stringLiteral: versionString)
	}
	
}

//	MARK: - IntervalMember Conformance
extension ExtendedSemanticVersion: IntervalMember {}
