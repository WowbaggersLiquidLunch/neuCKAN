//
//  DetailsView.swift
//  neuCKAN
//
//  Created by you on 20-03-31.
//  Copyleft © 2020 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import SwiftUI

struct DetailsView: View {
	var release: Release?
    var body: some View {
		ScrollView {
			if release != nil {
				VStack {
					HStack {
						//	TODO: Add mod logo here.
						VStack {
							Text(release!.name)
							Text(String(describing: release!.version))
						}
					}
				}
			} else {
				Text("Select a mod release to view its details.")
					.multilineTextAlignment(.center)
					.font(.callout)
					.foregroundColor(.secondary)
					.allowsTightening(true)
					.padding()
			}
		}
		.padding()
	}
}

struct DetailsView_Previews: PreviewProvider {
    static var previews: some View {
		DetailsView(release: nil)
    }
}
