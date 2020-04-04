//
//  DetailsViewController.swift
//  neuCKAN
//
//  Created by you on 20-01-11.
//  Copyleft © 2020 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import Cocoa
import SwiftUI

///	A controller that manages the details split view of neuCKAN.
class DetailsViewController: NSViewController {
	
	/// The details view.
	let detailsView = NSHostingView(rootView: DetailsView(release: nil))
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
		NotificationCenter.default.addObserver(self, selector: #selector(modReleaseSelectionDidChange(_:)), name: .modReleaseSelectionDidChange, object: nil)
		
		//	MARK: Subview Configurations
		detailsView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(detailsView)
		detailsView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		detailsView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
		detailsView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		detailsView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
	}
	
	override var representedObject: Any? {
		didSet {
			// Update the view, if already loaded.
		}
	}
	
	/// Called after the details view controller receives a notification that the mod release selection change.
	/// - Parameter notification: The notification that the mod release selection change.
	@objc func modReleaseSelectionDidChange(_ notification: Notification) {
		if let release = notification.object as? Release {
			detailsView.rootView.release = release
		}
	}
}
