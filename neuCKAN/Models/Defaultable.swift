//
//  Defaultable.swift
//  neuCKAN
//
//  Created by you on 20-03-11.
//  Copyleft © 2020 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import Foundation

///	A type that provides a default instance when requested.
protocol Defaultable {
	///	An instance of this type with a predefined composition.
	static var defaultInstance: Self { get }
}

extension Defaultable where Self: EmptyRepresentable{
	///	A default instance generated from the type's `EmptyRepresentable` conformance.
	static var defaultInstance: Self { emptyInstance }
}
