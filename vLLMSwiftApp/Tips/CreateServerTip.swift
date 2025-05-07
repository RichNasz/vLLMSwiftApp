//
//  CreateServerTip.swift
//  vLLMSwiftApp
//
//  Created by Richard Naszcyniec on 4/28/25.
//

import Foundation
import TipKit

/// Defines the user tip to create a server.
///
/// At least one server must be defined before any of the chat functionality can be used.
struct CreateServerTip: Tip {
	
	/// A property wrapper to determine if a server is defined that TipKit will monitor for changes.
	/// The rules for this tip use this value
	@Parameter
	static var aServerIsDefined: Bool = false
	
	/// property required by the Tip protocol to uniquely identify the tip
	var id: String {
		return "tip.identifier.CreateServerTip"
	}
	
	/// defines the headline of the tip to display prominently when the tip appears
	var title: Text {
		Text("Define your first server")
	}
	
	/// detailed text to accompany the title property
	var message: Text? {
		Text("You must create at least one server before you can interact with a model using a chat option.")
	}
	
	///  specifies the image to display alongside the tip to enhance its visual appeal.
	var asset: Image? {
		Image(systemName: "server.rack")
	}
	
	/// rules for displaying the tip:
	/// - only show the tip is no servers are defined
	public var rules: [Rule] {
		#Rule(Self.$aServerIsDefined) { $0 == false }
	}
	
}
