//
//  ChatInputView.swift
//  vLLMSwiftApp
//
//  Created by Richard Naszcyniec on 4/16/25.
//
// This view is used to collect an input prompt from a user.
// It is intended to be used by a parent view

import SwiftUI

struct ChatInputView: View {
	// Allows the calling view to indicate when the message collected by this view
	// is being used communication with the LLM.
	private var isSending: Bool
	// Set up a closure so the caller can take and action when the button is pressed
	// This provides the option of low level control for the user
	let onSend: (String) -> Void
	
	@State private var message: String = ""
	
	init(isSending: Bool, onSend: @escaping (String) -> Void) {
		self.isSending = isSending
		self.onSend = onSend
	}
	
	var body: some View {
		HStack {
			// Multiline text input
			TextEditor(text: $message)
				.frame(minHeight: 40, maxHeight: .infinity) // Set min/max height
				.padding()	// just use default padding
				.clipShape(RoundedRectangle(cornerRadius: 8))
				.overlay(
					RoundedRectangle(cornerRadius: 8)
						.stroke(.black))
				.disabled(isSending)
			
			Button(action: {
				guard !message.trimmingCharacters(in: .whitespaces).isEmpty else { return }
				onSend(message)
				message = ""
			}) {
				if isSending {
					ProgressView()
						.frame(width: 44, height: 44)
				} else {
					Image(systemName: "paperplane")
						.foregroundColor(.blue)
						.frame(width: 44, height: 44)
				}
			}
			.disabled(message.trimmingCharacters(in: .whitespaces).isEmpty || isSending)
		}
		.padding([.horizontal, .vertical], 5 )
		.background(.white)
		.clipShape(RoundedRectangle(cornerRadius: 10))
		.shadow(radius: 2)
	}
}

#Preview {
	// Wrapper view to simulate the chat interface context
	struct ChatInputPreviewWrapper: View {
		@State private var isSending: Bool = false
		@State private var lastMessage: String? // To display sent message
		
		var body: some View {
			VStack {
				// Mock chat area
				if let message = lastMessage {
					Text("Sent: \(message)")
						.padding()
						.background(Color.gray.opacity(0.2))
						.clipShape(RoundedRectangle(cornerRadius: 10))
						.frame(maxWidth: .infinity, alignment: .leading)
						.padding(.horizontal)
				}
				Spacer()
				
				// ChatInputView with isSending binding
				ChatInputView(isSending: isSending) { message in
					print("Message sent: \(message)")
					lastMessage = message
					isSending = true
					// Simulate async send delay
					DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
						isSending = false
					}
				}
//				.frame(height: 60)
				.padding([.vertical, .horizontal], 8)
				.background(.white)
				.containerRelativeFrame(.vertical) { length, _ in
					length * (1 - 0.66)	// make it 1/3 whatever the container height is
				}
			}
			//			.padding([.bottom], 10)
			
			.background(.white)
//			.previewLayout(.sizeThatFits)
			
			
		}
	}
	
	return ChatInputPreviewWrapper()
}

//#Preview {
//	var isSending: Bool = false
//	ChatInputView(isSending: self.$isSending) { message in
//		print("Message: \(message)")
//	}
//}
