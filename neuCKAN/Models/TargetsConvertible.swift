//
//  TargetsConvertible.swift
//  neuCKAN
//
//  Created by you on 20-03-08.
//  Copyleft © 2020 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import Foundation

/**
A type that can represent a collection of KSP targets.
*/
protocol TargetsConvertible {
	/**
	Returns an optional collection of KSP targets from the conforming instance.
	
	- Returns: The KSP targets converted from the conforming instance, or `nil` if the conversion fails.
	*/
	func asTargets() -> Targets?
}

//extension Sequence: TargetsConvertible where Element: TargetConvertible {
//	/**
//	Returns an optional `Target` instance from the sequence of targets.
//
//	- Returns: The KSP targets converted from the sequence of targets, or `nil` if the conversion fails.
//	*/
//	func asTargets() -> Targets? { Targets(targets: self) }
//}
