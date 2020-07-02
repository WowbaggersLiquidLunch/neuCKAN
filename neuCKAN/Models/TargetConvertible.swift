//
//	TargetConvertible.swift
//	neuCKAN
//
//	Created by you on 20-03-05.
//	Copyleft © 2020 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import Foundation

/**
A type that can represent a KSP target.
*/
protocol TargetConvertible: TargetsConvertible {
	/**
	Returns an optional KSP target from the conforming instance.
	
	- Returns: The KSP target converted from the conforming instance, or `nil` if the conversion fails.
	*/
	func asTarget() -> Target?
}

extension TargetConvertible {
	/**
	Returns an optional collection of KSP targets from the `TargetConvertible`-conforming instance.
	
	- Returns: The KSP targets converted from the `TargetConvertible`-conforming instance, or `nil` if the conversion fails.
	*/
	func asTargets() -> Targets? { Targets(targets: [self.asTarget()]) }
}
