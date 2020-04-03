//
//  Notification Names.swift
//  neuCKAN
//
//  Created by you on 20-02-23.
//  Copyleft © 2020 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import Foundation

extension Notification.Name {
	static let targetsDataDidUpdate = Notification.Name("targetsDataDidUpdate")
	static let modsCacheDidUpdate = Notification.Name("modsCacheDidUpdate")
	static let targetsSelectionDidChange = Notification.Name("targetsSelectionDidChange")
	static let modReleaseSelectionDidChange = Notification.Name("modReleaseSelectionDidChange")
	static let userDidInitiateModsLayoutChange = Notification.Name("userDidInitiateModsLayoutChange")
	static let modsLayoutDidChange = Notification.Name("modsLayoutDidChange")
	static let userDidInitiateWindowLayoutChange = Notification.Name("userDidInitiateWindowLayoutChange")
	static let windowLayoutDidChange = Notification.Name("windowLayoutDidChange")
}
