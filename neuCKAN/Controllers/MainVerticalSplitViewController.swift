//
//  MainVerticalSplitViewController.swift
//  neuCKAN
//
//  Created by you on 20-01-19.
//  Copyleft © 2020 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import Cocoa

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
        // Do view setup here.
//		mainVerticalSplitView.delegate = self
//		mainHorizontalSplitView.delegate = self
//		guard let mainWindowController = NSApp.mainWindow?.windowController as? MainWindowController else {
//			assertionFailure()
//			return
//		}
//		guard let toolbarWindowLayoutControl = mainWindowController.toolbarWindowLayoutControl else {
//			assertionFailure()
//			return
//		}
//		guard let touchBarWindowLayoutControl = mainWindowController.touchBarWindowLayoutControl else {
//			assertionFailure()
//			return
//		}
//		toolbarWindowLayoutControl.setSelected(targetsSplitViewItem.isCollapsed, forSegment: 0)
//		toolbarWindowLayoutControl.setSelected((middleSplitViewItem.viewController as! MainVerticalSplitViewController).statsSplitViewItem.isCollapsed, forSegment: 1)
//		toolbarWindowLayoutControl.setSelected(detailsSplitViewItem.isCollapsed, forSegment: 2)
//		touchBarWindowLayoutControl.setSelected(targetsSplitViewItem.isCollapsed, forSegment: 0)
//		touchBarWindowLayoutControl.setSelected((middleSplitViewItem.viewController as! MainVerticalSplitViewController).statsSplitViewItem.isCollapsed, forSegment: 1)
//		touchBarWindowLayoutControl.setSelected(detailsSplitViewItem.isCollapsed, forSegment: 2)
    }
	
	override func viewDidAppear() {
		super.viewDidAppear()
	}
    
	//	MARK: IBAction Methods
	
	//	FIXME: Sync buttons' state with the window layout.
	
	///	Collapses or expands split view items.
	@IBAction func updateLayout(_ splitViewSegmentedControl: NSSegmentedControl) {
		switch splitViewSegmentedControl.selectedSegment {
//		case 0, 2:
//			mainVerticalSplitView.arrangedSubviews[sender.selectedSegment].isHidden = sender.selectedCell()?.state.rawValue == 0
//		case 1:
//			mainHorizontalSplitView.arrangedSubviews[1].isHidden = sender.selectedCell()?.state.rawValue == 0
		case 0:
			targetsSplitViewItem.animator().isCollapsed = splitViewSegmentedControl.selectedCell()?.state.rawValue == 0
		case 1:
			guard let middleSplitViewController = middleSplitViewItem.viewController as? MainHorizontalSplitViewController else {
				assertionFailure()
				return
			}
			middleSplitViewController.statsSplitViewItem.animator().isCollapsed = splitViewSegmentedControl.selectedCell()?.state.rawValue == 0
		case 2:
			detailsSplitViewItem.animator().isCollapsed = splitViewSegmentedControl.selectedCell()?.state.rawValue == 0
		default:
			assertionFailure()
		}
	}
}
