//
//	Mod.swift
//	neuCKAN
//
//	Created by you on 19-11-01.
//	Copyleft © 2019 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import Foundation

///	An ordered collection of a mod's unique releases.
///
///	A mod is identified and accessible fron an enclosing `Mods` instance by its `id`.
///
///	The read-only `releases` instance property is an array of all the releases. The releases are sorted to reverse chronological order by comparison of their versions whenever `releases` changes.
///
///	- See Also: `Mods`.
///	- See Also: `Release`.
struct Mod: Hashable, Codable, Identifiable {
	
	///	Instantiates a mod release collection from the given release.
	///	- Parameter release: The `Release` instance to from which to instantiates `Mod`.
	init(with release: Release) {
		id = release.modID
		releases = [release]
	}
	
	///Instantiates a mod release collection from inserting the given release into the given collection.
	///- Complexity: O(_n_), where _n_ is the count of existing releases in the given mod.
	init(superseding mod: Mod, with release: Release) {
		var newMod = mod
		newMod.insert(release)
		self = newMod
	}
	
	///	The mod's read-only globally unique identifier.
	///
	///	This is equivalent to the ["identifier" attribute][0] in a .ckan file.
	///
	///	This is how the mod will be referred to by other CKAN documents. It may only consist of ASCII-letters, ASCII-digits and `-` (dash).
	///
	///	For example:
	///	- "FAR"
	///	- "RealSolarSystem".
	///
	///	The identifier is used whenever the mod is referenced (by `dependencies`, `conflicts`, and elsewhere).
	///
	///	The identifier is both case sensitive for machines, and unique regardless of capitalization for human consumption and case-ignorant systems. For example: the hypothetical identifier `"MyMod"` must always be expressed as `"MyMod"` everywhere, but another module cannot assume the `"mymod"` identifier.
	///
	///	[0]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#identifier
	let id: String
	
	//	TODO: Make releases atomic for concurrent parsing.
	
	///	A collection of mod releases of the same mod.
	///	- See Also: `Release`.
	private var releases: OrderedSet<Release> {
		didSet {
//			self.releases.sort(by: { $0.version >= $1.version } )
		}
	}
	
	///	The mod's name.
	///
	///	This is the human readable name of the mod, and may contain any printable characters.
	///
	///	This is equivalent to the ["name" attribute][0] in a .ckan file.
	///
	///	For example:
	///	- "Ferram Aerospace Research (FAR)"
	///	- "Real Solar System".
	///
	///	[0]: https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#name
	var name: String { releases.max(by: { $0.version > $1.version } )?.name ?? "mod name does not exist" }
	
	//	TODO: Remove need for passing in type.
	//	FIXME: Inconsistent behaviour.
	//	FIXME: Incorrect output for some Collection types.
	
	///	Retrieves for the mod an attribute derived from the values of its releases' at the given key path.
	///
	///	- Parameters:
	///	  - keyPath: The key path to a `Release` instance's property.
	///	  - Type: The type of the attribute.
	///
	///	- Returns: The mod's releases' attribute value, if it's the same across all the releases. Or, `"Multiple Values"`, if it's different across all the releases.
	///	- TODO: Remove the need of passing in `Type`.
	func attribute<T: Hashable>(forKey keyPath: PartialKeyPath<Release>, as Type: T.Type) -> Any? {
		let latestReleaseValue = releases[0][keyPath: keyPath] as! T
		let allValuesMatch = releases.reduce(into: true) { result, release in
			let releaseValue = release[keyPath: keyPath] as! T
			result = result && (releaseValue == latestReleaseValue)
		}
		return allValuesMatch ? latestReleaseValue : "Multiple Values"
	}
	
	///	Returns a string describing the mod's attribute derived from the values of its releases' at the given key path.
	///
	///	- Parameters:
	///	  - keyPath: The key path to a `Release` instance's property.
	///	  - Type: The type of the attribute.
	///
	///	- Returns: A string describing the mod's releases' attribute value, if it's the same across all the releases. Or, `"Multiple Values"`, if it's different across all the releases.
	///	- TODO: Remove the need of passing in `Type`.
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
	
	///	Returns a string describing the mod's attribute's list of values derived from the values of its releases' at the given key path.
	///
	///	Use this if the attribute's value is a `Sequence` type.
	///
	///	- Parameters:
	///	  - keyPath: The key path to a `Release` instance's property.
	///	  - Type: The type of the attribute.
	///
	///	- Returns: A string describing the mod's releases' attribute's list of values, if they're the same across all the releases. Or, `"Multiple Values"`, if they're different across all the releases.
	///	- TODO: Remove the need of passing in `Type`.
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
	
	///	Returns a string describing the mod's attribute's list of values derived from the values of its releases' at the given key path.
	///
	///	Use this if the attribute's value is a `Sequence`and `Optional` type.
	///
	///	- Parameters:
	///	  - keyPath: The key path to a `Release` instance's property.
	///	  - Type: The type of the attribute.
	///
	///	- Returns: A string describing the mod's releases' attribute's list of values, if they're the same across all the releases. Or, `"Multiple Values"`, if they're different across all the releases.
	///	- TODO: Remove the need of passing in `Type`.
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
}

//	MARK: - OrderedCollectionOfUniqueElements Conformance
extension Mod: OrderedCollectionOfUniqueElements {
	
	//	MARK: Collection Conformance
	
	typealias Index = OrderedSet<Release>.Index
	
	///	The position of the latest release in a nonempty mod rrelease collection.
	///
	///	If the mod has no releases, `startIndex` is equal to `endIndex`.
	///
	///	- See Also: `endIndex`.
	var startIndex: Index { releases.startIndex }
	
	///	The mod’s “past the end” position—i.e. the position one greater than the last valid subscript argument.
	///
	///	When you need a range that includes the earliest release of the mod, use the half-open range operator (`..<`) with `endIndex`. The `..<` operator creates a range that doesn’t include the upper bound, so it’s always safe to use with `endIndex`.
	///
	///	If the mod has no releases, `endIndex` is equal to `startIndex`.
	///
	///	- See Also: `startIndex`.
	var endIndex: Index { releases.endIndex }
	
	///	Returns the position immediately after the given position.
	///	- Parameter position: A valid polition of the mod release collection. `position` must be less than `endIndex`.
	///	- Returns: The position value immediately after `position.`
	func index(after position: Index) -> Index { releases.index(after: position) }
	
	///	Accesses the mod release at the specified position.
	///
	///	This subscript provides both a getter and a setter, but the setter does not guarantee releases' uniqueness in result. It's advised to use `subscript(version:)` and `update(with:)` for setting a new release.
	///
	///	- Parameter position: The position of the mod release to access. `position` must be a valid index of the mod release collection that is not equal to the `endIndex` property.
	///	- Returns: The mod release at the specified reverse-chronological position.
	///	- Complexity: O(1).
	subscript(position: Index) -> Release {
		get { releases[position] }
		set(newRelease) {
			precondition(allowsMembership(of: newRelease), "A release's 'modID' must match the mod's 'id'")
			releases[position] = newRelease
		}
	}
	
	//	MARK: OrderedCollection Conformance
	
	///	Replaces the specified subrange of releases with the given collection thereof.
	///
	///	This method has the effect of removing the specified range of releases from the mod and inserting the new releases at the same location. The number of new releases need not match the number of releases being removed.
	///
	///	If you pass a zero-length range as the `subrange` parameter, this method inserts the releases of `newReleases` at `subrange.startIndex`. Calling the `insert(contentsOf:at:)` method instead is preferred.
	///
	///	Likewise, if you pass a zero-length collection as the `newReleases` parameter, this method removes the releases in the given subrange without replacement. Calling the `removeSubrange(_:)` method instead is preferred.
	///
	///	Calling this method may invalidate any existing indices for use with this mod.
	///
	///	- Parameters:
	///	  - subrange: The subrange of the mod to replace. The bounds of the range must be valid indices of the mod.
	///	  - newReleases: The new releases to add to the mod.
	///
	///	- Complexity: O(*n* + *m*), where *n* is length of this mod and *m* is the length of `newReleases`. If the call to this method simply appends the contents of `newReleases` to the mod, the complexity is O(*m*).
	mutating func replaceSubrange<C: Collection, R: RangeExpression>(_ subrange: R, with newReleases: C) where C.Element == Release, R.Bound == Index {
		releases.replaceSubrange(subrange, with: newReleases)
	}
	
	//	MARK: CollectionOfUniqueElements Conformance
	
	///	Creates an empty mod.
	///
	///	This initializer is equivalent to initializing with an empty array literal. Both result in a runtime error. This initialiser is implemented for protocol conformance only.
	///
	///	- Important: Do not call this initialiser.
	init() {
		preconditionFailure("Value of type 'Mod' can not be initialised empty.")
	}
	
	///	Creates a mod containing the releases of the given array literal.
	///
	///	Do not call this initializer directly. It is used by the compiler when you use an array literal. Instead, create a new mod using an array literal as its value by enclosing a comma-separated list of releases in square brackets. You can use an array literal anywhere a mod is expected by the type context.
	///
	///	- Parameter releases: A list of releases of the new mod.
	///	- Important: Initialising a mod using an empty array literal results in a runtime error.
	init(arrayLiteral releases: Release...) {
		self.init(releases)
	}
	
	///	Checks if the specified release is compatible as a member of this mod.
	///	- Parameter release: The release to check for.
	///	- Returns: `true` if it's possible for the specified release to exist as a member in this mod; `false` otherwise.
	func allowsMembership(of release: Release) -> Bool { release.modID == id }
	
	///	Returns a `Boolean` value that indicates whether the given release exists in the mod.
	///	- Parameter release: A release to look for in the mod.
	///	- Returns: `true` if the specified release exists in the mod; otherwise, `false`.
	func contains(_ release: Release) -> Bool { releases.contains(release) }
	
	///	Inserts the given release in the mod if it is not already present.
	///
	///	If a release equal to `newRelease` is already contained in the mod, or if `newRelease.modID` isn't equal to `self.id`, this method has no effect.
	///
	///	- Parameter newRelease: A release to insert into the mod.
	///	- Returns: `(true, newRelease)` if `newRelease` was not contained in the mod. If a release equal to `newRelease` was already contained in the mod, or if `newRelease.modID` isn't equal to `self.id`, the method returns `(false, oldRelease)`, where `oldRelease` is the release that was equal to `newRelease`. In some cases, `oldRelease` may be distinguishable from `newRelease` by identity comparison or some other means.
	@discardableResult
	mutating func insert(_ newRelease: Release) -> (inserted: Bool, memberAfterInsert: Release) {
		precondition(allowsMembership(of: newRelease), "A release's 'modID' must match the mod's 'id'")
		if let oldRelease = releases.first(where: { $0.id == newRelease.id } ) {
			return (false, oldRelease)
		} else {
			return releases.insert(newRelease)
		}
	}
	
	///	Inserts the given release into the mod unconditionally.
	///
	///	If a release whose ID equal to `newRelease.id` is already contained in the mod, `newRelease` replaces the existing release.
	///
	///	- Parameter newRelease: A release to insert into the mod.
	///	- Returns: A release whose ID is equal to `newRelease.id` if the mod already contained such a member; otherwise, `nil`. In some cases, the returned release may be distinguishable from `newRelease` by identity comparison or some other means.
	@discardableResult
	mutating func update(with newRelease: Release) -> Release? {
		precondition(allowsMembership(of: newRelease), "A release's 'modID' must match the mod's 'id'")
		releases.removeAll(where: { $0.id == newRelease.id } )
		return releases.update(with: newRelease)
	}
	
	///	Removes the given release and any releases subsumed by the given release.
	///
	///	- Parameter release: The release of the mod to remove.
	///	- Returns: A release equal to `release` if `release` is contained in the mod; otherwise, `nil`. In some cases, a returned release may be distinguishable from `release` by identity comparison or some other means.
	@discardableResult
	mutating func remove(_ release: Release) -> Release? {
		precondition(allowsMembership(of: release), "A release's 'modID' must match the mod's 'id'")
		return releases.remove(release)
	}
	
	//	MARK: Conformance Disambiguations
	
	///	Creates a new mod from a finite sequence of releases.
	///
	///	Use this initialiser to create a new mod from an existing sequence, like an array or a range, of releases.
	///
	///	- Parameter releases: The sequence of releases to use as members for the new mod. `releases` must be finite.
	init<S: Sequence>(_ releases: S) where S.Element == Element {
		let releases = Array(releases)
		precondition(!releases.isEmpty, "Value of type 'Mod' can not be initialised empty")
		precondition(releases.allSatisfy { $0.modID == releases.first!.modID } , "Releases of a Mod instance must have the same 'modID' property")
		id = releases.first!.modID
		self.releases = []
		releases.forEach {
			self.releases.insert($0)
		}
	}
	
	//	MARK: Conformance Dependants
	
	///	Accesses the mod release associated with the given version for reading and writing.
	///
	///	This _version-based_ subscript behaves similarly to that of a dictionary's. It returns the release for the given version if the version is found in the mod, or `nil` if the version is not found. When this subscript is used for modifying the mod, the user-supplied new release must either have the same version as `version`, or be `nil`. If the new release is not `nil` and its version equals to `version`, the mod is updated with the new release; If it's `nil`, the old release with the given version is removed from mod. Mismatching versions results in a runtim error.
	///
	///	- Parameter version: The version of the release to find in the mod.
	///	- Returns: The release associated with `version` if `version` is in the mod; otherwise, `nil`.
	subscript(version: CKANMetadataVersion) -> Release? {
		get {
			releases.first(where: { $0.version == version } )
		}
		set(newRelease) {
			if let newRelease = newRelease {
				precondition(newRelease.version == version, "The new release must either have the same version as specified in the subscript, or be 'nil'")
				update(with: newRelease)
			} else {
				releases.removeAll(where: { $0.version == version })
			}
		}
	}
	
}

//	MARK: -
extension Optional: CustomStringConvertible where Wrapped: CustomStringConvertible {
	public var description: String { self != nil ? String(describing: self!) : self.debugDescription }
}
