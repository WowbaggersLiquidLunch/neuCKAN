//
//  ModResourceButton.swift
//  neuCKAN
//
//  Created by you on 20-04-07.
//  Copyleft © 2020 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import SwiftUI

///	A button that link to a resource.
struct ModResourceButton: View {
	///	Initialises a `ModResourceButton` instance with the specified resource.
	///	- Parameters:
	///		- resourceTitle: The name of the specified resource.
	///		- resourceURL: The location of the specified resource.
	init(resourceTitle: String, resourceURL: URL) {
		self.resourceTitle = resourceTitle
		self.resourceURL = resourceURL
		switch resourceTitle {
		case "Home Page": hostLogo = Image("safari fill")
		case "GitHub": hostLogo = Image("GitHub Mark")
		case "SpaceDock": hostLogo = Image("SpaceDock Badge")
		case "CurseForge": hostLogo = Image("CurseForge Anvil")
		case "CI": hostLogo = Image("Bot")
		case "Bug Tracker": hostLogo = Image("exclamationmark bubble")
		case "Manual": hostLogo = Image("book fill")
		default: hostLogo = Image("safari fill")
		}
	}
	///	The resource's logo's height, calculated from its title's heights.
	@State private var hostLogoHeight: CGFloat = 0
	///	The resource's title.
	let resourceTitle: String
	///	The resourde's location.
	let resourceURL: URL
	///	The resource's logo.
	let hostLogo: Image
	
    var body: some View {
        Button(action: {
			NSWorkspace.shared.open(self.resourceURL, configuration: .init(), completionHandler: nil)
		}, label: {
			HStack {
				Text(resourceTitle)
					.font(.system(size: 13))
					.lineLimit(1)
					.alignmentGuide(VerticalAlignment.center) { d in
						DispatchQueue.main.async {
							self.hostLogoHeight = d.height
						}
						return d[VerticalAlignment.center]
				}
				hostLogo
					.antialiased(true)
					.resizable()
					.scaledToFit()
					.frame(width: hostLogoHeight, height: hostLogoHeight, alignment: .center)
					.shadow(radius: 1)
					.layoutPriority(1)
			}
		})
			.buttonStyle(PlainButtonStyle())
			.foregroundColor(.secondary)
    }
}

struct ModResourceButton_Previews: PreviewProvider {
    static var previews: some View {
        ModResourceButton(
			resourceTitle: "Homepage",
			resourceURL: URL(string: "http://forum.kerbalspaceprogram.com/index.php?/topic/19321-1")!
		)
    }
}
