//
//	Mod.swift
//	neuCKAN
//
//	Created by you on 19-11-01.
//	Copyleft © 2019 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import Foundation

/**
An ordered collection of a mod's unique releases.

A mod is identified and accessible fron an enclosing `Mods` instance by its `id`.

The read-only `releases` instance property is an array of all the releases. The releases are sorted to reverse chronological order by comparison of their versions whenever `releases` changes.

- See Also: `Mods`.
- See Also: `Release`.

[identifier]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#identifier
[0]: https://github.com/KSP-CKAN/CKAN
[1]: https://github.com/ferram4/Ferram-Aerospace-Research/releases/tag/v0.15.9.1_Liepmann
[2]: https://github.com/ferram4/Ferram-Aerospace-Research/releases/tag/v0.15.9_Liebe
[3]: https://github.com/ferram4/Ferram-Aerospace-Research/releases/tag/v0.15.8.1_Lewis
*/
struct Mod: Hashable, Codable, Identifiable {
	
	/**
	Instantiates a mod release collection from the given release.
	
	- Parameter release: The `Release` instance to from which to instantiates `Mod`.
	*/
	init(with release: Release) {
		self.id = release.modID
		self.releases = [release]
	}
	
	/**
	Instantiates a mod release collection from inserting the given release into the given collection.
	
	- Complexity: O(_n_), where _n_ is the count of existing releases in the given mod.
	*/
	init(superseding mod: Mod, with release: Release) {
		self = mod.inserted(release)
	}
	
	/**
	The mod's read-only globally unique identifier.
	
	This is equivalent to the ["identifier" attribute][0] in a .ckan file.
	
	This is how the mod will be referred to by other CKAN documents. It may only consist of ASCII-letters, ASCII-digits and `-` (dash).
	
	For example:
	- "FAR"
	- "RealSolarSystem".
	
	The identifier is used whenever the mod is referenced (by `dependencies`, `conflicts`, and elsewhere).
	
	The identifier is both case sensitive for machines, and unique regardless of capitalization for human consumption and case-ignorant systems. For example: the hypothetical identifier `"MyMod"` must always be expressed as `"MyMod"` everywhere, but another module cannot assume the `"mymod"` identifier.
	
	[0]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#identifier
	*/
	let id: String
	
	//	TODO: Make releases atomic for concurrent parsing.
	
	/**
	A collection of mod releases of the same mod.
	
	- See Also: `Release`.
	*/
	private var releases: [Release] {
		didSet {
//			self.releases.sort(by: { $0.version >= $1.version } )
		}
	}
	
	/**
	The mod's name.
	
	This is the human readable name of the mod, and may contain any printable characters.
	
	This is equivalent to the ["name" attribute][0] in a .ckan file.
	
	For example:
	- "Ferram Aerospace Research (FAR)"
	- "Real Solar System".
	
	[0]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#name
	*/
	var name: String { releases.max(by: { $0.version > $1.version } )?.name ?? "mod name does not exist" }
	
	//	TODO: Remove need for passing in type.
	//	FIXME: Inconsistent behaviour.
	//	FIXME: Incorrect output for some Collection types.
	
	/**
	Retrieves for the mod an attribute derived from the values of its releases' at the given key path.
	
	- Parameters:
		- keyPath: The key path to a `Release` instance's property.
		- Type: The type of the attribute.
	
	- Returns: The mod's releases' attribute value, if it's the same across all the releases. Or, `"Multiple Values"`, if it's different across all the releases.
	
	- TODO: Remove the need of passing in `Type`.
	*/
	func attribute<T: Hashable>(forKey keyPath: PartialKeyPath<Release>, as Type: T.Type) -> Any? {
		let latestReleaseValue = releases[0][keyPath: keyPath] as! T
		let allValuesMatch = releases.reduce(into: true) { result, release in
			let releaseValue = release[keyPath: keyPath] as! T
			result = result && (releaseValue == latestReleaseValue)
		}
		return allValuesMatch ? latestReleaseValue : "Multiple Values"
	}
	
	/**
	Returns a string describing the mod's attribute derived from the values of its releases' at the given key path.
	
	- Parameters:
		- keyPath: The key path to a `Release` instance's property.
		- Type: The type of the attribute.
	
	- Returns: A string describing the mod's releases' attribute value, if it's the same across all the releases. Or, `"Multiple Values"`, if it's different across all the releases.
	
	- TODO: Remove the need of passing in `Type`.
	*/
	func readableAttribute<T: Hashable & CustomStringConvertible>(forKey keyPath: PartialKeyPath<Release>, ofType Type: T.Type) -> String {
		if let modAttribute = attribute(forKey: keyPath, as: Type) {
			if let modAttribute = modAttribute as? String {
				return modAttribute
			} else if let modAttribute = modAttribute as? T {
				return String(describing: modAttribute)
			}
		}
		return .defaultInstance
	}
	
	/**
	Returns a string describing the mod's attribute's list of values derived from the values of its releases' at the given key path.
	
	Use this if the attribute's value is a `Sequence` type.
	
	- Parameters:
		- keyPath: The key path to a `Release` instance's property.
		- Type: The type of the attribute.
	
	- Returns: A string describing the mod's releases' attribute's list of values, if they're the same across all the releases. Or, `"Multiple Values"`, if they're different across all the releases.
	
	- TODO: Remove the need of passing in `Type`.
	*/
	func readableAttributeElements<T: Hashable & Sequence>(forKey keyPath: PartialKeyPath<Release>, ofType Type: T.Type) -> String where T.Element: CustomStringConvertible {
		if let modAttribute = attribute(forKey: keyPath, as: Type) {
			if let modAttribute = modAttribute as? String {
				return modAttribute
			} else if let modAttribute = modAttribute as? T {
				return modAttribute.map { String(describing: $0) } .joined(separator: ", ")
			}
		}
		return .defaultInstance
	}
	
	/**
	Returns a string describing the mod's attribute's list of values derived from the values of its releases' at the given key path.
	
	Use this if the attribute's value is a `Sequence`and `Optional` type.
	
	- Parameters:
	- keyPath: The key path to a `Release` instance's property.
	- Type: The type of the attribute.
	
	- Returns: A string describing the mod's releases' attribute's list of values, if they're the same across all the releases. Or, `"Multiple Values"`, if they're different across all the releases.
	
	- TODO: Remove the need of passing in `Type`.
	*/
	func readableAttributeElements<T: Hashable & Sequence>(forKey keyPath: PartialKeyPath<Release>, ofType Type: (T?).Type) -> String where T.Element: CustomStringConvertible {
		if let modAttribute = attribute(forKey: keyPath, as: (T?).self) {
			if let modAttribute = modAttribute as? String {
				return modAttribute
			} else if let modAttribute = modAttribute as? T {
				return modAttribute.map { String(describing: $0) } .sorted(by: <).joined(separator: ", ")
			}
		}
		return .defaultInstance
	}
	
	//	TODO: Add update(_:).
	
	/**
	Inserts a new release into the mod.
	
	The release is only inserted if it doesn't already exists.
	
	- Parameter release: The release instance to be added in this collection.
	
	- Complexity: O(_n_), where _n_ is the count of releases in the collection.
	*/
	mutating func insert(_ release: Release) {
		if !releases.contains(where: { $0.id == release.id }) {
			releases.append(release)
		}
	}
	
	/**
	Inserts a new release into the mod, then returns itself.
	
	The release is only inserted if it doesn't already exists.
	
	- Parameter release: The release instance to be added in this collection.
	
	- Returns: The mod release collection itself.
	
	- Complexity: O(_n_), where _n_ is the count of releases in the collection.
	*/
	func inserted(_ release: Release) -> Mod {
		var mod = self
		mod.insert(release)
		return mod
	}
	
	/**
	Accesses the mod release of the specified version.
	
	An existing release can be read from, and a new release writen to the mod release collection through this subscript.
	
	- Parameter version: The version of the mod release.
	
	- Returns: The mod release of the specified version.
	
	- Complexity: O(_n_), where _n_ is the count of releases in the collection.
	*/
	subscript(version: Version) -> Release? {
		get {
			releases.first(where: { $0.version == version } )
		}
		set(newRelease) {
			releases.removeAll(where: { $0.version == version } )
			if let newRelease = newRelease {
				self.insert(newRelease)
			}
		}
	}
}

//	MARK: - Collection Conformance
extension Mod: Collection {	
	
	typealias Index = Array<Release>.Index
	
	/**
	The position of the latest release in a nonempty mod rrelease collection.
	
	If the mod has no releases, `startIndex` is equal to `endIndex`.
	
	- See Also: `endIndex`.
	*/
	var startIndex: Index { releases.startIndex }
	
	/**
	The mod’s “past the end” position—i.e. the position one greater than the last valid subscript argument.
	
	When you need a range that includes the earliest release of the mod, use the half-open range operator (`..<`) with `endIndex`. The `..<` operator creates a range that doesn’t include the upper bound, so it’s always safe to use with `endIndex`.
	
	If the mod has no releases, `endIndex` is equal to `startIndex`.
	
	- See Also: `startIndex`.
	*/
	var endIndex: Index { releases.endIndex }
	
	/**
	Returns the position immediately after the given position.
	
	- Parameter position: A valid polition of the mod release collection. `position` must be less than `endIndex`.
	
	- Returns: The position value immediately after `position.`
	
	- See Also: `endIndex`.
	*/
	func index(after position: Index) -> Index { releases.index(after: position) }
	
	/**
	Accesses the mod release at the specified reverse-chronological position.
	
	This subscript provides read-only access. For write access, use `subscript(version:)`.
	
	- Parameter position: The position of the mod release to access. `position` must be a valid index of the mod release collection that is not equal to the `endIndex` property.
	
	- Returns: The mod release at the specified reverse-chronological position.
	
	- Complexity: O(1).
	
	- See Also: `endIndex`.
	*/
	subscript(position: Index) -> Release { releases[position] }
}

//	MARK: - ExpressibleByArrayLiteral Conformance
extension Mod: ExpressibleByArrayLiteral {
	init(arrayLiteral elements: Release...) {
		precondition(!elements.isEmpty, "Value of type 'Mod' can not be empty")
		self.id = elements.first!.modID
		self.releases = []
		elements.forEach {
			self.insert($0)
		}
	}
}

//	MARK: -
extension Optional: CustomStringConvertible where Wrapped: CustomStringConvertible {
	public var description: String { self != nil ? String(describing: self!) : self.debugDescription }
}
