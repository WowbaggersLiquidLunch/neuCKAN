//
//	OrderedCollection.swift
//	neuCKAN
//
//	Created by you on 20-04-23.
//	Copyleft © 2020 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import Foundation

///	An ordered collection.
protocol OrderedCollection: Hashable, RandomAccessCollection, MutableCollection, RangeReplaceableCollection {
	///	Returns the elements of the ordered collection, sorted using the given predicate as the comparison between elements.
	///	- Parameter areInIncreasingOrder: A predicate that returns `true` if its first argument should be ordered before its second argument; otherwise, `false`.
	///	- Returns: A sorted ordered collection of the ordered collection’s elements.
	@inlinable func sorted(by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows -> Self
}

extension OrderedCollection {
	@inlinable func sorted(by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows -> Self {
		var newOrdredCollection = self
		try newOrdredCollection.sort(by: areInIncreasingOrder)
		return newOrdredCollection
	}
}

extension OrderedCollection where Element: Comparable {
	///	Returns the elements of the ordered collection, sorted.
	///	- Returns: A sorted ordered collection of the ordered collection’s elements.
	@inlinable func sorted() -> Self {
		return sorted(by: <)
	}
}
