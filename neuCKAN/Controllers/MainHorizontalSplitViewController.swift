//
//  MainHorizontalSplitViewController.swift
//  neuCKAN
//
//  Created by you on 20-02-14.
//  Copyleft © 2020 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import Cocoa

///	A controller that manages the main horizontal split view of neuCKAN.
class MainHorizontalSplitViewController: NSSplitViewController {
	
	///	The horizontal split view containing mods view and stats view in neuCKAN's main window.
	@IBOutlet weak var mainHorizontalSplitView: NSSplitView!
	///	The split view item for stats view.
	@IBOutlet weak var statsSplitViewItem: NSSplitViewItem!
	
	// MARK: - View Life Cycle
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		NotificationCenter.default.addObserver(self, selector: #selector(userDidInitiateWindowLayoutChange(_:)), name: .userDidInitiateWindowLayoutChange, object: nil)
    }
	
	override func viewDidAppear() {
		super.viewDidAppear()
		//	Sync window layout and its control's state.
		NotificationCenter.default.post(name: .windowLayoutDidChange, object: [1: statsSplitViewItem])
	}
    
	//	MARK: - Methods Exposed to Objective-C
	
	///	Called after the user initiated a window layout change.
	///	- Parameter notification: The notification that calls this method.
	@objc func userDidInitiateWindowLayoutChange(_ notification: Notification) {
		if (notification.object as? NSSegmentedControl)?.selectedSegment == 1 {
			toggleCollapse(of: statsSplitViewItem)
		}
	}
	
	//	MARK: - IBAction Methods
	
	//	MARK: -
	
	///	Toggles a splitview item's collapse.
	///	- Parameter splitViewItem: The split view item whose collapse needs toggling.
	func toggleCollapse(of splitViewItem: NSSplitViewItem) {
		splitViewItem.animator().isCollapsed = !splitViewItem.isCollapsed
		NotificationCenter.default.post(name: .windowLayoutDidChange, object: [1: statsSplitViewItem])
	}
}
