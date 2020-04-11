//
//  ModResourcesButtons.swift
//  neuCKAN
//
//  Created by you on 20-04-07.
//  Copyleft © 2020 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import SwiftUI

struct ModResourcesButtons: View {
	
	let resources: Resources
	
    var body: some View {
		VStack(alignment: .trailing) {
			if resources.homepage != nil {
				ModResourceButton(resourceTitle: "Home Page", resourceURL: resources.homepage!)
			}
			if resources.repository != nil {
				ModResourceButton(resourceTitle: "GitHub", resourceURL: resources.repository!)
			}
			if resources.spaceDock != nil {
				ModResourceButton(resourceTitle: "SpaceDock", resourceURL: resources.spaceDock!)
			}
			if resources.curseForge != nil {
				ModResourceButton(resourceTitle: "CurseForge", resourceURL: resources.curseForge!)
			}
			if resources.ci != nil {
				ModResourceButton(resourceTitle: "CI", resourceURL: resources.ci!)
			}
			if resources.bugTracker != nil {
				ModResourceButton(resourceTitle: "Bug Tracker", resourceURL: resources.bugTracker!)
			}
			if resources.manual != nil {
				ModResourceButton(resourceTitle: "Manual", resourceURL: resources.manual!)
			}
			Spacer()
		}
    }
}

//struct ModResourcesButtons_Previews: PreviewProvider {
//    static var previews: some View {
//        ModResourcesButtons()
//    }
//}
