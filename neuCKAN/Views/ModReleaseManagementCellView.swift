//
//  ModReleaseManagementCellView.swift
//  neuCKAN
//
//  Created by you on 20-03-12.
//  Copyleft © 2020 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import Cocoa

class ModReleaseManagementCellView: NSTableCellView {
	///	The action button.
	@IBOutlet weak var actionButton: NSButton!
	///	The type of the item in the cell's row.
	var managedInstanceType: ManagedInstanceType!
	///	The state the managed item is in.
	var state: State!
	///	The managed targets.
	var managedTargets: Targets!
	///	The type of the item in the cell's row.
	enum ManagedInstanceType {
		case mod(Mod)
		case release(Release)
	}
	///	The state the managed item is in.
	enum State {
		case uninstalled
		case upgradable	//	to the selected version
		case downgradable	//	to the selected version
		case installed
	}
	
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
		
        // Drawing code here.
		switch state {
		case .uninstalled:
			actionButton.title = "Install"
		case .upgradable:
			actionButton.title = "Upgrade"
		case .downgradable:
			actionButton.title = "Downgrade"
		case .installed:
			actionButton.title = "Uninstall"
		default: break
		}
    }
	///	Manages the mod release.
	@IBAction func manageModRelease(_ sender: NSButton) {
		var managedRelease: Release!
		switch managedInstanceType {
		case .mod(let mod):
			managedRelease = mod.first!
		case .release(let release):
			managedRelease = release
		case .none:
			assertionFailure("managedInstanceType can't be nil")
		}
		switch state {
		case .upgradable, .downgradable:
			//	TODO: Uninstall currently installed version.
			fallthrough
		case .uninstalled:
			GC.shared.install(managedRelease, for: managedTargets)
		case .installed:
			//	TODO: Uninstall selected version.
			break
		case .none:
			assertionFailure("state can't be nil")
		}
	}
}
