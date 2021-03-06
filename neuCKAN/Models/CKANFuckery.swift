//
//	CKANFuckery.swift
//	neuCKAN
//
//	Created by you on 19-12-25.
//	Copyleft © 2019 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import Foundation
import os.log

///	An item, or a list thereof.
///
///	Because CKAN metadata specification just has to allow either a something or a list of something in so many fields.
enum CKANFuckery<Item: Hashable & Comparable & CustomStringConvertible>: Hashable {
	
	///	Creates an empty `CKANFuckery` instance.
	init() {
		self = .items([])
	}
	
	///	Initialise a `CKANFuckery` instance from a single item.
	///
	///	If `item` is `nil`, the instance is initialised as an empty set.
	///
	///	- Parameter item: The item to initialse the `CKANFuckery` instance with.
	///	- See Also: `init<Items: Sequence>(items: Items?) where Items.Element == Item?`.
	init(item: Item?) {
		if let newItem = item {
			self = .item(newItem)
		} else {
			self = .items([])
		}
	}
	
	///	Initialise a `CKANFuckery` instance from a sequence of items.
	///
	///	If `items` is `nil`, or if it doesn't contain any non-`nil` elements, the instance is initialised as an empty set.
	///
	///	- Parameter items: The sequence of items to initialse the `CKANFuckery` instance with.
	///	- See Also: `init(item: Item?)`.
	init<Items: Sequence>(items: Items?) where Items.Element == Item? {
		if let newItems = items {
			let orderedSetOfItems = OrderedSet(newItems.compactMap { $0 } )
			if orderedSetOfItems.count == 1 {
				self = .item(orderedSetOfItems.first!)
			} else {
				self = .items(orderedSetOfItems)
			}
		} else {
			self = .items([])
		}
	}
	
	///	An item of the desired type.
	case item(Item)
	///	An ordered set of items of the desired type.
	case items(OrderedSet<Item>)
}

//	MARK: -Codable Conformance
extension CKANFuckery: Codable where Item: Codable & DefaultProviding {
	
	///	Instantiate `CKANFuckery` with the appropriate type by decoding from the given `decoder`.
	///	- Parameter decoder: The decoder to read data from.
	init(from decoder: Decoder) throws {
		if let _ = try? decoder.unkeyedContainer() {
			self = .items(try OrderedSet(from: decoder))
		} else if let value = try? decoder.singleValueContainer() {
			self = .item((try? value.decode(Item.self)) ?? .defaultInstance)
		} else {
			self = .item(.defaultInstance)
		}
	}
	
	///	Encodes a `CKANFuckery` instance.
	///	- Parameter encoder: The encoder to encode data to.
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
}

//	MARK: - Collection Conformance
extension CKANFuckery: Collection {
	
	///	The position of an item in the `CKANFuckery` instance.
	///
	///	This is the same as `Set<Item>.Index`, unless a customised implementation is provided through an extension of `Set<Item>`
	typealias Index = OrderedSet<Item>.Index
	
	///	The position of the first item in a nonempty `CKANFuckery` instance.
	///
	///	If the instance has no items, `startIndex` is equal to `endIndex`.
	///
	///	- See Also: `endIndex`.
	var startIndex: Index {
		switch self {
		case .item(let item): return OrderedSet([item]).startIndex
		case .items(let items): return items.startIndex
		}
	}
	
	///	The `CKANFuckery` instance’s “past the end” position—i.e. the position one greater than the last valid subscript argument.
	///
	///	When you need a range that includes the last item in the instance, use the half-open range operator (`..<`) with `endIndex`. The `..<` operator creates a range that doesn’t include the upper bound, so it’s always safe to use with `endIndex`.
	///
	///	If the collection has no mods, `endIndex` is equal to `startIndex`.
	///
	///	- See Also: `startIndex`.
	var endIndex: Index {
		switch self {
			case .item(let item): return OrderedSet([item]).endIndex
			case .items(let items): return items.endIndex
		}
	}
	
	///	Returns the position immediately after the given index.
	///	- Parameter position: A valid polition in the `CKANFuckery` instance. `i` must be less than `endIndex`.
	///	- Returns: The index value immediately after `i.`
	///	- See Also: `endIndex`.
	func index(after i: Index) -> Index {
		switch self {
			case .item(let item): return OrderedSet([item]).index(after: i)
			case .items(let items): return items.index(after: i)
		}
	}
	
	///	Accesses or update the item at the specified position.
	///	- Parameter position: The position of the item to access. `position` must be a valid index of the `CKANFuckery` instance that is not equal to the `endIndex` property.
	///	- Returns: The mod at the specified index.
	///	- See Also: `endIndex`.
	subscript(position: Index) -> Item {
		get {
			switch self {
				case .item(let item): return OrderedSet([item])[position]
				case .items(let items): return items[position]
			}
		}
		set(newItem) {
			switch self {
				case .item(let item):
					guard item != newItem else { return }
					self = .items([item, newItem])
				case .items(let items):
					if items.count == 0 {
						self = .item(newItem)
					} else  {
						var variableItems = items
						variableItems[position] = newItem
						self = .items(variableItems)
					}
			}
		}
	}
}

//	MARK: - ExpressibleByArrayLiteral Conformance
extension CKANFuckery: ExpressibleByArrayLiteral {
	//	FIXME: find permanent fix using init(arrayLiteral elements: Item...)
	init(arrayLiteral elements: Item?...) {
		self.init(items: elements)
	}
}

//	MARK: - CustomStringConvertible Conformance
extension CKANFuckery: CustomStringConvertible {
	///	A human-readable representation of its content.
	var description: String {
		switch self {
			case .item(let item):
				return String(describing: item)
			case .items(let items):
				return items.map{ String(describing: $0) }.sorted(by: <).joined(separator: ", ")
		}
	}
}
