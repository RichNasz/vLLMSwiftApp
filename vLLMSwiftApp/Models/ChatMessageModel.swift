//
//  ChatMessageModel.swift
//  vLLMSwiftApp
//
//  Created by Richard Naszcyniec on 4/16/25.
//

import Foundation
import SwiftData

/// Specify the scope of message roles that are valid
///
/// Defines the entire scope of possible roles assocaited with a a message.
/// Must remain public since the ``ChatMessage`` is also public and @Observable
enum ChatMessageRole: Codable {
	case user
	case system
	case assistant
}

/// This class is used to store a basic chat messge.
/// 
/// The @Oberservable macro is use to simplify SwiftUI  automatic tracking of value changes in the class's properties to drive view udates accordingly.
/// Very important when processing streaming message completions.
@Observable class ChatMessage: Identifiable {
	var id: UUID
	var content: String	// allows to used reactively in SwiftUI
	var isUser: ChatMessageRole
	var timestamp: Date // Added for sorting and persistence
	
	/// class initializer
	/// - Parameters:
	///   - id: unique identifier that defaults to a UUID being created
	///   - content: string that represents the text of the message
	///   - isUser: enumeration value that defines the type of message
	///   - timestamp: when the message was created
	init(id: UUID = UUID(), content: String, isUser: ChatMessageRole, timestamp: Date = Date()) {
		self.id = id
		self.content = content
		self.isUser = isUser
		self.timestamp = timestamp
	}
}

/// This class is used to track converstions
///
/// Conversations are made up of multiple indvidual ChatMessages.
/// This class **is not** currently used and is a placeholder for future functional capabilities.
@Observable class ChatConversation {
	var id: UUID
	var name: String?
	var messages: [ChatMessage]? = [] // allows to used reactively in SwiftUI
	
	init(id: UUID = UUID(), messages: [ChatMessage] ){
		self.id = id
		self.messages = messages
		
	}
	
}
