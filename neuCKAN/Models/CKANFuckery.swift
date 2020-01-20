//
//	CKANFuckery.swift
//	neuCKAN
//
//	Created by you on 19-12-25.
//	Copyleft © 2019 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

//	Because CKAN metadata specification just has to allow either a something or a list of something in so many fields.

import Foundation
import os.log

/**
A string of a set of strings.
*/
enum StringFuckery: Hashable, Codable {
	
	/**
	Initialises a `StringFuckery` instance by decoding from the given `decoder`.
	
	- Parameter decoder: The decoder to read data from.
	*/
	init(from decoder: Decoder) throws {
		if let container = try? decoder.unkeyedContainer() {
			var values = container
			var stringSet: Set<String> = []
			while values.count! > values.currentIndex {
				let indexBeforeLoop = values.currentIndex
				if let newString  = try? values.decode(String.self) {
					stringSet.insert(newString)
				}
				if values.currentIndex <= indexBeforeLoop {
					os_log("Unable to decode value #%d in unkeyed container.", type: .debug, values.currentIndex)
					break
				}
			}
			self = .strings(stringSet)
		} else if let value = try? decoder.singleValueContainer() {
			self = .string((try? value.decode(String.self)) ?? "")
		} else {
			self = .string("")
		}
	}
	
	/**
	Encodes a `StringFuckery` instance`.
	
	- Parameter encoder: The encoder to encode data to.
	*/
	func encode(to encoder: Encoder) throws {
		switch self {
		case .string(let value):
			var container = encoder.singleValueContainer()
			try container.encode(value)
		case .strings(let values):
			var container = encoder.unkeyedContainer()
			try container.encode(values)
		}
	}
	
	case string(String)
	case strings(Set<String>)
}

