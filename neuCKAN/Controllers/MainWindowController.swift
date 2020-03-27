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
	
	///	neuCKAN's navigation control on toolbar.
	@IBOutlet weak var toolbarNavigationControl: NSSegmentedControl!
	///	neuCKAN's navigation control on touch bar.
	@IBOutlet weak var touchBarNavigationControl: NSSegmentedControl!
	///	neuCKAN's target selector on toolbar.
	@IBOutlet weak var toolbarKSPTargetPopUpButton: NSPopUpButton!
	///	neuCKAN's filter button on toolbar.
	@IBOutlet weak var toolbarFilterButton: NSButton!
	///	neuCKAN's filter button on touch bar.
	@IBOutlet weak var touchBarFilterTouchBar: NSTouchBar!
	///	neuCKAN's search field on toolbar.
	@IBOutlet weak var toolbarSearchField: NSSearchField!
	///	neuCKAN's search button on touch bar.
	@IBOutlet weak var touchBarSearchTouchBar: NSTouchBar!
	///	neuCKAN's refresh button on toolbar.
	@IBOutlet weak var toolbarRefreshButton: NSButton!
	///	neuCKAN's refresh button on touch bar.
	@IBOutlet weak var touchBarRefreshButton: NSButton!
	///	neuCKAN's download & install button on toolbar.
	@IBOutlet weak var toolbarDownloadsAndInstallButton: NSButton!
	///	neuCKAN's mods layout switch on toolbar.
	@IBOutlet weak var toolbarModsLayoutButton: NSButton!
	///	neuCKAN's mods layout switch on touch bar.
	@IBOutlet weak var touchBarModsLayoutButton: NSButton!
	///	neuCKAN's window layout control on toolbar.
	@IBOutlet weak var toolbarWindowLayoutControl: NSSegmentedControl!
	///	neuCKAN's window layout control on touch bar.
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
