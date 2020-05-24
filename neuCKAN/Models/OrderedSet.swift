//
//  OrderedSet.swift
//  neuCKAN
//
//  Created by you on 20-04-23.
//  Copyleft © 2020 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import Foundation
import os.log

///	An ordered set.
struct OrderedSet<Element: Hashable> {
	private var variant: [Element]
}

//	MARK: - OrderedCollectionOfUniqueElements Conformance
extension OrderedSet: OrderedCollectionOfUniqueElements {
	
	//	MARK: Collection Conformance
	
	typealias Index = Array<Element>.Index
	
	func index(after i: Index) -> Index { variant.index(after: i) }
	
	var startIndex: Index { variant.startIndex }
	
	var endIndex: Index { variant.endIndex }
	
	subscript(position: Index) -> Element {
		get { variant[position] }
		set(newElement) {
			assertionFailure("Cannot guarantee elements' uniqueness")
		}
	}
	
	//	MARK: OrderedCollection Conformance
	
	mutating func replaceSubrange<C, R>(_ subrange: R, with newElements: C) where C : Collection, R : RangeExpression, Self.Element == C.Element, Self.Index == R.Bound {
		variant.replaceSubrange(subrange, with: newElements)
	}
	
	//	MARK: CollectionOfUniqueElements Conformance
	
	init() { variant = [] }
	
	func contains(_ member: Element) -> Bool { variant.contains(member) }
		
	@discardableResult
	mutating func insert(_ newMember: Element) -> (inserted: Bool, memberAfterInsert: Element) {
		if !contains(newMember) {
			variant.append(newMember)
			return (inserted: true, memberAfterInsert: newMember)
		} else {
			let oldMember = variant.first(where: { $0 == newMember })
			return (inserted: false, memberAfterInsert: oldMember!)
//			return (inserted: false, memberAfterInsert: newMember)
		}
	}
	
	@discardableResult
	mutating func update(with newMember: Element) -> Element? {
		if let oldMemberIndex = variant.firstIndex(of: newMember) {
			let oldMember = variant[oldMemberIndex]
			variant[oldMemberIndex] = newMember
			return oldMember
		} else {
			variant.append(newMember)
			return nil
		}
	}
	
	@discardableResult
	mutating func remove(_ member: Element) -> Element? {
		if contains(member) {
			variant.removeAll(where: { $0 == member })
			return member
		} else {
			return nil
		}
	}
	
	//	MARK: Conformance Disambiguations
	
	init<S>(_ elements: S) where S : Sequence, Self.Element == S.Element {
		variant = []
		elements.forEach {
			insert($0)
		}
	}
}

//	MARK: - Codable Conformance
extension OrderedSet: Codable where Element: Codable {
	
	///	Creates an ordered set with the appropriate type by decoding from the given `decoder`.
	///	- Parameter decoder: The decoder to read data from.
	init(from decoder: Decoder) throws {
		var values = try decoder.unkeyedContainer()
		var orderedSet: OrderedSet<Element> = []
		while values.count! > values.currentIndex {
			do {
				orderedSet.insert(try values.decode(Element.self))
			} catch let decodingError as DecodingError {
				os_log("Unable to decode value #%d in unkeyed container due to a decoding error: %@.", type: .error, values.currentIndex, decodingError.localizedDescription)
			} catch let cocoaError as CocoaError {
				os_log("Unable to decode value #%d in unkeyed container due to a cocoa error: %@.", type: .error, values.currentIndex, cocoaError.localizedDescription)
			} catch let nsError as NSError {
				os_log("Unable to decode value #%d in unkeyed container due to an error in domain %@: %@.", type: .error, values.currentIndex, nsError.domain, nsError.localizedDescription)
			} catch let error {
				os_log("Unable to decode value #%d in unkeyed container due to an error: %@.", type: .error, values.currentIndex, error.localizedDescription)
			}
		}
		self = orderedSet
	}
	
	///	Encodes an ordered set.
	///	- Parameter encoder: The encoder to encode data to.
	func encode(to encoder: Encoder) throws {
		var container = encoder.unkeyedContainer()
		do {
			try container.encode(variant)
		} catch let encodingError as EncodingError {
			os_log("Unable to encode value %@ due to a decoding error: %@", type: .error, String(describing: variant), encodingError.localizedDescription)
		} catch let cocoaError as CocoaError {
			os_log("Unable to encode value %@ due to a cocoa error: %@.", type: .error, String(describing: variant), cocoaError.localizedDescription)
		} catch let nsError as NSError {
			os_log("Unable to encode value %@ due to an error in domain %@: %@.", type: .error, String(describing: variant), nsError.domain, nsError.localizedDescription)
		} catch let error {
			os_log("Unable to encode value %@ due to an error: %@.", type: .error, String(describing: variant), error.localizedDescription)
		}
	}
}
