//
//	CKANFuckery.swift
//	neuCKAN
//
//	Created by you on 19-12-25.
//	Copyleft © 2019 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import Foundation
import os.log

/**
An item, or a list thereof.

Because CKAN metadata specification just has to allow either a something or a list of something in so many fields.
*/
enum CKANFuckery<Item: Hashable & Codable & CustomStringConvertible & Defaultable>: Hashable, Codable {
	
	/**
	Instantiate `CKANFuckery` with the appropriate type by decoding from the given `decoder`.
	
	- Parameter decoder: The decoder to read data from.
	*/
	init(from decoder: Decoder) throws {
		if let container = try? decoder.unkeyedContainer() {
			var values = container
			var itemSet: Set<Item> = []
			while values.count! > values.currentIndex {
				let indexBeforeLoop = values.currentIndex
				if let newItem  = try? values.decode(Item.self) {
					itemSet.insert(newItem)
				}
				if values.currentIndex <= indexBeforeLoop {
					os_log("Unable to decode value #%d in unkeyed container.", type: .debug, values.currentIndex)
					break
				}
			}
			self = .items(itemSet)
		} else if let value = try? decoder.singleValueContainer() {
			self = .item((try? value.decode(Item.self)) ?? Item.defaultInstance)
		} else {
			self = .item(Item.defaultInstance)
		}
	}
	
	/**
	Encodes a `CKANFuckery` instance`.
	
	- Parameter encoder: The encoder to encode data to.
	*/
	func encode(to encoder: Encoder) throws {
		switch self {
		case .item(let value):
			var container = encoder.singleValueContainer()
			try container.encode(value)
		case .items(let values):
			var container = encoder.unkeyedContainer()
			try container.encode(values)
		}
	}
	
	case item(Item)
	case items(Set<Item>)
}

//	Conformance to CustomStringConvertible allows an instance of CKANFuckery to be displayed in a human-readable format.
extension CKANFuckery: CustomStringConvertible {
	/// A human-readable representation of its content.
	var description: String {
		switch self {
		case .item(let item):
			return String(describing: item)
		case .items(let items):
			return items.map{ String(describing: $0) }.joined(separator: ", ")
		}
	}
}

///	A type that provides a default instance when requested.
protocol Defaultable {
	///	An instance of this type with a predefined composition.
	static var defaultInstance: Self { get }
}

extension String: Defaultable {
	///	A default String instance: `""`.
	static let defaultInstance: String = ""
}
