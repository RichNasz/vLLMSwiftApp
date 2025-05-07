//
//  ChooseMenuItemTip.swift
//  vLLMSwiftApp
//
//  Created by Richard Naszcyniec on 4/28/25.
//

import Foundation
import TipKit

/// Defines the user tip to prompt the user to select a menu item
///
/// When the application starts up there is no default menu item selected.
/// This tip instructs the user to select an item from the menu.
struct ChooseMenuItemTip: Tip {
	
	/// property required by the Tip protocol to uniquely identify the tip
	var id: String {
		return "tip.identifier.ChooseMenuItemTip"
	}
	
	/// defines the headline of the tip to display prominently when the tip appears
	var title: Text {
		Text("Choose menu item")
	}
	
	/// detailed text to accompany the title property
	var message: Text? {
		Text("Choose a menu item from the list of enabled items.")
	}
	
	/// specifies the image to display alongside the tip to enhance its visual appeal.
	var asset: Image? {
		Image(systemName: "hand.tap")
	}
	
	
	/// Tip will only appear 3 times before it is automatically invalidated.
	var options: [any Option] {
		MaxDisplayCount(3)
	}
	
}
