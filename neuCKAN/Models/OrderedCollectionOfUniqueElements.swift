//
//  OrderedCollectionOfUniqueElements.swift
//  neuCKAN
//
//  Created by you on 20-04-23.
//  Copyleft © 2020 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import Foundation

///	An ordered collection of unique elements.
protocol OrderedCollectionOfUniqueElements: OrderedCollection, CollectionOfUniqueElements {
	///	Inserts the given element in the collection if it is not already present, then sorts the collection in place, using the given predicate as the comparison between elements.
	///
	///	If an element equal to `newMember` is already contained in the collection, this method has no effect.
	///	- Parameters:
	///		- newMember: An element to insert into the collection.
	///		- areInIncreasingOrder: A predicate that returns `true` if its first argument should be ordered before its second argument; otherwise, `false`. If `areInIncreasingOrder` throws an error during the sort, the elements may be in a different order, but none will be lost.
	///	- Returns: `(true, newMember)` if `newMember` was not contained in the collection. If an element equal to `newMember` was already contained in the collection, the method returns `(false, oldMember)`, where `oldMember` is the element that was equal to `newMember`. In some cases, `oldMember` may be distinguishable from `newMember` by identity comparison or some other means.
	@discardableResult
	mutating func insert(_ newMember: Element, sortResultBy areInIncreasingOrder: (Self.Element, Self.Element) throws -> Bool) rethrows -> (inserted: Bool, memberAfterInsert: Element)
	
	///	Inserts the given element into the collection unconditionally, then sorts the collection in place, using the given predicate as the comparison between elements.
	///
	///	If an element equal to `newMember` is already contained in the collection, `newMember` replaces the existing element.
	///	- Parameters:
	///		- newMember: An element to insert into the collection.
	///		- areInIncreasingOrder: A predicate that returns `true` if its first argument should be ordered before its second argument; otherwise, `false`. If `areInIncreasingOrder` throws an error during the sort, the elements may be in a different order, but none will be lost.
	///	- Returns: For ordinary collections, an element equal to `newMember` if the collection already contained such a member; otherwise, `nil`. In some cases, the returned element may be distinguishable from `newMember` by identity comparison or some other means.
	///
	///	  For collections where the collection type and element type are the same, this method returns any intersection between the collection and `[newMember]`, or `nil` if the intersection is empty.
	@discardableResult
	mutating func update(with newMember: Element, sortResultBy areInIncreasingOrder: (Self.Element, Self.Element) throws -> Bool) rethrows -> Element?
	
	///	Removes the given element and any elements subsumed by the given element.
	///	- Parameters:
	///		- member: The element of the collection to remove.
	///		- areInIncreasingOrder: A predicate that returns `true` if its first argument should be ordered before its second argument; otherwise, `false`. If `areInIncreasingOrder` throws an error during the sort, the elements may be in a different order, but none will be lost.
	///	- Returns: For ordinary collections, an element equal to `member` if `member` is contained in the collection; otherwise, `nil`. In some cases, a returned element may be distinguishable from `newMember` by identity comparison or some other means.
	///
	///	  For collections where the collection type and element type are the same, this method returns any intersection between the collection and `[member]`, or `nil` if the intersection is empty.
	@discardableResult
	mutating func remove(_ member: Element, sortResultBy areInIncreasingOrder: (Self.Element, Self.Element) throws -> Bool) rethrows -> Element?
}

extension OrderedCollectionOfUniqueElements {
	@discardableResult
	mutating func insert(_ newMember: Element, sortResultBy areInIncreasingOrder: (Self.Element, Self.Element) throws -> Bool) rethrows -> (inserted: Bool, memberAfterInsert: Element) {
		insert(newMember)
		try sort(by: areInIncreasingOrder)
	}
	
	mutating func update(with newMember: Element, sortResultBy areInIncreasingOrder: (Self.Element, Self.Element) throws -> Bool) rethrows -> Element? {
		update(with: newMember)
		try sort(by: areInIncreasingOrder)
	}
	
	mutating func remove(_ member: Element, sortResultBy areInIncreasingOrder: (Self.Element, Self.Element) throws -> Bool) rethrows -> Element? {
		update(with: member)
		try sort(by: areInIncreasingOrder)
	}
}
