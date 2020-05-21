//
//  TargetView.swift
//  neuCKAN
//
//  Created by you on 20-01-14.
//  Copyleft © 2020 Wowbagger & His Liquid Lunch. All wrongs reserved.
//

import SwiftUI

//	FIXME: Change text formatting, so that only "GameData" is monospaced, not the entire string.

struct TargetView: View {
	///	A flag indicating whether the cursor is hovering over the target view.
	@State private var cursorIsHoveringOverTarget: Bool = false
	///	A flag indicating whether the cursor is hovering over the "Reveal in Finder" button.
	@State private var cursorIsHoveringOverRevealButton: Bool = false
	///	A flag indicating whether the cursor is hovering over the "Go to GameData/" button.
	@State private var cursorIsHoveringOverFollowLinkButton: Bool = false
	///	A flag indicating whether the ancillary text should take more than one line.
	@State private var ancillaryTextSpansMultipleLines: Bool = false
	///	KSP logo's height, calculated from its `HStack` siblings' heights.
	@State private var kspLogoHeight: CGFloat = 0
	///	The target to display.
	let target: Target
	///	The accessible tool tip for the "Reveal in Finder" button.
	let revealButtonAccessibleToolTip: String = "Show Game in Finder"
	///	The accessible tool tip for the "Go to GameData/" button.
	let followLinkButtonAccessibleToolTip: String = "Go to the GameData Folder"
	///	The displayed tool tip for the "Reveal in Finder" button.
	let revealButtonToolTip: String = "Show in Finder"
	///	The displayed tool tip for the "Go to GameData/" button.
	let followLinkButtonToolTip: String = "Go to GameData/"
	
    var body: some View {
		HStack (alignment: .center) {
			
			//	TODO: Align top of the patch's frame with the version text's ascent, and the bottom of patch's frame with path text's first line's baseline.
			Image(nsImage: target.logo!)
				.antialiased(true)
				.resizable()
				.scaledToFit()
				.frame(width: kspLogoHeight * 1.1, height: kspLogoHeight, alignment: .center)
				.shadow(radius: 5)
				.layoutPriority(1)
				
			
			VStack(alignment: .leading) {
				
				Text("KSP \(target.version.description)")
					.fontWeight(.medium)
					.font(.system(.title, design: .default))
					.lineLimit(1)
					.allowsTightening(true)
					.layoutPriority(1)
				
				//	TODO: Render "GameData/" in code format
				Text(LocalizedStringKey(ancillaryText))
					.fontWeight((cursorIsHoveringOverRevealButton || cursorIsHoveringOverFollowLinkButton) ? .light : .ultraLight)
					.font(.system(.caption, design: (cursorIsHoveringOverRevealButton || cursorIsHoveringOverFollowLinkButton) ? .default : .monospaced))
					.lineLimit(ancillaryTextSpansMultipleLines ? 5 : 1)
					.onTapGesture { self.ancillaryTextSpansMultipleLines.toggle() }
				
			}
			.alignmentGuide(VerticalAlignment.center) { d in
				DispatchQueue.main.async {
					self.kspLogoHeight = d.height
				}
				return d[VerticalAlignment.center]
			}
			
			Spacer()
			
			if cursorIsHoveringOverTarget {
				VStack(alignment: .trailing) {
					//	Click this button to show the selected target's directory in Finder.
					Button(action: { self.showInFinder(itemAtPath: self.target.path) } ) {
						Image(nsImage: NSImage(named: "NSRevealFreestandingTemplate")!)
							.accessibility(hint: Text(revealButtonAccessibleToolTip))
					}
					.onHover { self.cursorIsHoveringOverRevealButton = $0 }
					//	Click this button to navigate to the selected target's GameData/ directory in Finder.
					Button(action: { self.openInFinder(directoryPath: self.target.gameDataPath) } ) {
						Image(nsImage: NSImage(named: "NSFollowLinkFreestandingTemplate")!)
							.accessibility(hint: Text(followLinkButtonAccessibleToolTip))
					}
					.onHover { self.cursorIsHoveringOverFollowLinkButton = $0 }
				}
				.buttonStyle(BorderlessButtonStyle())
			}
			
		}
		.padding(.top, 9)
		.padding(.bottom, 9)
		.padding(.leading, 5)
		.padding(.trailing, 5)
		.onHover { self.cursorIsHoveringOverTarget = $0 }
	}
	///	The ancillary text of the target view.
	var ancillaryText: String {
		if cursorIsHoveringOverRevealButton {
			return revealButtonToolTip
		} else if cursorIsHoveringOverFollowLinkButton {
			return followLinkButtonToolTip
		} else {
			return "~/" + target.path.pathComponents.dropFirst(3).joined(separator: "/")
			//	abbreviatingWithTildeInPath doesn't work in sandboxed app.
//			return NSString(string: target.path.path).abbreviatingWithTildeInPath
		}
	}
	///	Shows the item at the specified path in Finder.
	///	- Parameter path: The path to the item to select in Finder.
	func showInFinder(itemAtPath path: URL) {
		guard try! path.checkResourceIsReachable() else { return }
		NSWorkspace.shared.activateFileViewerSelecting([path])
	}
	///	Opens the directory at the specified path in Finder.
	///	- Parameter path: The path to the item to open in Finder.
	func openInFinder(directoryPath path: URL) {
		guard try! path.checkResourceIsReachable() else { return }
		guard path.hasDirectoryPath else { return }
		NSWorkspace.shared.open(path)
	}
}

//	https://stackoverflow.com/questions/59129089/swiftui-how-to-display-tooltip-hint-on-mouse-move-on-some-object
//extension View {
//	///	Overlays this view with a view that provides a toolTip with the given string.
//	func toolTip(_ toolTip: String?) -> some View {
//		self.overlay(TooltipView(toolTip))
//	}
//}
//
//private struct TooltipView: NSViewRepresentable {
//	let toolTip: String?
//
//	init(_ toolTip: String?) {
//		self.toolTip = toolTip
//	}
//
//	func makeNSView(context: NSViewRepresentableContext) -> NSView {
//		let view = NSView()
//		view.toolTip = self.toolTip
//		return view
//	}
//
//	func updateNSView(_ nsView: NSView, context: NSViewRepresentableContext) {
//	}
//}

struct TargetView_Previews: PreviewProvider {
    static var previews: some View {
		//	TODO: Add preview.
		EmptyView()
	}
}
