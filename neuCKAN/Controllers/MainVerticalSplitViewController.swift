//
//	MainVerticalSplitViewController.swift
//	neuCKAN
//
//	Created by you on 20-01-19.
//	Copyleft © 2020 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import Cocoa

///	A controller that manages the main vertical split view of neuCKAN.
class MainVerticalSplitViewController: NSSplitViewController {
	
	// MARK: - IBOutlet Properties
	
	///	The main verticle split view in neuCKAN's main window.
	@IBOutlet weak var mainVerticalSplitView: NSSplitView!
	///	The split view item for targets view.
	@IBOutlet weak var targetsSplitViewItem: NSSplitViewItem!
	///	The split view item for mods view and stats view.
	@IBOutlet weak var middleSplitViewItem: NSSplitViewItem!
	///	The split view item for details view.
	@IBOutlet weak var detailsSplitViewItem: NSSplitViewItem!
	
	// MARK: - View Life Cycle
	
    override func viewDidLoad() {
        super.viewDidLoad()
		targetsSplitViewItem.isSpringLoaded = true
		detailsSplitViewItem.isSpringLoaded = true
		NotificationCenter.default.addObserver(self, selector: #selector(userDidInitiateWindowLayoutChange(_:)), name: .userDidInitiateWindowLayoutChange, object: nil)
    }
	
	override func viewDidAppear() {
		super.viewDidAppear()
		//	Sync window layout and its control's state.
		NotificationCenter.default.post(name: .windowLayoutDidChange, object: [0: targetsSplitViewItem, 2: detailsSplitViewItem])
	}
    
	//	MARK: - Methods Exposed to Objective-C
	
	///	Called after the main vertical split view controller receives a notification that the user initiated a window layout change.
	///	- Parameter notification: The notification that the user initiated a window layout change.
	@objc func userDidInitiateWindowLayoutChange(_ notification: Notification) {
		switch (notification.object as? NSSegmentedControl)?.selectedSegment {
			case 0: toggleCollapse(of: targetsSplitViewItem)
			case 2: toggleCollapse(of: detailsSplitViewItem)
			default: break
		}
	}
	
	//	MARK: - IBAction Methods
	
	//	MARK: -
	
	///	Toggles a splitview item's collapse.
	///	- Parameter splitViewItem: The split view item whose collapse needs toggling.
	func toggleCollapse(of splitViewItem: NSSplitViewItem) {
		splitViewItem.animator().isCollapsed = !splitViewItem.isCollapsed
		NotificationCenter.default.post(name: .windowLayoutDidChange, object: [0: targetsSplitViewItem, 2: detailsSplitViewItem])
	}
}
