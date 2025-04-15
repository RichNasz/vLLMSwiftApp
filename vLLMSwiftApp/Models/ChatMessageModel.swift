//
//  ChatMessageModel.swift
//  vLLMSwiftApp
//
//  Created by Richard Naszcyniec on 4/16/25.
//

import Foundation
import SwiftData

// valid chatmessage type
enum ChatMessageRole: Codable {
	case user
	case system
	case assistant
}

@Observable class ChatMessage: Identifiable {
	var id: UUID
	var content: String	// allows to used reactively in SwiftUI
	var isUser: ChatMessageRole
	var timestamp: Date // Added for sorting and persistence
	
	init(id: UUID = UUID(), content: String, isUser: ChatMessageRole, timestamp: Date = Date()) {
		self.id = id
		self.content = content
		self.isUser = isUser
		self.timestamp = timestamp
	}
}


@Observable class ChatConversation {
	var id: UUID
	var name: String?
	var messages: [ChatMessage]? = [] // allows to used reactively in SwiftUI
	
	init(id: UUID = UUID(), messages: [ChatMessage] ){
		self.id = id
		self.messages = messages
		
	}
	
}
