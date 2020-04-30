//
//  OrderedSet.swift
//  neuCKAN
//
//  Created by you on 20-04-23.
//  Copyleft © 2020 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import Foundation

///	An ordered set.
struct OrderedSet<Element: Comparable> {
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
		set(newElement) { variant[position] = newElement }
	}
	
	//	MARK: OrderedCollection Conformance
	
	//	MARK: CollectionOfUniqueElements Conformance
	
	typealias Element = Element
		
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
}
