//
//  ChooseMenuItemTip.swift
//  vLLMSwiftApp
//
//  Created by Richard Naszcyniec on 4/28/25.
//

import Foundation
import TipKit

struct ChooseMenuItemTip: Tip {
	
	var id: String {
		return "tip.identifier.ChooseMenuItemTip"
	}
	
	var title: Text {
		Text("Choose menu item")
	}
	
	var message: Text? {
		Text("Choose a menu item from the list of enabled items.")
	}
	
	var asset: Image? {
		Image(systemName: "hand.tap")
	}
	
	
	var options: [any Option] {
		// Tip will only appear 3 times before it is automatically invalidated.
		MaxDisplayCount(3)
	}
	
}
