//
//  Targets.swift
//  neuCKAN
//
//  Created by you on 20-02-14.
//  Copyleft © 2020 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import Foundation
import Cocoa
import os.log

/**
A collection of KSP installations managable by neuCKAN.
*/
struct Targets: Hashable {
	
	/**
	Initialises a collection of targets from the given sequence of target convertibles.
	
	Because of [a problem with generic default parameters][generic default parameters problem], use `init(groupVersion: Version, groupingLevel: GroupingLevel, conflictHandlingScheme: ConflictHandlingOption)` to initialise an empty collection of targets.
	
	- Parameters:
		- targets: The sequence of target convertibles to initialise the collection of targets from.
		- groupVersion: The shared version among the group members.
		- groupingLevel: The level of grouping the target is initialised for. This is mostly for the convenience of the `TargetView`'s source list's data source and delegates.
		- conflictHandlingScheme: The scheme for handeling possible targets with the same inode value in the sequence of targets.
	
	[generic default parameters problem]: https://stackoverflow.com/questions/38326992/default-parameter-as-generic-type
	*/
	init<T: Sequence>(targets: T, groupVersion: Version = Version(""), groupingLevel: GroupingLevel = .none, conflictHandlingScheme: ConflictHandlingOption = .preserveFirstOccurence) where T.Element == TargetConvertible? {
		var temporaryTargets: [Target] = []
		targets.compactMap { $0?.asTarget() } .forEach { target in
			if let oldTargetIndex = temporaryTargets.firstIndex(where: { $0.inode == target.inode } ) {
				switch conflictHandlingScheme {
				case .preserveFirstOccurence: break
				case .updatePreviousOccurence: temporaryTargets[oldTargetIndex] = target
				}
			} else {
				temporaryTargets.append(target)
			}
		}
		self.targets = temporaryTargets.sorted { $0.version >= $1.version }
		self.groupVersion = groupVersion
		self.groupingLevel = groupingLevel
	}
	
	/**
	Initialises an empty collection of targets from the given sequence of target convertibles.
	
	This initialiser exists because of [a problem with generic default parameters][generic default parameters problem]. Use `init<T: Sequence>(targets: T, groupVersion: Version, groupingLevel: GroupingLevel, conflictHandlingScheme: ConflictHandlingOption) where T.Element == Target` to initialise a non-empty collection of targets.
	
	- Parameters:
		- groupVersion: The shared version among the group members.
		- groupingLevel: The level of grouping the target is initialised for. This is mostly for the convenience of the `TargetView`'s source list's data source and delegates.
		- conflictHandlingScheme: The scheme for handeling possible targets with the same inode value in the sequence of targets.
	
	[generic default parameters problem]: https://stackoverflow.com/questions/38326992/default-parameter-as-generic-type
	*/
	init(groupVersion: Version = Version(""), groupingLevel: GroupingLevel = .none, conflictHandlingScheme: ConflictHandlingOption = .preserveFirstOccurence) {
		self.init(targets: [], groupVersion: groupVersion, groupingLevel: groupingLevel, conflictHandlingScheme: conflictHandlingScheme)
	}
	
	///	An array of targets sorted descendingly by version.
	private(set) var targets: [Target] { didSet { targets.sort { $0.version >= $1.version } } }
	//	TODO: Apply filters to mods.
	///	Mods that satisfy all targets' filtering criteria.
	var mods: Mods { Synecdoche.shared.mods }
	///	A dictionary of collections of targets grouped by their major versions.
	var majorVersionGroups: [Version: Targets] {
		Set<Version>(targets.map { Version($0.version[..<1]) } ).reduce(into: [:]) { groups, version in
			groups[version] = Targets(
				targets: targets.filter { $0.version[..<1] == version.description },
				groupVersion: version,
				groupingLevel: .major,
				conflictHandlingScheme: .updatePreviousOccurence
			)
		}
	}
	///	A dictionary of collections of targets grouped by their minor versions.
	var minorVersionGroups: [Version: Targets] {
		Set<Version>(targets.map { Version($0.version[..<2]) } ).reduce(into: [:]) { groups, version in
			groups[version] = Targets(
				targets: targets.filter { $0.version[..<2] == version.description },
				groupVersion: version,
				groupingLevel: .minor,
				conflictHandlingScheme: .updatePreviousOccurence
			)
		}
	}
	///	A dictionary of collections of targets grouped by their patch versions.
	var patchVersionGroups: [Version: Targets] {
		Set<Version>(targets.map { Version($0.version[..<3]) } ).reduce(into: [:]) { groups, version in
			groups[version] = Targets(
				targets: targets.filter { $0.version[..<3] == version.description },
				groupVersion: version,
				groupingLevel: .patch,
				conflictHandlingScheme: .updatePreviousOccurence
			)
		}
	}
	///	The shared version among group members.
	let groupVersion: Version
	///	The level this collection of targets is grouped by.
	let groupingLevel: GroupingLevel
	
	///	A collection of targets' grouping level.
	enum GroupingLevel {
		///	The top level (root level for the source list).
		case root
		///	Group by major version.
		case major
		///	Group by minor version..
		case minor
		///	Group by patch version.
		case patch
		///	Grouping is not applicable.
		case none
	}
	
	///	A collection of target's conflict-handling option during its initialisation.
	enum ConflictHandlingOption {
		///	Do not update the existing target that has the same inode value with the new target.
		case preserveFirstOccurence
		///	Always update the existing target that has the same inode value with the new target.
		case updatePreviousOccurence
	}
}

//	MARK: - Collection Conformance
extension Targets: Collection {
	
	/**
	The position of a target in the collection of targets.
	
	This is the same as `Array<Target>.Index`, which is in turn a type alias for `Int`.
	*/
	typealias Index = Array<Target>.Index
	
	/**
	The position of the first target in a nonempty collection of targets.
	
	If the collection has no targets, `startIndex` is equal to `endIndex`.
	
	- See Also: `endIndex`.
	*/
	var startIndex: Index { targets.startIndex }
	
	/**
	The collection of targets’ “past the end” position—i.e. the position one greater than the last valid subscript argument.
	
	When you need a range that includes the last target of the collection, use the half-open range operator (`..<`) with `endIndex`. The `..<` operator creates a range that doesn’t include the upper bound, so it’s always safe to use with `endIndex`.
	
	If the collection has no targets, `endIndex` is equal to `startIndex`.
	
	- See Also: `startIndex`.
	*/
	var endIndex: Index { targets.endIndex }
	
	/**
	Returns the position immediately after the given index.
	
	- Parameter i: A valid polition in the collection of targets. `i` must be less than `endIndex`.
	
	- Returns: The index value immediately after `i.`
	
	- See Also: `endIndex`.
	*/
	func index(after i: Index) -> Index { targets.index(after: i) }
	
	/**
	Inserts a target converted from the given target convertible into the collection of targets if it is not already present.
	
	- Parameter newTarget: The target convertible whose converted target is to insert into the collection of targets. `nil` is ignored.
	*/
	mutating func insert(newElement newTarget: TargetConvertible?) {
		guard let newTarget = newTarget?.asTarget() else { return }
		if !contains(where: { $0.inode == newTarget.inode } ) {
			targets.append(newTarget)
		}
	}
	
	/**
	Merges targets converted from the given sequence of target convertibles into the current collection of targets, if any of them is not already present.
	
	When multiple new targets share the same inode, the first in order among them takes precedence.
	
	- Parameter newTargets: The target convertibles whose converted targets are to insert into the collection of targets. `nil`s in the sequence are ignored.
	*/
	mutating func insert<T: Sequence>(contentsOf newTargets: T) where T.Element == TargetConvertible? {
		newTargets.forEach { insert(newElement: $0) }
	}
	
	/**
	Inserts targets at the given paths into the collection of targets if any of them is not already present.
	
	When multiple new targets share the same inode, the first in order among them takes precedence.
	
	- Parameter paths: The paths where the targets to insert into the collection of targets are. `nil`s in the sequence are ignored.
	*/
	mutating func insert<T: Sequence>(newTargetsAt paths: T) where T.Element: FileURLConvertible {
		insert(contentsOf: paths.compactMap { $0.asTarget() } )
	}
	
	/**
	Inserts a target converted from the given target convertible into the collection of targets unconditionally.
	
	- Parameter newTarget: The target convertible whose converted target is to insert into the collection of targets. `nil` is ignored.
	*/
	mutating func update(newElement newTarget: TargetConvertible?) {
		guard let newTarget = newTarget?.asTarget() else { return }
		if let oldTargetIndex = firstIndex(where: { $0.inode == newTarget.inode } ) {
			targets[oldTargetIndex] = newTarget
		} else {
			targets.append(newTarget)
		}
	}
	
	/**
	Merges targets converted from the given sequence of target convertibles into the current collection of targets unconditionally.
	
	When multiple new targets share the same inode, the last in order among them takes precedence.
	
	- Parameter newTargets: The target convertibles whose converted targets are to insert into the collection of targets. `nil`s in the sequence are ignored.
	*/
	mutating func update<T: Sequence>(contentsOf newTargets: T) where T.Element == TargetConvertible? {
		newTargets.forEach { update(newElement: $0) }
	}
	
	/**
	Merges targets at the given paths into the current collection of targets unconditionally.
	
	When multiple new targets share the same inode, the last in order among them takes precedence.
	
	- Parameter paths: The paths where the targets to insert into the collection of targets are. `nil`s in the sequence are ignored.
	*/
	mutating func update<T: Sequence>(newTargetsAt paths: T) where T.Element == FileURLConvertible {
		update(contentsOf: paths.compactMap { $0.asTarget() } )
	}
	
	/**
	Accesses the mod at the specified path.
	
	This subscript provides read-only access.
	
	- Parameter path: The path of the target to access.
	
	- Returns: The target at the specified path.
	
	- Complexity: O(1).
	*/
	private(set) subscript(path: FileURLConvertible) -> Target? {
		get {
			let kspURL = path.asFileURL()
			let resolvedPath = kspURL.standardized.resolvingSymlinksInPath()
			guard FileManager.default.fileExists(atPath: resolvedPath.absoluteString) else {
				os_log("Unable to locate KSP target: %@ does not exist.", log: .default, type: .debug, kspURL.absoluteString)
				return nil
			}
			guard let kspDirectoryAttributes = try? FileManager.default.attributesOfItem(atPath: resolvedPath.absoluteString) else {
				os_log("Unable to retrieve file attributes of %@, which is after standardising and resolving symlinks in %@.", log: .default, type: .error, resolvedPath.absoluteString, kspURL.absoluteString)
				return nil
			}
			return first(where: { $0.inode == kspDirectoryAttributes[.systemFileNumber] as! Int } )
		}
		set(newTarget) {
			update(newElement: newTarget)
		}
	}
	
	/**
	Accesses the target at the specified position.
	
	This subscript provides read-only access.
	
	- Parameter position: The position of the target to access. `position` must be a valid index of the collection of targets, that is not equal to the `endIndex` property.
	
	- Returns: The target at the specified index.
	
	- Complexity: O(1).
	
	- See Also: `endIndex`.
	*/
	private(set) subscript(position: Array<Target>.Index) -> Target {
		get { targets[position] }
		set(newTarget) { insert(newElement: newTarget) }
	}
	
}

//	MARK: - ExpressibleByArrayLiteral Conformance
extension Targets: ExpressibleByArrayLiteral {
	init(arrayLiteral elements: Target...) {
		//	FIXME: Disambiguate self.init().
//		self.init()
		self.init(targets: [])
		self.insert(contentsOf: elements)
	}
}

//	MARK: - TargetsConvertible Conformance
extension Targets: TargetsConvertible {
	/**
	Returns `self`.
	
	- Returns: `self`.
	*/
	func asTargets() -> Targets? { self }
}
