//
//  ModPreviewSlide.swift
//  neuCKAN
//
//  Created by you on 20-04-04.
//  Copyleft © 2020 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import SwiftUI
import URLImage
import KingfisherSwiftUI

///	A scrollable preview of the mod release.
struct ModPreviewSlide: View {
	///	The mod release the preview slide is for.
	let release: Release
	
	var body: some View {
		VStack {
			Divider()
			HStack {
				Text("Preview")
					.font(.headline)
				Spacer()
			}
			
			ScrollView(.horizontal, showsIndicators: true) {
				if release.resources?.screenshot != nil {
//					URLImage(release.resources!.screenshot!, incremental: true, placeholder: {
//						ProgressView($0) { progress in
//							ZStack {
//								if progress > 0.0 {
//									CircleProgressView(progress).stroke(lineWidth: 2.0)
//								}
//								else {
//									CircleActivityView().stroke(lineWidth: 2.0)
//								}
//							}
//						}
//						.frame(width: 25.0, height: 25.0)
//					}, content: { proxy in
//						proxy.image
//							.antialiased(true)
//							.resizable()
//							.scaledToFill()
//					})
//						.frame(width: 430, height: 270, alignment: .center)
//						.cornerRadius(5)
					
					//	TODO: Add placeholders/indicators or show/hide the entire preview based on the network request result.
					KFImage(
						release.resources!.screenshot!,
						options: [.backgroundDecode, .progressiveJPEG(.default)]
					)
						.antialiased(true)
						.resizable()
						.scaledToFill()
						.frame(width: 430, height: 270, alignment: .center)
						.cornerRadius(5)
				}
			}
		}
	}
}

//struct ModPreviewSlide_Previews: PreviewProvider {
//    static var previews: some View {
//        PreviewView()
//    }
//}
