//
//	Mods.swift
//	neuCKAN
//
//	Created by you on 20-02-04.
//	Copyleft © 2020 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import Foundation

/**
An ordered collection of unique mods.

- See Also: `mod`.
*/
struct Mods: Hashable, Codable {
	
	///	Creates a mod collection from the given sequence of mods.
	///	- Parameter mods: The sequence of mods to create a mod collection with.
	init<T: Sequence>(mods: T) where T.Element == Mod {
		self.init()
		self.mods = OrderedSet(mods)
	}
	
	//	TODO: Make mods atomic for concurrent parsing.
	
	///	A collection of mods.
	///
	///	A mod, in turn, is a collection of its different versions of releases.
	private var mods: OrderedSet<Mod>
}

//	MARK: - OrderedCollectionOfUniqueElements Conformance

extension Mods: OrderedCollectionOfUniqueElements {
	
	//	MARK: Collection Conformance
	
	typealias Index = OrderedSet<Mod>.Index
	
	///	The position of the first mod in a nonempty mod collection.
	///
	///	If the collection has no mods, `startIndex` is equal to `endIndex`.
	///
	///	- See Also: `endIndex`.
	var startIndex: Index { mods.startIndex }
	
	///	The mod collection’s “past the end” position—i.e. the position one greater than the last valid subscript argument.
	///
	///	When you need a range that includes the last mod of the collection, use the half-open range operator (`..<`) with `endIndex`. The `..<` operator creates a range that doesn’t include the upper bound, so it’s always safe to use with `endIndex`.
	///
	///	If the collection has no mods, `endIndex` is equal to `startIndex`.
	///
	///	- See Also: `startIndex`.
	var endIndex: Index { mods.endIndex }
	
	///	Returns the position immediately after the given index.
	///	- Parameter position: A valid polition in the mod collection. `i` must be less than `endIndex`.
	///	- Returns: The index value immediately after `i.`
	///	- See Also: `endIndex`.
	func index(after i: Index) -> Index { mods.index(after: i) }
	
	///	Accesses the mod at the specified position.
	///
	///	This subscript provides both a getter and a setter, but the setter does not guarantee releases' uniqueness in result. It's advised to use `subscript(version:)` and `update(with:)` for setting a new release.
	///
	///	- Parameter position: The position of the mod to access. `position` must be a valid index of the mod collection that is not equal to the `endIndex` property.
	///	- Returns: The mod at the specified index.
	///	- Complexity: O(1).
	subscript(position: Index) -> Mod {
		get { mods[position] }
		set(newMod) { mods[position] = newMod }
	}
	
	//	MARK: OrderedCollection Conformance
	
	///	Replaces the specified subrange of mods with the given collection thereof.
	///
	///	This method has the effect of removing the specified range of mods from the mod collection and inserting the new mods at the same location. The number of new mods need not match the number of mods being removed.
	///
	///	If you pass a zero-length range as the `subrange` parameter, this method inserts the mods of `newMods` at `subrange.startIndex`. Calling the `insert(contentsOf:at:)` method instead is preferred.
	///
	///	Likewise, if you pass a zero-length collection as the `newMods` parameter, this method removes the mods in the given subrange without replacement. Calling the `removeSubrange(_:)` method instead is preferred.
	///
	///	Calling this method may invalidate any existing indices for use with this mod collection.
	///
	///	- Parameters:
	///	  - subrange: The subrange of the mod collection to replace. The bounds of the range must be valid indices of the mod collection.
	///	  - newMods: The new mods to add to the mod collection.
	///
	///	- Complexity: O(*n* + *m*), where *n* is length of this mod collection and *m* is the length of `newMods`. If the call to this method simply appends the contents of `newMods` to the mod collection, the complexity is O(*m*).
	mutating func replaceSubrange<C: Collection, R: RangeExpression>(_ subrange: R, with newMods: C) where C.Element == Mod, R.Bound == Index {
		mods.replaceSubrange(subrange, with: newMods)
	}
	
	//	MARK: CollectionOfUniqueElements Conformance
	
	///	Creates an empty mod collection.
	///
	///	This initializer is equivalent to initializing with an empty array literal. 
	init() { mods = [] }
	
//	///	Creates a mod collection containing the mods of the given array literal.
//	///
//	///	Do not call this initializer directly. It is used by the compiler when you use an array literal. Instead, create a new mod using an array literal as its value by enclosing a comma-separated list of releases in square brackets. You can use an array literal anywhere a mod is expected by the type context.
//	///
//	///	- Parameter mods: A list of releases of the new mod.
//	init(arrayLiteral mods: Mod...) {
//		self.init(mods)
//	}
	
	///	Returns a `Boolean` value that indicates whether the given mod exists in the mod collection.
	///	- Parameter mod: A mod to look for in the mod collection.
	///	- Returns: `true` if the specified mod exists in the mod collection; otherwise, `false`.
	func contains(_ mod: Mod) -> Bool { mods.contains(mod) }
	
	///	Inserts the given mod in the mod collection if it is not already present.
	///
	///	If a mod whose ID equal to `newMod.id` is already contained in the mod collection, this method has no effect.
	///
	///	- Parameter newMod: A mod to insert into the mod collection.
	///	- Returns: `(true, newMod)` if `newMod` was not contained in the mod collection. If a mod whose ID equal to `newMod.id` was already contained in the mod, the method returns `(false, oldMod)`, where `oldMod` is the mod that was equal to `newMod`, or whose ID was equal to `newMod.id`. In some cases, `oldMod` may be distinguishable from `newMod` by identity comparison or some other means.
	@discardableResult
	mutating func insert(_ newMod: Mod) -> (inserted: Bool, memberAfterInsert: Mod) {
		if let oldMod = mods.first(where: { $0.id == newMod.id } ) {
			return (false, oldMod)
		} else {
			return mods.insert(newMod)
		}
	}
	
	///	Inserts the given mod into the mod collection unconditionally.
	///
	///	If a mod whose ID equal to `newMod.id` is already contained in the mod collection, `newMod` replaces the existing mod.
	///
	///	- Parameter newMod: A mod to insert into the mod collection.
	///	- Returns: A mod equal to `newMod` if the mod collection already contained such a member with the same ID; otherwise, `nil`. In some cases, the returned mod may be distinguishable from `newMod` by identity comparison or some other means.
	@discardableResult
	mutating func update(with newMod: Mod) -> Mod? {
		mods.removeAll(where: { $0.id == newMod.id } )
		return mods.update(with: newMod)
	}
	
	///	Removes the given mod and any mods subsumed by the given mod.
	///
	///	- Parameter mod: The mod of the mod collection to remove.
	///	- Returns: A mod equal to `mod` if `mod` is contained in the mod collection; otherwise, `nil`. In some cases, a returned mod may be distinguishable from `mod` by identity comparison or some other means.
	@discardableResult
	mutating func remove(_ mod: Mod) -> Mod? {
		return mods.remove(mod)
	}
	
	//	MARK: Conformance Disambiguations
	
	///	Creates a new mod collection from a finite sequence of mods.
	///
	///	Use this initialiser to create a new mod collection from an existing sequence, like an array or a range, of mods.
	///
	///	- Parameter mods: The sequence of mods to use as members for the new mod collection. `mods` must be finite.
	init<S: Sequence>(_ mods: S) where S.Element == Element {
		self.mods = OrderedSet(mods)
	}
	
	//	MARK: Conformance Dependants
	
	///	Inserts the given release into a mod collection.
	///
	///	If a mod with an ID equal to `release.modID` already exists in the collection, the release is inserted into the mod. Otherwise, a new mod holding the given release is created and added to the mod collection.
	///
	///	- Parameter release: The mod release to be inserted into the collection.
	///	- Complexity: O(_mr_) in the worst case and O(_m_) in the best case, where _m_ is the count of existing mods in the mod collection, and where _r_ is the count of releases in the existing mod in the collection that shares the same `modID` with the release.
	mutating func insert(_ release: Release) {
		if let mod = mods.first(where: { $0.id == release.modID } ) {
			update(with: Mod(superseding: mod, with: release))
		} else {
			insert(Mod(with: release))
		}
	}
	
	///	Inserts the given sequence of releases into the mod collection.
	///
	///	The releases are checked one-by-one. If a mod with an ID equal to `release.modID` already exists in the collection, the release is inserted into the mod. Otherwise, a new mod holding the given release is created and added to the mod collection.
	///
	///	- Parameter releases: The sequence of mod releases to be inserted into the mods array.
	///	- Complexity: O(_mnr_), where _m_ is the count of existing mods in the mod collection, where _n_ is the count of releases, and where _r_ is the highest count of releases in an existing mod in the collection that shares the same `id` with one of the releases.
	mutating func insert<T: Sequence>(contentsOf releases: T) where T.Element == Release {
		releases.forEach { insert($0) }
	}
	
	///	Accesses the mod associated with the given ID for reading and writing.
	///
	///	This _ID-based_ subscript behaves similarly to that of a dictionary's. It returns the mod for the given ID if the ID is found in the mod collection, or `nil` if the ID is not found. When this subscript is used for modifying the mod collection, the user-supplied new mod must either have the same ID as `id`, or be `nil`. If the new mod is not `nil` and its ID equals to `id`, the mod collection is updated with the new mod; If it's `nil`, the old mod with the given ID is removed from mod collection. Mismatching IDs results in a runtim error.
	///
	///	- Parameter version: The version of the release to find in the mod.
	///	- Returns: The release associated with `version` if `version` is in the mod; otherwise, `nil`.
	subscript(id: String) -> Mod? {
		get {
			mods.first(where: { $0.id == id } )
		}
		set(newMod) {
			if let newMod = newMod {
				precondition(newMod.id == id, "The new mod must either have the same ID as specified in the subscript, or be 'nil'")
				update(with: newMod)
			} else {
				mods.removeAll(where: { $0.id == id })
			}
		}
	}
}
