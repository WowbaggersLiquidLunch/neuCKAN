//
//	Synecdoche.swift
//	neuCKAN
//
//	Created by you on 19-12-11.
//	Copyleft © 2019 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import Combine
import Foundation

let ckanMetadataArchiveURL = URL(string: "https://github.com/KSP-CKAN/CKAN-meta/archive/master.zip")!

/**
The most summarised data/state representation of the application.

The single, shared instance of this type represents all essential data for continued operation in each running session and across application launches. Most data and states natively managed by Cocoa are not represented. Temporary data and incomplete data processing are not represented currently.

- Remark: synecdoche | sɪˈnɛkdəki | _noun_ a figure of speech in which a part is made to represent the whole or vice versa, as in _England lost by six wickets_ (meaning "the English cricket team").
*/
struct Synecdoche {
	/// Initialises a `Synecdoche` instance.
	private init() {
		//	TODO: Load from persistent data storage; continue from last session.
		targets = []
		mods = []
		selectedTargets = []
	}
	
	//	MARK: - Singleton
	///	The shared, and only, data/state representation of the application.
	static var shared = Synecdoche()
	
	
	//	MARK: - Persistent Data
	///	All KSP installations under management of neuCKAN.
	var targets: Targets {
		didSet {
			NotificationCenter.default.post(name: .targetsDataDidUpdate, object: targets)
			//	TODO: Update persistent data storage.
			//	TODO: Update UI.
			
		}
	}
	//	TODO: Make mods private.
	///	All mods parsed from CKAN metadata.
	var mods: Mods {
		didSet {
			NotificationCenter.default.post(name: .modsCacheDidUpdate, object: mods)
			//	TODO: Update persistent data storage.
			//	TODO: Update UI.
			
		}
	}
	
//	var modCatalogue: [Target: Mods]
	
	//	MARK: - Volatile Data
	///	All KSP installations currently selected under immediate management.
	var selectedTargets: Targets {
		didSet {
			NotificationCenter.default.post(name: .targetsSelectionDidChange, object: selectedTargets)
		}
	}
	
//	var modListScrollLocation: Int = 0
	
	//	MARK: -
	
	
}
