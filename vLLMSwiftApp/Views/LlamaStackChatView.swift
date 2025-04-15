//
//  LlamaStackChatView.swift
//  vLLMSwiftApp
//
//  Created by Richard Naszcyniec on 4/16/25.
//

import SwiftUI
import SwiftData

struct LlamaStackChatView: View {
	// get the Swift Data context and get the current sorted data for use in this view
	@Environment(\.modelContext) private var modelContext
	// TODO: add a query to just use llama-stack server definitions
	@Query(sort: \Server.name, order: .forward) var serverList: [Server]
	
	// Declare the @State variables this view owns and will share with subviews
	// Clear ownership of variables in required for SwiftUI updates
	@State private var pickedServer: Server? // Optional value bound to Picker
	@State private var messages: [ChatMessage] = [] // Local array for chat messages that are observable
	@StateObject private var chatManager: LlamaStackChatViewModel = .init()	// code for interacting with llama-stack
	@State private var lastScrollListId: UUID?	// use to make sure we always scroll messsages to the bottom
	@State private var isSending: Bool = false	// track sending to LLM state
	@State private var currentLLMChatMessage: ChatMessage?
	@State private var updateScroll: Bool = false
	
	var body: some View {
		NavigationStack {
			VStack {
				// Picker for selecting a llama-stack server to communicate with
				Picker("Select Server", selection: $pickedServer) {
					ForEach(serverList) { server in
						Text(server.name)
							.tag(server as Server?) // Tag is the Server object
					}
				}
				.pickerStyle(.menu) // Use .menu for a dropdown style
				.padding([.horizontal, .vertical], 8 )	// specifically around the picker
				.background(.white)
				.clipShape(RoundedRectangle(cornerRadius: 10))
				.shadow(radius: 2)
				// now adjust everything above
				.padding([.vertical, .horizontal], 8)	// padding around the shape and shadow
				.containerRelativeFrame(.vertical) { length, _ in
					length * (1 - 0.90 )	// make it 10% whatever the container height is
				}
				
				Spacer()
				// Chat Messages are contained in a scroll view that we can control programatically
				// We want to new messages to always appear at the bottom and dynamically expand with an llm server response
				ScrollViewReader { proxy in
					ScrollView {
						LazyVStack(alignment: .leading, spacing: 10) {
							ForEach(messages.sorted(by: { $0.timestamp < $1.timestamp })) { message in
								ChatBubble(message: message)
									.id(message.id)
							}
						}
					}
					.padding([.vertical, .horizontal], 8)	// overall cotainer size will fit in available space
					.defaultScrollAnchor(.bottom)
					.onChange(of: updateScroll) {
						if(updateScroll) {
							withAnimation(.easeInOut(duration: 0.2)) {
								proxy.scrollTo(lastScrollListId, anchor: .bottom)
								self.updateScroll = false
							}
						}
					}
				}
				// display the prompt input view and get the message to send via a closure
				ChatInputView(isSending: isSending) { message in
					isSending = true	// starting the process of getting an inference result
//					print("Prompt: \(message)")
					// append the prompt being sent to the LLM
					let userMessage = ChatMessage(content: message, isUser: .user)
					messages.append(userMessage)
					lastScrollListId = userMessage.id	// scroll to the user message
					updateScroll = true
					
					currentLLMChatMessage = ChatMessage(content: chatManager.llmResponse, isUser: .assistant)
					messages.append(currentLLMChatMessage!)
					lastScrollListId = currentLLMChatMessage!.id	// forces update to scrollview
					updateScroll = true
					
					Task {
						do {
							// make sure the assistantMessage we set is updated with the llm response
							await chatManager.sendMessage( message)
						}
						// use the following line if you don't want to stream the response
//						messages.append( ChatMessage(content: chatManager.llmResponse, isUser: .assistant))
						isSending = false
						
//						print( "response: \(chatManager.llmResponse)")
					}
				}
				.padding([.vertical, .horizontal], 8)
				.containerRelativeFrame(.vertical) { length, _ in
					length * (1 - 0.80 )	// make it 25% whatever the container height is
				}
			}
		}
		.navigationTitle("Llama-Stack Chat")
		// provide a default selection. The view shouldn't be used if the list of servers is empty
		.onAppear {
			if pickedServer == nil, !serverList.isEmpty {
				pickedServer = serverList.first
				chatManager.setServer(server: pickedServer!)
			}
		}
		.onChange(of: pickedServer) { _, newServer in
			if let server = newServer {
				chatManager.setServer(server: server)
				messages.removeAll()
			}
		}
		.background(.white)
		//
		// MARK: streaming response from LLM server is handled here
		.onChange(of: chatManager.llmResponse) { _, newResponse in
			if let lastAssistantMessage = currentLLMChatMessage {
				lastAssistantMessage.content = newResponse	// change out the value based on what is returned
				updateScroll = true
			}
			
		}
}

//
// Chat Bubble View for displaying messages
//
	struct ChatBubble: View {
		let message: ChatMessage
		
		var body: some View {
			HStack {
				switch message.isUser {	// use a switch here for flexibility when formatting on role
					case .user:
						Spacer() // forces the bubble to the right
						Text(message.content)
							.padding()
							.background(Color.blue)
							.foregroundColor(.white)
							.clipShape(RoundedRectangle(cornerRadius: 10))
							.frame(maxWidth: .infinity, alignment: .trailing)
					default:
						Text(message.content)
							.padding()
							.background(Color.gray.opacity(0.2))
							.foregroundColor(.primary)
							.clipShape(RoundedRectangle(cornerRadius: 10))
							.frame(maxWidth: .infinity, alignment: .leading)
						Spacer() // forces the bubble to the left
				}
			}
			.padding(.horizontal, 5)
		}
	}
}
//
//EVERYTHING BELOW IS FOR PREVIEW ONLY
//

// Preview utility struct to hold static methods
@MainActor
struct PreviewUtils {
	static func createPreviewContainer() throws -> ModelContainer {
		let schema = Schema([Server.self])
		let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
		let container = try ModelContainer(for: schema, configurations: configuration)
		
		let context = container.mainContext
		
		// Insert sample data
		let server1 = Server(
			name: "Llama Server local",
			url: "http://127.0.0.1:5001",
			apiType: .llamaStack,
			modelName: "meta-llama/Llama-3.1-8B-Instruct"
		)
//		let server2 = Server(
//			name: "OpenAI Server 1",
//			url: "https://api.openai.com",
//			apiType: .openAI
//		)
//		let server3 = Server(
//			name: "Llama Server 2",
//			url: "http://example.com",
//			apiType: .llamaStack
//		)
		
		context.insert(server1)
//		context.insert(server2)
//		context.insert(server3)
		
		// Save the context
		try context.save()
		
		return container
	}
}

// View to wrap preview content
	private struct PreviewWrapper: View {
		let container: ModelContainer?
		let error: Error?
		
		init() {
			do {
				self.container = try PreviewUtils.createPreviewContainer()
				self.error = nil
			} catch {
				self.container = nil
				self.error = error
			}
		}
		
		var body: some View {
			if let container = container {
				LlamaStackChatView()
					.modelContainer(container)
			} else {
				Text("Preview failed: \(error?.localizedDescription ?? "Unknown error")")
			}
		}
}

#Preview {
	PreviewWrapper()
}
