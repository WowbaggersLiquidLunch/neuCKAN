//
//  ModsViewController.swift
//  neuCKAN
//
//  Created by you on 20-01-11.
//  Copyleft © 2020 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import Cocoa
import os.log

///	A controller that manages the principle view of neuCKAN, i.e. the view showing the mod list.
class ModsViewController: NSViewController {
	//	MARK: - IBOutlet Properties
	///	The mods list view above the status view.
	@IBOutlet weak var modsListView: NSOutlineView!
	///	The status view below the mods list view.
	@IBOutlet weak var statusView: NSBox!
	///	The status message displayed in the status view.
	@IBOutlet weak var statusMessage: NSTextField!
	//	MARK: - Flags
	///	A flag indicating whether the display is hierarchical.
	private var displayIsHierarchical: Bool = true
	///	A flag indicating whether the mods list view is an outline view or a table view.
	private var modsListViewType: ViewType = .outlineView
	//	MARK: - Data
	///	A copy of	`Synecdoche.shared.mods`.
	private var synechdochicalMods = Synecdoche.shared.mods
	/// A copy of `Synecdoche.shared.selectedTargets`.
	var stagedTargets = Synecdoche.shared.selectedTargets
	//	MARK: - View Configurations
	///	An alias of `(NSTableCellView, Any) -> NSView?`.
	private typealias ColumnDrawingGuide = (NSTableCellView, Any) -> NSView?
	//	TODO: Pitch/propose adding labels for function types.
	///	An alias of `(visibility: ColumnVisibility, drawing: ColumnDrawingGuide)`.
	private typealias ColumnConfigurations = (visibility: ColumnVisibility, drawing: ColumnDrawingGuide)
	///	A map between columns' titles and their configurations.
	private var columnsConfigurations: [String: ColumnConfigurations] {
		optionalColumnsConfigurations.flatMap { $0 } .reduce(into: [:]) { $0[$1.key] = $1.value }
			.merging(mandatoryLeadingColumnsConfigurations, uniquingKeysWith: { value1, _ in value1 } )
			.merging(mandatoryOutlineViewTrailingColumnsConfigurations, uniquingKeysWith: { value1, _ in value1 } )
	}
	///	A map between mandatorily visible leading columns' titles and their configurations.
	private let mandatoryLeadingColumnsConfigurations: [String: ColumnConfigurations] = [
		"Name":
			(.visible, { cell, item in
				if let mod = item as? Mod {
					cell.textField?.stringValue = mod.name
				} else if let release = item as? Release {
					cell.textField?.stringValue = release.name
				}
				return cell
			})
	]
	//	FIXME: Fix empty and "nil" cells.
	///	A map between optionally visible columns' titles and their configurations.
	private var optionalColumnsConfigurations: [OrderedDictionary<String, ColumnConfigurations>] = [
		[
			"CKAN Meta Spec Version": (
				.hidden,  { cell, item in
					if let mod = item as? Mod {
						cell.textField?.stringValue = mod.readableAttribute(forKey: \Release.ckanMetadataSpecificationVersion, ofType: Version.self)
					} else if let release = item as? Release {
						cell.textField?.stringValue = String(describing: release.ckanMetadataSpecificationVersion)
					}
					return cell
			})
		],
		[
			"ID": (
				.hidden,  { cell, item in
					if let mod = item as? Mod {
						cell.textField?.stringValue = mod.id
					} else if let release = item as? Release {
						cell.textField?.stringValue = release.modID
					}
					return cell
			}),
			"Abstract": (
				.visible, { cell, item in
					if let mod = item as? Mod {
						cell.textField?.stringValue = mod.readableAttribute(forKey: \Release.abstract, ofType: String.self)
					} else if let release = item as? Release {
						cell.textField?.stringValue = release.abstract
					}
					return cell
			}),
			"Description": (
				.hidden,  { cell, item in
					if let mod = item as? Mod {
						cell.textField?.stringValue = mod.readableAttribute(forKey: \Release.description, ofType: (String?).self)
					} else if let release = item as? Release, let releaseDescription = release.description {
						cell.textField?.stringValue = releaseDescription
					}
					return cell
			}),
			"Tags": (
				.visible, { cell, item in
					if let mod = item as? Mod {
						cell.textField?.stringValue = mod.readableAttributeElements(forKey: \Release.tags, ofType: (Set<String>?).self)
					} else if let release = item as? Release, let releaseTags = release.tags {
						cell.textField?.stringValue = releaseTags.joined(separator: ", ")
					}
					return cell
			}),
			"Author(s)": (
				.hidden,  { cell, item in
					if let mod = item as? Mod {
						cell.textField?.stringValue = mod.readableAttribute(forKey: \Release.authors, ofType: (CKANFuckery<String>?).self)
					} else if let release = item as? Release, let releaseAuthors = release.authors {
						cell.textField?.stringValue = String(describing: releaseAuthors)
					}
					return cell
			}),
			"Licence(s)": (
				.hidden,  { cell, item in
					if let mod = item as? Mod {
						cell.textField?.stringValue = mod.readableAttribute(forKey: \Release.licences, ofType: CKANFuckery<String>.self)
					} else if let release = item as? Release {
						cell.textField?.stringValue = String(describing: release.licences)
					}
					return cell
			}),
			"Supported Languages": (
				.hidden,  { cell, item in
					if let mod = item as? Mod {
						cell.textField?.stringValue = mod.readableAttribute(forKey: \Release.locales, ofType: (Set<String>?).self)
					} else if let release = item as? Release, let releasesLocales = release.locales {
						cell.textField?.stringValue = releasesLocales.joined(separator: ", ")
					}
					return cell
			}),
			"Release Status": (
				.hidden,  { cell, item in
					if let mod = item as? Mod {
						cell.textField?.stringValue = mod.readableAttribute(forKey: \Release.status, ofType: (String?).self)
					} else if let release = item as? Release, let releaseStstus = release.status {
						cell.textField?.stringValue = releaseStstus
					}
					return cell
			}),
			"Version": (
				.visible, { cell, item in
					if let mod = item as? Mod {
						cell.textField?.stringValue = mod.readableAttribute(forKey: \Release.version, ofType: Version.self)
					} else if let release = item as? Release {
						cell.textField?.stringValue = String(describing: release.version)
					}
					return cell
			})
		],
		[
			"Supported KSP Versions": (
				.visible, { cell, item in
					if let mod = item as? Mod {
						cell.textField?.stringValue = mod.readableAttribute(forKey: \Release.kspVersionRequirement, ofType: Requirement.self)
					} else if let release = item as? Release {
						cell.textField?.stringValue = String(describing: release.kspVersionRequirement)
					}
					return cell
			}),
			"Dependencies": (
				.hidden,  { cell, item in
					if let mod = item as? Mod {
						cell.textField?.stringValue = mod.readableAttribute(forKey: \Release.dependencies, ofType: (Requirements?).self)
					} else if let release = item as? Release, let releaseDependencies = release.dependencies {
						cell.textField?.stringValue = String(describing: releaseDependencies)
					}
					return cell
			}),
			"Conflicts": (
				.hidden,  { cell, item in
					if let mod = item as? Mod {
						cell.textField?.stringValue = mod.readableAttribute(forKey: \Release.conflicts, ofType: (Requirements?).self)
					} else if let release = item as? Release, let releaseConflicts = release.conflicts {
						cell.textField?.stringValue = String(describing: releaseConflicts)
					}
					return cell
			})
		],
		[
			"Download Link": (
				.hidden,  { cell, item in
					if let mod = item as? Mod {
						cell.textField?.stringValue = mod.readableAttribute(forKey: \Release.downloadLink, ofType: URL.self)
					} else if let release = item as? Release {
						cell.textField?.stringValue = release.downloadLink.absoluteString
					}
					return cell
			}),
			"Home Page": (
				.hidden,  { cell, item in
					if let mod = item as? Mod {
						cell.textField?.stringValue = mod.readableAttribute(forKey: \Release.resources?.homepage, ofType: (URL?).self)
					} else if let release = item as? Release, let releaseHomePage = release.resources?.homepage {
						cell.textField?.stringValue = releaseHomePage.absoluteString
					}
					return cell
			}),
			"Repository": (
				.hidden,  { cell, item in
					if let mod = item as? Mod {
						cell.textField?.stringValue = mod.readableAttribute(forKey: \Release.resources?.repository, ofType: (URL?).self)
					} else if let release = item as? Release, let releaseRepository = release.resources?.repository {
						cell.textField?.stringValue = releaseRepository.absoluteString
					}
					return cell
			}),
			"SpaceDock": (
				.hidden,  { cell, item in
					if let mod = item as? Mod {
						cell.textField?.stringValue = mod.readableAttribute(forKey: \Release.resources?.spaceDock, ofType: (URL?).self)
					} else if let release = item as? Release, let releaseSpacedock = release.resources?.spaceDock {
						cell.textField?.stringValue = releaseSpacedock.absoluteString
					}
					return cell
			}),
			"CurseForge": (
				.hidden,  { cell, item in
					if let mod = item as? Mod {
						cell.textField?.stringValue = mod.readableAttribute(forKey: \Release.resources?.curseForge, ofType: (URL?).self)
					} else if let release = item as? Release, let releaseCurse = release.resources?.curseForge {
						cell.textField?.stringValue = releaseCurse.absoluteString
					}
					return cell
			}),
			"Continuous Integration": (
				.hidden,  { cell, item in
					if let mod = item as? Mod {
						cell.textField?.stringValue = mod.readableAttribute(forKey: \Release.resources?.ci, ofType: (URL?).self)
					} else if let release = item as? Release, let releaseCI = release.resources?.ci {
						cell.textField?.stringValue = releaseCI.absoluteString
					}
					return cell
			}),
			"Bug Tracker": (
				.hidden,  { cell, item in
					if let mod = item as? Mod {
						cell.textField?.stringValue = mod.readableAttribute(forKey: \Release.resources?.bugTracker, ofType: (URL?).self)
					} else if let release = item as? Release, let releaseBugTracker = release.resources?.bugTracker {
						cell.textField?.stringValue = releaseBugTracker.absoluteString
					}
					return cell
			}),
			"Manual": (
				.hidden,  { cell, item in
					if let mod = item as? Mod {
						cell.textField?.stringValue = mod.readableAttribute(forKey: \Release.resources?.manual, ofType: (URL?).self)
					} else if let release = item as? Release, let releaseManual = release.resources?.manual {
						cell.textField?.stringValue = releaseManual.absoluteString
					}
					return cell
			}),
			"netkan": (
				.hidden,  { cell, item in
					if let mod = item as? Mod {
						cell.textField?.stringValue = mod.readableAttribute(forKey: \Release.resources?.netkan, ofType: (URL?).self)
					} else if let release = item as? Release, let releaseNetkan = release.resources?.netkan {
						cell.textField?.stringValue = releaseNetkan.absoluteString
					}
					return cell
			})
		]
	]
	///	A map between mandatorily visible trailing columns' titles and their configurations.
	private let mandatoryOutlineViewTrailingColumnsConfigurations: [String: ColumnConfigurations] = [
		"Action": (
			.visible, { cell, item in
				guard let modReleaseManagementCell = cell as? ModReleaseManagementCellView else { return cell }
				if let mod = item as? Mod {
					modReleaseManagementCell.managedInstanceType = .mod(mod)
				} else if let release = item as? Release {
					modReleaseManagementCell.managedInstanceType = .release(release)
				}
				modReleaseManagementCell.state = .uninstalled
				modReleaseManagementCell.managedTargets = Synecdoche.shared.selectedTargets
				return modReleaseManagementCell
		})
	]
	///	All columns' titles.
	private var columnsTitles: [String] { [String](columnsConfigurations.keys) }
	///	Mandatorily visible leading columns' titles.
	private var mandatoryLeadingColumnsTitles: [String] { [String](mandatoryLeadingColumnsConfigurations.keys) }
	///	Optionally visible columns' titles.
	private var optionalColumnsTitles: [[String]] { optionalColumnsConfigurations.map { $0.map { $0.key } } }
	///	Mandatorily visible trailing columns' titles.
	private var mandatoryOutlineViewTrailingColumnsTitles: [String] { [String](mandatoryOutlineViewTrailingColumnsConfigurations.keys) }
	///	Menu options for showing/hiding columns.
	private var columnsMenuItems: [NSMenuItem] {
		var menuItems: [NSMenuItem] = []
		optionalColumnsConfigurations.forEach {
			$0.forEach {
				let menuItem = NSMenuItem(title: $0.key, action: #selector(toggleColumnVisibility(_:)), keyEquivalent: "")
				menuItem.identifier = NSUserInterfaceItemIdentifier(rawValue: $0.key.trimmingCharacters(in: .whitespaces) + "MenuItem")
				menuItem.state = $0.value.visibility == .visible ? .on : .off
				menuItems.append(menuItem)
			}
			menuItems.append(NSMenuItem.separator())
		}
		menuItems.removeLast()
		return menuItems
	}
	
	//	MARK: - Nested Types
	
	///	The mods list view's type.
	private enum ViewType {
		case outlineView
		case tableView
	}
	///	A column's visibility.
	private enum ColumnVisibility {
		case visible
		case hidden
	}
	//	TODO: Implement sorting rule structure.
	//	TODO: Record sorting rule.
	///	A column's sorting direction.
	enum SortingDirection {
		///	No sorting.
		case neural
		///	Sort ascendingly.
		case ascending
		///	Sort descendingly.
		case descending
	}
	///	An ordered collection whose elements are key-value pairs.
	private struct OrderedDictionary<Key: Hashable, Value>: ExpressibleByDictionaryLiteral, Collection {
		/// The position of a key-value pair in an ordered dictionary.
		typealias Index = Array<(key: Key, value: Value)>.Index
		///	Creates an ordered dictionary initialized with a dictionary literal.
		init(dictionaryLiteral elements: (Key, Value)...) {
			keyValuePairs = elements.map { (key: $0.0, value: $0.1) }
		}
		///	The key-value pairs in the ordered dictionary.
		private var keyValuePairs: [(key: Key, value: Value)]
		///	An array containing just the keys of the ordered dictionary.
		var keys: [Key] { keyValuePairs.map { $0.key } }
		///	An array containing just the values of the ordered dictionary.
		var values: [Value] { keyValuePairs.map { $0.value } }
		///	The position of the first element in a nonempty ordered dictionary.
		///
		///	If the ordered dictionary has no key-value pairs, `startIndex` is equal to `endIndex`.
		///
		///	- See Also: `endIndex`.
		var startIndex: Index { keyValuePairs.startIndex }
		///	The ordered dictionary's “past the end” position—i.e. the position one greater than the last valid subscript argument.
		///
		///	If the ordered dictionary has no key-value pairs, `endIndex` is equal to `startIndex`.
		///
		///	- See Also: `startIndex`.
		var endIndex: Index { keyValuePairs.endIndex}
		///	Returns the position immediately after the given index.
		///	- Parameter i: A valid polition in the ordered dictionary. `i` must be less than `endIndex`.
		///	- Returns: The index value immediately after `i.`
		///	- See Also: `endIndex`.
		func index(after i: Index) -> Index { keyValuePairs.index(after: i) }
		///	Accesses the key-value pair at the specified position.
		///	This subscript provides read-only access. For write access, use `subscript(key:)`.
		///	- Parameter position: The position of the key-value pair to access. `position` must be a valid index of the ordered dictionary that is not equal to the `endIndex` property.
		///	- Returns: The key-value pair at the specified index.
		///	- Complexity: O(1).
		///	- See Also: `subscript(key:)`.
		///	- See Also: `endIndex`.
		subscript(position: Index) -> (key: Key, value: Value) { keyValuePairs[position] }
		///	Accesses the value associated with the given key for reading and writing.
		///	- Parameter key: The key to find in the ordered dictionary.
		///	- Returns: The value associated with key if key is in the ordered dictionary; otherwise, nil.
		subscript(key: Key) -> Value? {
			get {
				keyValuePairs.first(where: { $0.key == key })?.value
			}
			set(value) {
				precondition(value != nil, "Value can not be nil")
				if let index = keyValuePairs.firstIndex(where: { $0.key == key } ) {
					keyValuePairs[index].value = value!
				} else {
					keyValuePairs.append((key: key, value: value!))
				}
			}
		}
	}
	
	//	MARK: - View Life Cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
		modsListView.tableColumns.forEach {
			guard optionalColumnsTitles.flatMap { $0 } .contains($0.title) else { return }
			restoreConfigurations(of: $0)
		}
		modsListView.dataSource = self
		modsListView.delegate = self
//		setupModsListView(as: .outlineView)
		setupMenuBarMenus()
		setupContextualMenus()
		NotificationCenter.default.addObserver(self, selector: #selector(modsCacheDidUpdate(_:)), name: .modsCacheDidUpdate, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(targetsSelectionDidChange(_:)), name: .targetsSelectionDidChange, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(userDidInitiateModsLayoutChange(_:)), name: .userDidInitiateModsLayoutChange, object: nil)
		updateColumnsAttributes()
	}
	
	override func viewWillAppear() {
		super.viewWillAppear()
	}
	
	override func viewDidAppear() {
		super.viewDidAppear()
		NotificationCenter.default.post(name: .modsLayoutDidChange, object: displayIsHierarchical)
	}
	
	//	MARK: -
	
	override var representedObject: Any? {
		didSet {
			// Update the view, if already loaded.
		}
	}
	
	///	Restores a column's configurations from the previous neuCKAN session.
	///	Parameter column: The column whose configurations need restoring.
	private func restoreConfigurations(of column: NSTableColumn) {
		if columnsTitles.contains(column.title) {
			restoreVisibility(of: column)
		}
	}
	///	Restores a column's visibility from the previous neuCKAN session.
	///	- Parameter column: The column whose visibility needs restoring.
	private func restoreVisibility(of column: NSTableColumn) {
		guard let index = optionalColumnsConfigurations.firstIndex(where: { $0.keys.contains(column.title) } ) else {
			os_log("Unable to locate configurations for column with title \"%@\".", log: .default, type: .error, column.title)
			return
		}
		optionalColumnsConfigurations[index][column.title]?.visibility = column.isHidden ? .hidden : .visible
	}
	///	Sets up mods list view to the given view type.
	///	- Parameter viewType: The view type to set up the mods list view to.
	private func setupModsListView(as viewType: ViewType) {
//		switch viewType {
//		case .outlineView:
//
//		case .tableView:
//
//		default:
//			<#code#>
//		}
	}
	///	Sets up menu bar menus.
	private func setupMenuBarMenus() {
		guard let columnsMenu = NSApp.mainMenu?.item(withTitle: "View")?.submenu?.item(withTitle: "Columns")?.submenu else {
			os_log("No \"Columns\" menu item in \"View\" menu in application menu bar.", log: .default, type: .error)
			return
		}
		columnsMenu.removeAllItems()
		columnsMenuItems.forEach { columnsMenu.addItem($0) }
	}
	///	Sets up contextual menus.
	private func setupContextualMenus() {
		//	MARK: Header Contextual Menu
		modsListView.headerView!.menu = NSMenu()
		columnsMenuItems.forEach { modsListView.headerView!.menu!.addItem($0) }
		//	MARK: Body Contextual Menu
		modsListView.menu = NSMenu()
		modsListView.menu!.addItem(NSMenuItem(title: "Refresh Mods Data", action: #selector(updateModsCache(_:)), keyEquivalent: "R"))
		//	TODO: Add menu item for toggle between table view and outline view
//		contextualMenu.addItem(NSMenuItem(title: (mode == table ? "View as Hierachical List" : "View as Table"), action: <#T##Selector?#>, keyEquivalent: <#T##String#>))
	}
	///	Toggles a column's visibility.
	///	- Parameter menuItem: The menu item that calls this method.
	@objc func toggleColumnVisibility(_ menuItem: NSMenuItem) {
		//	FIXME: Actually toggle state in menu.
		guard let index = optionalColumnsConfigurations.firstIndex(where: { $0.keys.contains(menuItem.title) } ) else {
			os_log("Unable to locate configurations for column with title \"%@\".", log: .default, type: .error, menuItem.title)
			return
		}
		let visibility = optionalColumnsConfigurations[index][menuItem.title]?.visibility
		optionalColumnsConfigurations[index][menuItem.title]?.visibility = visibility == .hidden ? .visible : .hidden
		updateColumnsAttributes()
		setupMenuBarMenus()
		setupContextualMenus()
	}
	///	Updates columns' attributes.
	private func updateColumnsAttributes() {
		modsListView.tableColumns.forEach {
			updateVisibility(of: $0)
		}
//		modsListView.tableColumn(withIdentifier: NSUserInterfaceItemIdentifier("NameColumn"))?.sizeToFit()
		modsListView.sizeToFit()
	}
	///	Updates a column's visibility to align with its record in `columnsConfigurations`.
	///	- Parameter column: The column whose visibility needs updating.
	private func updateVisibility(of column: NSTableColumn) {
		guard columnsTitles.contains(column.title) else { column.isHidden = true; return }
		column.isHidden = columnsConfigurations[column.title]!.visibility == .hidden
	}
	///	Refreshes CKAN metadata.
	///	- Parameter menuItem: The menu item that calls this method.
	@objc func updateModsCache(_ menuItem: NSMenuItem) {
		GC.shared.updateModsCache()
	}
	///	Called after `Synecdoche.shared.mods` has changed.
	///	- Parameter notification: The notification of `Synecdoche.shared.mods` having been changed.
	@objc func modsCacheDidUpdate(_ notification: Notification) {
		//	TODO: Throw an error.
		guard let updatedMods = notification.object as? Mods else { return }
		DispatchQueue.main.async {
			self.synechdochicalMods = updatedMods
			self.modsListView.reloadData()
		}
	}
	///	Called after `Synecdoche.shared.selectedTargets` has changed.
	///	- Parameter notification: The notification of `Synecdoche.shared.selectedTargets` having been changed.
	@objc func targetsSelectionDidChange(_ notification: Notification) {
		//	TODO: Throw an error.
		guard let newTargetSelection = notification.object as? Targets else { return }
		DispatchQueue.main.async {
			self.stagedTargets = newTargetSelection
			self.modsListView.reloadData()
		}
	}
	/// Called after the mods view controller receives a notification that the user initiated a mods layout change.
	/// - Parameter notification: The notification that the user initiated a mods layout change.
	@objc func userDidInitiateModsLayoutChange(_ notification: Notification) {
		displayIsHierarchical.toggle()
		modsListView.reloadData()
		NotificationCenter.default.post(name: .modsLayoutDidChange, object: displayIsHierarchical)
	}
}

//	MARK: - NSOutlineViewDataSource Conformance
extension ModsViewController: NSOutlineViewDataSource {
	//
	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		if item == nil {
			return stagedTargets.mods.count
		} else if let modReleases = item as? Mod, displayIsHierarchical {
			return modReleases.count > 1 ? modReleases.count : 0
		} else {
			return 0
		}
	}
	//
	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		if item == nil {
			let mod = stagedTargets.mods[index]
			return mod.count > 1 ? mod : mod.first ?? 0
		} else if let modReleases = item as? Mod, displayIsHierarchical {
			return modReleases[index]
		} else {
			return 0
		}
	}
	//
	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		displayIsHierarchical && item is Mod
	}
}

//	MARK: - NSOutlineViewDelegate Conformance
extension ModsViewController: NSOutlineViewDelegate {
	//
	func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		guard let columnTitle = tableColumn?.title, columnsTitles.contains(columnTitle) else { return nil }
		let cellID = NSUserInterfaceItemIdentifier(columnTitle.trimmingCharacters(in: .whitespaces) + "ColumnCell")
		guard let cell = outlineView.makeView(withIdentifier: cellID, owner: nil) as? NSTableCellView else { return nil }
		return columnsConfigurations[columnTitle]!.drawing(cell, item)
	}
	//	TODO: Handle deselection.
	//
	func outlineViewSelectionDidChange(_ notification: Notification) {
		guard notification.object as? NSOutlineView == modsListView else { return }
		//	TODO: Handle multiple selections.
		if modsListView.numberOfSelectedRows == 1 {
			let item = modsListView.item(atRow: modsListView.selectedRow)
			NotificationCenter.default.post(name: .modReleaseSelectionDidChange, object: item as? Release ?? item as? Mod ?? nil)
		} else if modsListView.numberOfSelectedRows > 1 {
			
		}
	}
}

//	MARK: - NSUserInterfaceValidations Conformance
//	TODO: Embelish. Elaborate.
extension ModsViewController: NSUserInterfaceValidations {
	func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
		true
	}
}

fileprivate extension NSControl.StateValue {
	///	Toggles a control's state.
	mutating func toggle() {
		switch self {
		case .on, .mixed: self = .off
		case .off: self = .on
		default: break
		}
	}
}

fileprivate extension NSMenuItem {
	
	func enable() {
		isEnabled = true
	}
	
	func enabled() -> NSMenuItem {
		self.enable()
		return self
	}
}
