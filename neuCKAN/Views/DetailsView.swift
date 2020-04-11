//
//  DetailsView.swift
//  neuCKAN
//
//  Created by you on 20-03-31.
//  Copyleft © 2020 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import SwiftUI

///	A details view.
struct DetailsView: View {
	///	The mod release the details view is for.
	var release: Release?
	
    var body: some View {
		GeometryReader { geometry in
			ScrollView {
				if self.release != nil {
					VStack(alignment: .leading) {
						DetailsViewHeader(release: self.release!)
						if self.release!.resources?.screenshot != nil {
							ModPreviewSlide(release: self.release!)
						} else {
							Divider()
						}
						Spacer()
							.frame(height: 25)
						HStack {
							VStack(alignment: .leading) {
								if (self.release!.abstract.count > 60 && self.release!.abstract.split(separator: " ").count > 6) || self.release!.abstract.contains("//") || self.release!.abstract.split(separator: ".").count > 2 {
									Text(self.release!.abstract)
									if self.release!.description != nil && self.release!.description != "" {
										Text("")
										Text(self.release!.description!)
									}
								} else if self.release!.description != "" {
									Text(self.release!.description ?? "This mod has no detailed description.")
								} else {
									Text("This mod has no detailed description.")
								}
								Spacer()
							}
							if self.release!.resources!.homepage != nil {
								Spacer(minLength: 30)
								VStack(alignment: .trailing) {
									Text(self.release!.authors?.joined(separator: ", ") ?? "Anonymous author(s)")
											.lineLimit(1)
											.font(.caption)
											.foregroundColor(Color(NSColor.tertiaryLabelColor))
									ModResourcesButtons(resources: self.release!.resources!)
										.layoutPriority(1)
								}
							}
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
