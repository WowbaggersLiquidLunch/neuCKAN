//
//  Version.swift
//  neuCKAN
//
//  Created by you on 19-11-05.
//  Copyleft © 2019 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import AppKit
import Foundation
import SwiftUI

/**
A version type containing both an epoch and a semantic versioning sequence.

This is equivalent to the **version** [attribute][0] in a .ckan file.

It translates a .ckan file's `"[epoch:]version"` version string into a `Int Optional`: `epoch`, and an `Int Array`: `version`.

When comparing two version numbers, first the `epoch` of each are compared, then the `version` if epoch is equal. epoch is compared numerically. The `version` is compared in sequence of its elements.

[0]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#version
*/
struct Version: Hashable, Codable{
	
	/**
	The original version string verbatim from the .ckan file.
	*/
	let originalString: String
	
	/**
	The fail-safe insurance to the versioning sequence.
	
	`epoch` is a single (generally small) unsigned integer. It may be omitted, in which case zero is assumed. CKAN provides it to allow mistakes in the version numbers of older versions of a package, and also a package's previous version numbering schemes, to be left behind.
	
	- Note: The purpose of epochs is to allow CKAN to leave behind mistakes in version numbering, and to cope with situations where the version numbering scheme changes. It is not intended to cope with version numbers containing strings of letters which the package management system cannot interpret (such as ALPHA or pre-), or with silly orderings.
	*/
	let epoch: Int?
	
	/**
	The primary versioning sequence.
	
	This is equivalent to the **mod_version** attribute in a .ckan file.
	
	`version` is the main part of the version number. In application to mods, it is usually the version number of the original mod from which the CKAN file is created. Usually this will be in the same format as that specified by the mod author(s); however, it may need to be reformatted to fit into the package management system's format and comparison scheme.
	*/
	let version: [Int]
	
	/**
	The release version suffix.
	
	This is mostly used for denoting a pre-release version. The string follows a `"-"`, and is composed of alphsnumerical characters and `"."`, such as `"alpha"`, `"1337"`, or practically anything. For more information, see [semantic versioning][0]
	
	[0]: https://semver.org/#spec-item-9
	*/
	let releaseSuffix: String?
	
	/**
	The metadata suffix.
	
	The string follows a `"+"`, and is composed of alphsnumerical characters and `".", such as `"alpha"`, `"1337"`, or practically anything. For more information, see [semantic versioning][0]
	
	[0]: https://semver.org/#spec-item-10
	*/
	let metadataSuffix: String?
}
