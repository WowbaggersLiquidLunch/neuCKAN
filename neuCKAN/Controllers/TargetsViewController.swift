//
//  TargetsViewController.swift
//  neuCKAN
//
//  Created by you on 20-01-11.
//  Copyleft © 2020 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import Cocoa
import Combine
import SwiftUI
import os.log

///	A controller that manages the targets view of neuCKAN.
class TargetsViewController: NSViewController {
	//	MARK: - IBOutlet Properties
	///	The targets source list view.
	@IBOutlet weak var targetsSourceListView: NSOutlineView!
	//	MARK: -
	///	A flag indicating whether targets are grouped by their major versions.
	@Published private var targetsAreGroupedByMajorVersion: Bool = false {
		didSet { targetsSourceListView.reloadData() }
	}
	///	A flag indicating whether targets are grouped by their minor versions.
	@Published private var targetsAreGroupedByMinorVersion: Bool = false {
		didSet { targetsSourceListView.reloadData() }
	}
	///	A flag indicating whether targets are grouped by their patch versions.
	@Published private var targetsAreGroupedByPatchVersion: Bool = false {
		didSet { targetsSourceListView.reloadData() }
	}
	
	//	MARK: - Data
	private var synecdochicalTargets = Synecdoche.shared.targets
	//	FIXME: Grouping options don't work.
	///	Menu options for grouping targets by their versions.
	private let groupingMenuItems: [NSMenuItem] = [
		NSMenuItem(title: "Major Version", action: #selector(toggleMajorGrouping(_:)), keyEquivalent: ""),
		NSMenuItem(title: "Minor Version", action: #selector(toggleMinorGrouping(_:)), keyEquivalent: ""),
		NSMenuItem(title: "Patch Version", action: #selector(togglePatchGrouping(_:)), keyEquivalent: "")
	]
	//	MARK: -
	//
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
		targetsSourceListView.dataSource = self
		targetsSourceListView.delegate = self
		setupMenus()
		NotificationCenter.default.addObserver(self, selector: #selector(targetsDataDidUpdate(_:)), name: .targetsDataDidUpdate, object: nil)
	}
	//
	override var representedObject: Any? {
		didSet {
			// Update the view, if already loaded.
		}
	}
	
	//	TODO: Add menu bar menu and contextual menu.
	///	Sets up menus.
	private func setupMenus() {
//		setupMenuBarMenus()
		setupContextualMenus()
	}
	//	FIXME: Setting up menu bar menus break app UI.
	///	Sets up menu bar menus.
	private func setupMenuBarMenus() {
		guard let targetsMenu = NSApp.mainMenu?.item(withTitle: "File")?.submenu?.item(withTitle: "KSP Targets")?.submenu else {
			os_log("No \"KSP Targets\" Menu Found in \"File\" menu in application menu bar..", log: .default, type: .error)
			return
		}
		targetsMenu.removeAllItems()
		targetsMenu.addItem(NSMenuItem(title: "Add...", action: #selector(addTargets(_:)), keyEquivalent: ""))
		targetsMenu.addItem(NSMenuItem(title: "Add Recent", action: nil, keyEquivalent: ""))
		targetsMenu.addItem(NSMenuItem.separator())
		targetsMenu.addItem(NSMenuItem(title: "Remove", action: nil, keyEquivalent: ""))
		targetsMenu.addItem(NSMenuItem.separator())
		targetsMenu.addItem(NSMenuItem(title: "Reload", action: #selector(reloadTargets(_:)), keyEquivalent: ""))
		targetsMenu.addItem(NSMenuItem.separator())
		targetsMenu.addItem(NSMenuItem(title: "Group By", action: nil, keyEquivalent: ""))
		let addRecentMenu = NSMenu()
		targetsMenu.item(withTitle: "Add Recent")!.submenu = addRecentMenu
		//	TODO: Add menu items for "Add Recent" menu.
		let removeMenu = NSMenu()
		targetsMenu.item(withTitle: "Remove")!.submenu = removeMenu
		//	TODO: Add menu items for "Remove" menu.
		let groupingMenu = NSMenu()
		targetsMenu.item(withTitle: "Group By")!.submenu = groupingMenu
		groupingMenuItems.forEach { groupingMenu.addItem($0) }
	}
	///	Sets up contextual menus.
	private func setupContextualMenus() {
		let contextualMenu = NSMenu()
		targetsSourceListView.menu = contextualMenu
		contextualMenu.addItem(NSMenuItem(title: "Add KSP Targets...", action: #selector(addTargets(_:)), keyEquivalent: ""))
		contextualMenu.addItem(NSMenuItem(title: "Reload KSP Targets", action: #selector(reloadTargets(_:)), keyEquivalent: ""))
		contextualMenu.addItem(NSMenuItem(title: "Group By", action: nil, keyEquivalent: ""))
		let groupingMenu = NSMenu()
		contextualMenu.item(withTitle: "Group By")!.submenu = groupingMenu
		groupingMenuItems.forEach { groupingMenu.addItem($0) }
		
	}
	///	Asks user for additional KSP targets, then adds them.
	///	- Parameter menuItem: The menu item that calls this method.
	@IBAction private func addTargets(_ menuItem: NSMenuItem) {
		let targetsSelectionPanel = NSOpenPanel()
		targetsSelectionPanel.canChooseFiles = false
		targetsSelectionPanel.canChooseDirectories = true
		targetsSelectionPanel.resolvesAliases = false
		targetsSelectionPanel.allowsMultipleSelection = true
		targetsSelectionPanel.begin { response in
			guard response == NSApplication.ModalResponse.OK else { return }
			GC.shared.addTargets(at: targetsSelectionPanel.urls)
		}
	}
	//	TODO: Actually refresh targets.
	///	Reloads targets.
	///	- Parameter menuItem: The menu item that calls this method.
	@IBAction private func reloadTargets(_ menuItem: NSMenuItem) {
		GC.shared.reloadTargets()
	}
	///	Toggles whether targets are grouped by their major versions.
	///	- Parameter menuItem: The menu item that calls this method.
	@objc private func toggleMajorGrouping(_ menuItem: NSMenuItem) {
		targetsAreGroupedByMajorVersion.toggle()
		menuItem.state = NSControl.StateValue(rawValue: targetsAreGroupedByMajorVersion ? 1 : 0)
	}
	///	Toggles whether targets are grouped by their minor versions.
	///	- Parameter menuItem: The menu item that calls this method.
	@objc private func toggleMinorGrouping(_ menuItem: NSMenuItem) {
		targetsAreGroupedByMajorVersion.toggle()
		menuItem.state = NSControl.StateValue(rawValue: targetsAreGroupedByMinorVersion ? 1 : 0)
	}
	///	Toggles whether targets are grouped by their patch versions.
	///	- Parameter menuItem: The menu item that calls this method.
	@objc private func togglePatchGrouping(_ menuItem: NSMenuItem) {
		targetsAreGroupedByMajorVersion.toggle()
		menuItem.state = NSControl.StateValue(rawValue: targetsAreGroupedByPatchVersion ? 1 : 0)
	}
	///	Called after `Synecdoche.shared.targets` has changed.
	///	- Parameter notification: The notification of `Synecdoche.shared.targets` having been changed.
	@objc func targetsDataDidUpdate(_ notification: Notification) {
		//	TODO: Throw an error.
		guard let updatedTargets = notification.object as? Targets else { return }
		DispatchQueue.main.async {
			self.synecdochicalTargets = updatedTargets
			self.targetsSourceListView.reloadData()
		}
	}
	
	@objc func redrawTargets(_ notification: Notification) {
		
	}
	
//	deinit {
//		NotificationCenter.default.removeObserver(self)
//	}
}

extension TargetsViewController: NSOutlineViewDataSource {
	//
	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		//
		func targetsCount(of targets: Targets) -> Int {
			switch targets.groupingLevel {
			case .root: if targetsAreGroupedByMajorVersion { return targets.majorVersionGroups.count }; fallthrough
			case .major: if targetsAreGroupedByMinorVersion { return targets.minorVersionGroups.count }; fallthrough
			case .minor: if targetsAreGroupedByPatchVersion { return targets.patchVersionGroups.count }; fallthrough
			default: return targets.count
			}
		}
		//
		if item == nil {
			return targetsCount(of: synecdochicalTargets)
		} else if let targets = item as? Targets {
			return targetsCount(of: targets)
		} else {
			return 0
		}
	}
	//
	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		//
		func child(of targets: Targets) -> Any {
			switch targets.groupingLevel {
			case .root: if targetsAreGroupedByMajorVersion { return targets.majorVersionGroups[targets.majorVersionGroups.keys.sorted(by: >)[index]] ?? 0 }; fallthrough
			case .major: if targetsAreGroupedByMinorVersion { return targets.minorVersionGroups[targets.minorVersionGroups.keys.sorted(by: >)[index]] ?? 0 }; fallthrough
			case .minor: if targetsAreGroupedByPatchVersion { return targets.patchVersionGroups[targets.patchVersionGroups.keys.sorted(by: >)[index]] ?? 0 }; fallthrough
			default: return targets[index]
			}
		}
		
		if item == nil {
			return child(of: synecdochicalTargets)
		} else if let targets = item as? Targets {
			return child(of: targets)
		} else {
			return 0
		}
	}
	//
	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		item is Targets
	}
}

extension TargetsViewController: NSOutlineViewDelegate {
	//
	func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
		if let targets = item as? Targets {
			switch targets.groupingLevel {
			case .root: if targetsAreGroupedByMajorVersion { return true }
			case .major: if targetsAreGroupedByMinorVersion { return true }
			case .minor: if targetsAreGroupedByPatchVersion { return true }
			default: break
			}
		}
		return false
	}
	//
	func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		//
		guard tableColumn?.identifier.rawValue == "TargetColumn" else { return nil }
		//
		if let targets = item as? Targets {
			guard let cell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "HeaderCell"), owner: nil) as? NSTableCellView else { return nil }
			cell.textField?.stringValue = "KSP \(targets.groupVersion.description)"
			return cell
		} else if let target = item as? Target {
			//	FIXME: Use Auto Layout to align the leading and trailing edges with superview's.
			return NSHostingView(rootView: TargetView(target: target))
		} else {
			return nil
		}
	}
	//	FIXME: Use Auto Layout, instead of hard-coded values.
	//
	func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
		//
		if item is Targets {
			return 17
		} else if item is Target {
			return 59
		} else {
			return 0
		}
	}
	//
	func outlineViewSelectionDidChange(_ notification: Notification) {
		//
		if notification.object as? NSOutlineView == targetsSourceListView {
			guard targetsSourceListView.selectedRow >= 0 else { return }
			//	TODO: Make a pitch to make flatMap smarter.
			GC.shared.recordSelection(of: targetsSourceListView.selectedRowIndexes
				.map { targetsSourceListView.item(atRow: $0) }
				.flatMap { ($0 as? Targets)?.targets ?? [$0 as? Target].compactMap { $0 } }
			)
			Synecdoche.shared.selectedTargets.forEach {
				print($0)
			}
		}
	}
}

//	MARK: - NSUserInterfaceValidations Conformance
//	TODO: Embelish. Elaborate.
//extension TargetsViewController: NSUserInterfaceValidations {
//	func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
//		true
//	}
//
//
//}
