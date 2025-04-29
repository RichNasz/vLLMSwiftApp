//
//  CreateServerTip.swift
//  vLLMSwiftApp
//
//  Created by Richard Naszcyniec on 4/28/25.
//

import Foundation
import TipKit

struct CreateServerTip: Tip {
	
	@Parameter
	static var aServerIsDefined: Bool = false
	
	var id: String {
		return "tip.identifier.CreateServerTip"
	}
	
	var title: Text {
		Text("Define your first server")
	}
	
	var message: Text? {
		Text("You must create at least one server before you can interact with a model using a chat option.")
	}
	
	var asset: Image? {
		Image(systemName: "server.rack")
	}
	
	public var rules: [Rule] {
		#Rule(Self.$aServerIsDefined) { $0 == false }
	}
	
}
