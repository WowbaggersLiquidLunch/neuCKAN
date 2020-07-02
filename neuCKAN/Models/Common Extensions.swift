//
//	Common Extensions.swift
//	neuCKAN
//
//	Created by you on 20-05-22.
//	Copyleft © 2020 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import Foundation

extension NSRegularExpression: Comparable {
	public static func < (lhs: NSRegularExpression, rhs: NSRegularExpression) -> Bool {
		return lhs.pattern < rhs.pattern
	}
}

extension Sequence {
	//	FIXME: group<T>(by key: (Element) throws -> T) rethrows -> OrderedDictionary<T, Self> will be better.
	//	FIXME: Add labels to closure as soon as Swift supports it.
	/// Group the sequence by the given criterion.
	/// - Parameter criterion: The basis by which to group the sequence.
	/// - Throws: `Error`.
	/// - Returns: A dictionary consisting of the sequence grouped by the given criterion.
	func group<T>(by criterion: (_ transforming: Element) throws -> T) rethrows -> [T: [Element]] {
		var groups: [T: [Element]] = [:]
		for element in self {
			try groups[criterion(_: element), default: []].append(element)
		}
		return groups
	}
}
