//
//  CollectionOfUniqueElements.swift
//  neuCKAN
//
//  Created by you on 20-04-23.
//  Copyleft © 2020 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import Foundation

///	A collection of unique elements.
protocol CollectionOfUniqueElements: Hashable, Collection, SetAlgebra {
	//	MARK: Adding and Removing Elements
	
	//	MARK: Combining Collections
	///	Returns a new collection with the elements of both this set and the given sequence.
	///	- Parameter other: A sequence of elements. other must be finite.
	func union<S: Sequence>(_ other: S) -> Self where Element == S.Element
	///	Inserts the elements of the given sequence into the collection.
	///	- Parameter other: A sequence of elements. other must be finite.
	mutating func formUnion<S: Sequence>(_ other: S) where Element == S.Element
	///	Returns a new collection, with the elements that are common to both this set and the given sequence.
	///	- Parameter other: A sequence of elements. other must be finite.
	func intersection<S: Sequence>(_ other: S) -> Self where Element == S.Element
	///	Removes the elements of the collection that aren’t also in the given sequence.
	///	- Parameter other: A sequence of elements. other must be finite.
	mutating func formIntersection<S: Sequence>(_ other: S) where Element == S.Element
	///	Returns a new collection, with the elements that are either in this set or in the given sequence, but not in both.
	///	- Parameter other: A sequence of elements. other must be finite.
	func symmetricDifference<S: Sequence>(_ other: S) -> Self where Element == S.Element
	///	Removes the elements of the collection that are also in the given sequence and adds the members of the sequence that are not already in the collection.
	///	- Parameter other: A sequence of elements. other must be finite.
	mutating func formSymmetricDifference<S: Sequence>(_ other: S) where Element == S.Element
	///	Returns a new collection containing the elements of this collection that do not occur in the given sequence.
	///	- Parameter other: A sequence of elements. other must be finite.
	func subtracting<S: Sequence>(_ other: S) -> Self where Element == S.Element
	///	Removes the elements of the given sequence from the collection.
	///	- Parameter other: A sequence of elements. other must be finite.
	mutating func subtract<S: Sequence>(_ other: S) where Element == S.Element
}

extension CollectionOfUniqueElements {
	
	//	EXC_BAD_ACCESS
//	init() { self = [] }
	
	var isEmpty: Bool { startIndex == endIndex }
	
	func union<S: Sequence>(_ other: S) -> Self where Element == S.Element {
		union(Self(other))
	}
	
	func union(_ other: Self) -> Self {
		var newCollectionOfUniqueElements = self
		newCollectionOfUniqueElements.formUnion(other)
		return newCollectionOfUniqueElements
	}
	
	mutating func formUnion<S: Sequence>(_ other: S) where Element == S.Element {
		formUnion(Self(other))
	}
	
	mutating func formUnion(_ other: Self) {
		for item in other {
			insert(item)
		}
	}
	
	func intersection<S: Sequence>(_ other: S) -> Self where Element == S.Element {
		intersection(Self(other))
	}
	
	func intersection(_ other: Self) -> Self {
		var newCollectionOfUniqueElements = Self()
		for member in self {
			if other.contains(member) {
				newCollectionOfUniqueElements.insert(member)
			}
		}
		return newCollectionOfUniqueElements
	}
	
	mutating func formIntersection<S: Sequence>(_ other: S) where Element == S.Element {
		formIntersection(Self(other))
	}
	
	mutating func formIntersection(_ other: Self) {
		let result = self.intersection(other)
		if result.count != count {
			self = result
		}
	}
	
	func symmetricDifference<S: Sequence>(_ other: S) -> Self where Element == S.Element {
		symmetricDifference(Self(other))
	}
	
	func symmetricDifference(_ other: Self) -> Self {
		var newCollectionOfUniqueElements = self
		newCollectionOfUniqueElements.formSymmetricDifference(other)
		return newCollectionOfUniqueElements
	}
	
	mutating func formSymmetricDifference<S: Sequence>(_ other: S) where Element == S.Element {
		formSymmetricDifference(Self(other))
	}
	
	mutating func formSymmetricDifference(_ other: Self) {
		for member in other {
			if contains(member) {
				remove(member)
			} else {
				insert(member)
			}
		}
	}
	
	func subtracting<S: Sequence>(_ other: S) -> Self where Element == S.Element {
		subtracting(Self(other))
	}
	
	func subtracting(_ other: Self) -> Self {
		var newCollectionOfUniqueElements = self
		newCollectionOfUniqueElements.subtract(other)
		return newCollectionOfUniqueElements
	}
	
	mutating func subtract<S: Sequence>(_ other: S) where Element == S.Element {
		subtract(Self(other))
	}
	
	mutating func subtract(_ other: Self) {
		guard !isEmpty else { return }
		for item in other {
			remove(item)
		}
	}
}
