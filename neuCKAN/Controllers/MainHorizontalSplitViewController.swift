//
//  MainHorizontalSplitViewController.swift
//  neuCKAN
//
//  Created by you on 20-02-14.
//  Copyleft © 2020 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import Cocoa

class MainHorizontalSplitViewController: NSSplitViewController {
	
	///	The horizontal split view containing mods view and stats view in neuCKAN's main window.
	@IBOutlet weak var mainHorizontalSplitView: NSSplitView!
	///	The split view item for stats view.
	@IBOutlet weak var statsSplitViewItem: NSSplitViewItem!
	
	// MARK: - View Life Cycle
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
}
