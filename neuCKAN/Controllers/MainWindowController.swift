//
//  MainWindowController.swift
//  neuCKAN
//
//  Created by you on 20-01-11.
//  Copyleft © 2020 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import Cocoa

class MainWindowController: NSWindowController {
	
	// MARK: - IBOutlet Properties
	
	///
	@IBOutlet weak var navigationControl: NSSegmentedControl!
	///
	@IBOutlet weak var touchBarNavigationControl: NSSegmentedControl!
	///
	@IBOutlet weak var kspTargetPopUpButton: NSPopUpButton!
	///
	@IBOutlet weak var filterButton: NSButton!
	///
	@IBOutlet weak var filterTouchBar: NSTouchBar!
	///
	@IBOutlet weak var searchField: NSSearchField!
	///
	@IBOutlet weak var searchTouchBar: NSTouchBar!
	///
	@IBOutlet weak var refreshButton: NSButton!
	///
	@IBOutlet weak var touchBarRefreshButton: NSButton!
	///
	@IBOutlet weak var downloadsAndInstallButton: NSButton!
	///
	@IBOutlet weak var modsLayoutButton: NSButton!
	///
	@IBOutlet weak var touchBarModsLayoutButton: NSButton!
	///
	@IBOutlet weak var windowLayoutControl: NSSegmentedControl!
	
	@IBOutlet weak var touchBarWindowLayoutControl: NSSegmentedControl!
	
	// MARK: -
	
	override func windowDidLoad() {
		super.windowDidLoad()
		
		// Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
	}
	
	//	MARK: - IBAction Methods
	
	/**
	Refreshes all data in window.
	
	- Parameter sender: The object that calls this method.
	*/
	@IBAction func refresh(_ sender: Any) {
		GC.shared.refreshData()
	}
	
}
