//
//  SwiftOpenAIChatView.swift
//  vLLMSwiftApp
//
//  Created by Richard Naszcyniec on 5/14/25.
//

import SwiftData
import SwiftUI

/// View used to interact with vLLM using the [SwiftOpenAI](https://github.com/jamesrochabrun/SwiftOpenAI) OSS project
///
/// This view contains the code required to implement a text chat with a vLLM server, or Llama Stack server via an OpenAI-compatible endpoint.
/// Interaction with a  server is performed using SwiftOpenAI functionality.
struct SwiftOpenAIChatView: View {
	// get the Swift Data context and get the current sorted data for use in this view
	@Environment(\.modelContext) private var modelContext
	/// list of servers persisted by Swift Data that is used by the user to select what server to interact with
	@Query(sort: \Server.name, order: .forward) var serverList: [Server]
	
	// Declare the @State variables this view owns and will share with subviews
	// Clear ownership of variables in required for SwiftUI updates
	@State private var pickedServer: Server?  // Optional value bound to Picker
	@State private var messages: [ChatMessage] = []  // Local array for chat messages that are observable
	@StateObject private var chatManager: SwiftOpenAIChatViewModel = .init()  // code for interacting with SwiftOpenAI
	@State private var lastScrollListId: UUID?  // use to make sure we always scroll messsages to the bottom
	@State private var isSending: Bool = false  // track sending to LLM state
	@State private var currentLLMChatMessage: ChatMessage?
	@State private var updateScroll: Bool = false
	
	/// view that defines the user interface
	var body: some View {
		NavigationStack {
			VStack {
				// Picker for selecting a server to communicate with
				Picker("Select Server", selection: $pickedServer) {
					ForEach(serverList) { server in
						Text(server.name)
							.tag(server as Server?)  // Tag is the Server object
					}
				}
				.pickerStyle(.menu)  // Use .menu for a dropdown style
				.padding([.horizontal, .vertical], 8)  // specifically around the picker
				.background(.white)
				.clipShape(RoundedRectangle(cornerRadius: 10))
				.shadow(radius: 2)
				// now adjust everything above
				.padding([.vertical, .horizontal], 8)  // padding around the shape and shadow
				.containerRelativeFrame(.vertical) { length, _ in
					length * (1 - 0.90)  // make it 10% whatever the container height is
				}
				
				Spacer()
				// Chat Messages are contained in a scroll view that we can control programatically
				// We want to new messages to always appear at the bottom and dynamically expand with an llm server response
				ScrollViewReader { proxy in
					ScrollView {
						LazyVStack(alignment: .leading, spacing: 10) {
							ForEach(
								messages.sorted(by: { $0.timestamp < $1.timestamp })
							) { message in
								ChatBubble(message: message)
									.id(message.id)
							}
						}
					}
					.padding([.vertical, .horizontal], 8)  // overall cotainer size will fit in available space
					.defaultScrollAnchor(.bottom)
					.onChange(of: updateScroll) {
						if updateScroll {
							withAnimation(.easeInOut(duration: 0.2)) {
								proxy.scrollTo(lastScrollListId, anchor: .bottom)
								self.updateScroll = false
							}
						}
					}
				}
				// display the prompt input view and get the message to send via a closure
				ChatInputView(isSending: isSending) { message in
					isSending = true  // starting the process of getting an inference result
					// append the prompt being sent to the LLM
					let userMessage = ChatMessage(content: message, isUser: .user)
					messages.append(userMessage)
					lastScrollListId = userMessage.id  // scroll to the user message
					updateScroll = true
					
					// need to make sure llmResponse is reset
					currentLLMChatMessage = ChatMessage(
						content: chatManager.llmResponse,
						isUser: .assistant
					)
					messages.append(currentLLMChatMessage!)
					lastScrollListId = currentLLMChatMessage!.id  // forces update to scrollview
					updateScroll = true
					
					Task {
						do {
							// make sure the assistantMessage we set is updated with the llm response
							await chatManager.sendMessage(message)
						}
						// use the following line if you don't want to stream the response
						//	messages.append( ChatMessage(content: chatManager.llmResponse, isUser: .assistant))
						isSending = false
						
						//	print( "response: \(chatManager.llmResponse)")
					}
				}
				.padding([.vertical, .horizontal], 8)
				.containerRelativeFrame(.vertical) { length, _ in
					length * (1 - 0.80)  // make it 25% whatever the container height is
				}
			}
		}
		.navigationTitle("SwiftOpenAI Chat")
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
		// MARK: streaming responses from LLM server are handled here
		.onChange(of: chatManager.llmResponse) { _, newResponse in
			if let lastAssistantMessage = currentLLMChatMessage {
				lastAssistantMessage.content = newResponse  // change out the value based on what is returned
				updateScroll = true
			}
			
		}
	}
	
	//
	// Chat Bubble View for displaying messages
	//
	/// View used to display a chat message
	///
	/// Creaes a view formatted as a "bubble" to represent a chat message.
	/// If the message originates from the application user, then the text is aligned to the right side of the view, is colored white over blue.
	/// If the message is not from the user, the it is aligned to the left side of the view, with text set in the primarty device color over gray.
	/// The varying alignment helps to visually distinguish between messages sent by the user from responses from the server.
	private struct ChatBubble: View {
		let message: ChatMessage
		
		var body: some View {
			HStack {
				switch message.isUser {  // use a switch here for flexibility when formatting on role
					case .user:
						Spacer()  // forces the bubble to the right
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
						Spacer()  // forces the bubble to the left
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
private struct PreviewUtils {
	static func createPreviewContainer() throws -> ModelContainer {
		let schema = Schema([Server.self])
		let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
		let container = try ModelContainer(
			for: schema,
			configurations: configuration
		)
		
		let context = container.mainContext
		
		// Insert sample data
		let server1 = Server(
			name: "local OpenAPI-compatible server",
			url: "http://localhost:11434",
			apiType: .openAI,
			modelName: "llama3.2:latest"
		)
		//		let server2 = Server(
		//			name: "OpenAI Server",
		//			url: "https://api.openai.com",
		//			apiType: .openAI
		//		)
		//		let server3 = Server(
		//			name: "Some other server",
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
			SwiftOpenAIChatView()
				.modelContainer(container)
		} else {
			Text(
				"Preview failed: \(error?.localizedDescription ?? "Unknown error")"
			)
		}
	}
}

#Preview {
	PreviewWrapper()
}

