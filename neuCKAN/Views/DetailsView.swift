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
		GeometryReader { geometry in
			ScrollView {
				if self.release != nil {
					VStack {
						HStack {
							//	TODO: Add mod logo here.
							VStack(alignment: .leading) {
								Text(self.release!.name)
									.font(.title)
								Text(self.release!.abstract)
								Text("Version \(String(describing: self.release!.version))")
							}
							.lineLimit(1)
							Spacer()
						}
					}
					.padding()
				} else {
					VStack {
						Spacer()
						HStack {
							Spacer()
							Text("Select a mod release to view its details.")
								.multilineTextAlignment(.center)
								.font(.callout)
								.foregroundColor(.secondary)
								.allowsTightening(true)
//								.padding()
							Spacer()
						}
						Spacer()
					}
					.padding()
					.frame(width: geometry.size.width)
					.frame(minHeight: geometry.size.height)
				}
			}
		}
	}
}

struct DetailsView_Previews: PreviewProvider {
    static var previews: some View {
		DetailsView(release: nil)
    }
}
