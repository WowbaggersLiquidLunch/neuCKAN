//
//	EmptyInstanceProviding.swift
//	neuCKAN
//
//	Created by you on 20-03-11.
//	Copyleft © 2020 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import Foundation

///	A type that provides a default empty representation.
protocol EmptyInstanceProviding: DefaultProviding {
	///	An empty instance of the type.
	static var emptyInstance: Self { get }
}

extension EmptyInstanceProviding {
	///	A default instance generated from the type's `EmptyRepresentable` conformance.
	static var defaultInstance: Self { emptyInstance }
}

extension String: EmptyInstanceProviding {
	///	An empty String instance: `""`.
	static let emptyInstance: String = ""
}
