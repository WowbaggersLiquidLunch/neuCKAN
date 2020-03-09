//
//  TargetConvertible.swift
//  neuCKAN
//
//  Created by you on 20-03-05.
//  Copyleft © 2020 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import Foundation

/**
A type that can represent a KSP target.
*/
protocol TargetConvertible {
	/**
	Returns an optional KSP target from the conforming instance.
	
	- Returns: The KSP target converted from the conforming instance, or `nil` if the conversion fails.
	*/
	func asTarget() -> Target?
}

extension Target: TargetConvertible {
	/**
	Returns `self`.
	
	- Returns: `self`.
	*/
	func asTarget() -> Target? { self }
}
