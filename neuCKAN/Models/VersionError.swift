//
//  VersionError.swift
//  neuCKAN
//
//  Created by you on 20-07-02.
//  Copyleft © 2020 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import Foundation

/// An error that occurs during the instanciation of `Version` and `OrdinalVersion`.
enum VersionError: Error {
	///	An indication that a non-empty string was expected, but an empty one was given.
	case stringEmpty
	///	An indication that a quasi-semantic version component was expected in the version string, but it did not contain one.
	case quasiSemanticVersionNotFound(versionString: String)
	///	An indication that a numerical minimal comparable unit is too large for the system's memory address size.
	case minimalComparableUnitOversize(comparableUnitString: String, versionString: String)
}

//	MARK: - LocalizedError Conformance
extension VersionError: LocalizedError {
	
	var errorDescription: String? {
		switch self {
		case .stringEmpty:
			return "The version string is empty."
		case let .quasiSemanticVersionNotFound(versionString: versionString):
			return "The version string \"\(versionString)\" does not contain a quasi-semantic version."
		case let .minimalComparableUnitOversize(comparableUnitString: comparableUnitString, versionString: versionString):
			return "The version string \"\(versionString)\" has oversized component \"\(comparableUnitString)\"."
		}
	}
	
	var failureReason: String? {
		switch self {
		case .stringEmpty:
			return "The initialiser expects a non-empty string, but an empty string is given. No versioning information can be obtained from an empty string."
		case let .quasiSemanticVersionNotFound(versionString: versionString):
			return "The version string deconstruction algorithm expects a quasi-semantic version component in the version string \"\(versionString)\", but none is found. In practice, all version-related operations (e.g. version comparison) will do just fine without it, even if the entire original version string is empty. However, CKAN metadata specification implicitly demands a non-empty value for the quasi-semantic version. Thus, for the sake of specification-compliance and maintining a consistent behaviour across all CKAN client, version strings without the quasi-semantic version component are disallowed."
		case let .minimalComparableUnitOversize(comparableUnitString: comparableUnitString, versionString: versionString):
			return "The number \(comparableUnitString) in version string \"\(versionString)\" overflows the system's memory address size."
		}
	}
	
}

//	TODO: Conform VersionError to RecoverableError.
//	MARK: - RecoverableError Conformance
//extension VersionError: RecoverableError {
//	func attemptRecovery(optionIndex recoveryOptionIndex: Int) -> Bool {
//		<#code#>
//	}
//
//	var recoveryOptions: [String] {
//		<#code#>
//	}
//
//
//}
