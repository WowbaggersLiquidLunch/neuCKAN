//
//	DetailsViewHeader.swift
//	neuCKAN
//
//	Created by you on 20-04-05.
//	Copyleft © 2020 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import SwiftUI

///	A details view header.
struct DetailsViewHeader: View {
	///	The mod release's logo's height, calculated from its `HStack` siblings' heights.
	@State private var releaseLogoHeight: CGFloat = 0
	///	The mod release this details header applies to.
	let release: Release
	
	var body: some View {
		HStack {
			//	TODO: Add placeholder logo here.
			//	TODO: Add mod logo here.
			Image("Mod Logo Placeholder")
				.antialiased(true)
				.resizable()
				.aspectRatio(contentMode: .fit)
				.frame(width: releaseLogoHeight, height: releaseLogoHeight, alignment: .center)
				.shadow(radius: 5)
				.padding(.leading, -10)
				.padding(.trailing,15)
				.padding(.bottom, -5)
				.layoutPriority(1)
			
			VStack(alignment: .leading, spacing: 5) {
				Text(release.name)
					.font(.title)
				
				HStack {
					VStack(alignment: .leading, spacing: 5) {
						Text((release.abstract.count <= 60 || release.abstract.split(separator: " ").count <= 6) && !release.abstract.contains("//") && release.abstract.split(separator: ".").count <= 2 && !release.abstract.isEmpty ? release.abstract : "No succinct mod abstract")
							.font(.system(size: 13))
							.foregroundColor(.secondary)
						Text(release.authors?.joined(separator: ", ") ?? "Anonymous author(s)")
							.font(.caption)
					}
					.font(.caption)
					
					Spacer()
					
					//				Button(action: {} ) {
					//					Text("Install")
					//				}
					
				}
				
				Divider()
				
				Text(release.licences.joined(separator: ", "))
				
				
			}
			.lineLimit(1)
			.alignmentGuide(VerticalAlignment.center) { d in
				DispatchQueue.main.async {
					self.releaseLogoHeight = d.height
				}
				return d[VerticalAlignment.center]
			}
			
			Spacer()
		}
		.padding()
	}
}

//struct DetailsHeaderView_Previews: PreviewProvider {
//    static var previews: some View {
//        DetailsViewHeader()
//    }
//}
