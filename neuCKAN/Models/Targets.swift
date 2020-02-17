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

struct Targets: Hashable {
	
	/**
	Initialises a collection of targets from the given sequence of targets.
	
	Because of [this problem][generic default parameter problem], use `init(groupingLevel: GroupingLevel = .none, conflictHandlingScheme: ConflictHandlingOption = .preserveFirstOccurence)` to initialise an empty collection of targets.
	
	- Parameters:
		- targets: The sequence of targets to initialise the collection of targets from.
		- groupingLevel: The level of grouping the target is initialised for. This is mostly for the convenience of the `TargetView`'s source list's data source and delegates.
		- conflictHandlingScheme: The scheme for handeling possible targets with the same inode value in the sequence of targets.
	
	[generic default parameter problem]: https://stackoverflow.com/questions/38326992/default-parameter-as-generic-type
	*/
	init<T: Sequence>(targets: T, groupingLevel: GroupingLevel = .none, conflictHandlingScheme: ConflictHandlingOption = .preserveFirstOccurence) where T.Element == Target {
		var temporaryTargets: [Target] = []
		targets.forEach { target in
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
		self.groupingLevel = groupingLevel
	}
	
	/**
	Initialises an empty collection of targets from the given sequence of targets.
	
	This initialiser exists because of [this problem][generic default parameter problem]. Use `init<T: Sequence>(targets: T, groupingLevel: GroupingLevel = .none, conflictHandlingScheme: ConflictHandlingOption = .preserveFirstOccurence) where T.Element == Target` to initialise a non-empty collection of targets.
	
	- Parameters:
		- groupingLevel: The level of grouping the target is initialised for. This is mostly for the convenience of the `TargetView`'s source list's data source and delegates.
		- conflictHandlingScheme: The scheme for handeling possible targets with the same inode value in the sequence of targets.
	
	[generic default parameter problem]: https://stackoverflow.com/questions/38326992/default-parameter-as-generic-type
	*/
	init(groupingLevel: GroupingLevel = .none, conflictHandlingScheme: ConflictHandlingOption = .preserveFirstOccurence) {
		self.init(targets: [Target](), groupingLevel: groupingLevel, conflictHandlingScheme: conflictHandlingScheme)
	}
	
	///	An array of targets sorted descendingly by version.
	private var targets: [Target] { didSet { targets.sort { $0.version >= $1.version } } }
	///	A dictionary of collections of targets grouped by their major versions.
	private var majorVersionGroup: [Version: Targets] {
		Set<Version>(targets.map { Version($0.version[..<1]) } ).reduce(into: [:]) { groups, version in
			groups[version] = Targets(targets: targets.filter { $0.version[..<1] == version.description }, groupingLevel: .major, conflictHandlingScheme: .updatePreviousOccurence)
		}
	}
	///	A dictionary of collections of targets grouped by their minor versions.
	private var minorVersionGroups: [Version: Targets] {
		Set<Version>(targets.map { Version($0.version[..<2]) } ).reduce(into: [:]) { groups, version in
			groups[version] = Targets(targets: targets.filter { $0.version[..<2] == version.description }, groupingLevel: .minor, conflictHandlingScheme: .updatePreviousOccurence)
		}
	}
	///	A dictionary of collections of targets grouped by their patch versions.
	private var patchVersionGroup: [Version: Targets] {
		Set<Version>(targets.map { Version($0.version[..<3]) } ).reduce(into: [:]) { groups, version in
			groups[version] = Targets(targets: targets.filter { $0.version[..<3] == version.description }, groupingLevel: .patch, conflictHandlingScheme: .updatePreviousOccurence)
		}
	}
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

//	MARK: Collection Conformance
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
	
	- Parameter position: A valid polition in the collection of targets. `i` must be less than `endIndex`.
	
	- Returns: The index value immediately after `i.`
	
	- See Also: `endIndex`.
	*/
	func index(after i: Index) -> Index { targets.index(after: i) }
	
	/**
	Inserts the given target into the collection of targets if it is not already present.
	
	- Parameter newTarget: The target to insert into the collection of targets. `nil` is ignored.
	*/
	mutating func insert(newElement newTarget: Target?) {
		guard let newTarget = newTarget else { return }
		if !contains(where: { $0.inode == newTarget.inode } ) {
			targets.append(newTarget)
		}
	}
	
	/**
	Merges the given sequence of targets into the current collection of targets, if any of them is not already present.
	
	When multiple new targets share the same inode, the first in order among them takes precedence.
	
	- Parameter newTargets: The target to insert into the collection of targets. Targets that are `nil` in the sequence are ignored.
	*/
	mutating func insert<T: Sequence>(contentsOf newTargets: T) where T.Element == Target? {
		newTargets.forEach { insert(newElement: $0) }
	}
	
	/**
	Inserts the given target into the collection of targets unconditionally.
	
	- Parameter newTarget: The target to insert into the collection of targets. `nil` is ignored.
	*/
	mutating func update(newElement newTarget: Target?) {
		guard let newTarget = newTarget else { return }
		if let oldTargetIndex = firstIndex(where: { $0.inode == newTarget.inode } ) {
			targets[oldTargetIndex] = newTarget
		} else {
			targets.append(newTarget)
		}
	}
	
	/**
	Merges the given sequence of targets into the current collection of targets unconditionally.
	
	When multiple new targets share the same inode, the last in order among them takes precedence.
	
	- Parameter newTargets: The target to insert into the collection of targets. Targets that are `nil` in the sequence are ignored.
	*/
	mutating func update<T: Sequence>(contentsOf newTargets: T) where T.Element == Target? {
		newTargets.forEach { update(newElement: $0) }
	}
	
	/**
	Accesses the mod at the specified path.
	
	This subscript provides read-only access.
	
	- Parameter path: The path of the target to access.
	
	- Returns: The target at the specified path.
	
	- Complexity: O(1).
	*/
	private(set) subscript(path: URL) -> Target? {
		get {
			let resolvedPath = path.standardizedFileURL.resolvingSymlinksInPath()
			guard FileManager.default.fileExists(atPath: resolvedPath.absoluteString) else {
				os_log("Unable to locate KSP target: %@ does not exist.", log: .default, type: .debug, path.absoluteString)
				return nil
			}
			guard let kspDirectoryAttributes = try? FileManager.default.attributesOfItem(atPath: resolvedPath.absoluteString) else {
				os_log("Unable to retrieve file attributes of %@, which is after standardising and resolving symlinks in %@.", log: .default, type: .error, resolvedPath.absoluteString, path.absoluteString)
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
