//
//  Mods.swift
//  neuCKAN
//
//  Created by you on 20-02-04.
//  Copyleft © 2020 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import Foundation

/**
An unordered collection of mods.

- See Also: `mod`.
*/
struct Mods: Hashable, Codable {
	
	/**
	A collection of mods.
	
	A mod, in turn, is a collection of its different versions of releases.
	*/
	private var mods: Set<Mod> = []
	
	/**
	Inserts a mod into a mod collection.
	
	If a mod with the same ID already exists in the collection, then the existing mod is replaced by the union of the two. Otherwise, the new mode is added to the collection.
	
	- Parameter mod: The mod to be inserted into the collection.
	
	- Complexity:O(_mnr_) in the worst case and O(_m_) in the best case, where _m_ is the count of existing mods in the mod collection, where _n_ is the count of releases in the new given mod, and where _r_ is the highest count of releases in a mod in the mod collection.
	*/
	mutating func insert(_ mod: Mod) {
		var modCopy = mod
		if let oldMod = mods.first(where: { $0.id == mod.id }) {
			mods.remove(oldMod)
			oldMod.forEach { modCopy.insert($0) }
		}
		mods.insert(modCopy)
	}
	
	/**
	Inserts a mod release into a mod collection.
	
	If a mod with the same ID already exists in the collection, the release is inserted into the mod. Otherwise, a new mod holding this mod release is created and added to the collection.
	
	- Parameter release: The mod release to be inserted into the collection.
	
	- Complexity: O(_mr_) in the worst case and O(_m_) in the best case, where _m_ is the count of existing mods in the mod collection, and where _r_ is the count of releases in the existing mod in the collection that shares the same `id` with the release.
	*/
	mutating func insert(_ release: Release) {
		if let mod = mods.first(where: { $0.id == release.id }) {
			mods.remove(mod)
			mods.insert(Mod(superseding: mod, with: release))
		} else {
			mods.insert(Mod(with: release))
		}
	}
	
	/**
	Inserts a sequence of mod releases into the mod collection.
	
	The mod releases are checked one-by-one. If a mod with the same ID already exists in the collection, the release is inserted into the mod. Otherwise, a new mod holding this mod release is created and added to the collection.
	
	- Parameter releases: The sequence of mod releases to be inserted into the mods array.
	
	- Complexity: O(_mnr_), where _m_ is the count of existing mods in the mod collection, where _n_ is the count of releases, and where _r_ is the highest count of releases in an existing mod in the collection that shares the same `id` with one of the releases.
	*/
	mutating func insert<T: Sequence>(contentsOf releases: T) where T.Element == Release {
		releases.forEach { insert($0) }
	}
	
	/**
	Get and set a mod by its ID.
	
	- Parameter id: The mod's ID.
	
	- Returns: The mod with the specified ID.
	
	- Complexity: O(_n_), where _n_ is the count of existing mods in the collection.
	*/
	subscript(id: String) -> Mod? {
		get {
			mods.first(where: { $0.id == id })
		}
		set(newMod) {
			if let oldMod = mods.first(where: { $0.id == id }) {
				mods.remove(oldMod)
			}
			if let newMod = newMod {
				mods.insert(newMod)
			}
		}
	}
}

//	MARK: - Collection Conformance

extension Mods: Collection {
	
	typealias Index = Set<Mod>.Index
	
	/**
	The position of the first mod in a nonempty mod collection.
	
	If the collection has no mod, `startIndex` is equal to `endIndex`.
	*/
	var startIndex: Index { mods.startIndex }
	
	/**
	The mod collection’s “past the end” position—i.e. the position one greater than the last valid subscript argument.
	
	When you need a range that includes the last mod of the collection, use the half-open range operator (`..<`) with `endIndex`. The `..<` operator creates a range that doesn’t include the upper bound, so it’s always safe to use with `endIndex`.
	
	If the collection has no mod, `endIndex` is equal to `startIndex`.
	*/
	var endIndex: Index { mods.endIndex }
	
	/**
	Returns the position immediately after the given index.
	
	- Parameter position: A valid polition of the mod collection. `i` must be less than `endIndex`.
	
	- Returns: The index value immediately after `i.`
	*/
	func index(after i: Index) -> Index { mods.index(after: i) }
	
	/**
	Accesses the mod at the specified position.
	
	This subscript provides read-only access. For write access, use `subscript(id:)`.
	
	- Parameter position: The position of the mod to access. `position` must be a valid index of the mod collection that is not equal to the `endIndex` property.
	
	- Returns: The mod at the specified index.
	
	- Complexity: O(1).
	*/
	subscript(position: Index) -> Mod { mods[position] }
}