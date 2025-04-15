//
//  LlamaStackChatViewModel.swift
//  vLLMSwiftApp
//
//  Created by Richard Naszcyniec on 4/18/25.
//
// manages the interaction with the LlamaStackChatActor, and updates the UI with streaming responses and chat history.
//


import Foundation
import LlamaStackClient

// using @Observable instead of @ObservableObject and @Published as it is easier to proagate changes
// to the llmResponse for the UI to pick up on.
//
@Observable class LlamaStackChatViewModel: ObservableObject {
	
	var llmResponse: String = ""	// TODO: determine if using an optional is better for code flow when empty
	private var server: Server?	// TODO: make sure proper optional checking is done
//	private var chatActor: LlamaStackChatActor?
	
	init(){
		// do nothing for now since so far there are defaults for all values
	}
	
	//
	// we need this function since the class may be instantiated in a view struct before the server is known
	//
	func setServer( server: Server) {
		self.server = server
		llmResponse = ""	// also reset the response since there is a new server
		// TODO: consider adding code to save the exisitng converstion before resetting so user can return to it
	}
	
	//
	// Use this function as an entry point and be sure to do error checking before attempting
	// to make a network call
	//
	func sendMessage(_ message: String) async {
		if server == nil {
			llmResponse = "Server not set. Message could not be sent"
			return
		}
		
		do {
			try await sendLLMrequest(forPrompt: message, onServer: server!)
		} catch {
        print("Error sending message: \(error)")
        llmResponse = "Error: \(error.localizedDescription)"
		}
		
	}
	
	//
	// standardize the errors that can be thrown
	//
	enum LlamaStackError: Error {
		case invalidServerType
		case noURL
		case noModelName
		case invalidURL
		case apiError(statusCode: Int)
		case encodingError
		case decodingError
	}
	
	//
	// Isolate this code to just for the class and make the API call
	//
	private func sendLLMrequest(forPrompt prompt: String, onServer lsServer: Server) async throws {
		
		// series of guard stements used since we will use the let values later in the code
		guard let url = URL(string: lsServer.url) else {
			throw LlamaStackError.invalidURL
		}
		guard let modelName = lsServer.modelName else {
			throw LlamaStackError.noModelName
		}
		
		let inference: RemoteInference // allowed due to deferred initialization
		if let apiKey = lsServer.apiKey {	// if we have an API key then use it
			inference = RemoteInference(url: url, apiKey: apiKey)
		} else {
			inference = RemoteInference(url: url)
		}
		
		// Directly set the llmResponse in the for loop since the class is observable and we want updates
		for await chunk in try await inference.chatCompletion(
			request:
				Components.Schemas.ChatCompletionRequest(
					model_id: modelName,
					messages: [
						.user(
							Components.Schemas.UserMessage(
								role: .user,
								content:
										.case1(prompt)
							)
						)
					],
					stream: true)
		) {
			switch (chunk.event.delta) {
				case .text(let s):
					if chunk.event.event_type == .start {
						await MainActor.run {	// make absolutely sure the value update is done on the SwiftUI thread
							llmResponse = ""		// reset at the start of a new message
						}
//						print("start of response event")
					}
					await MainActor.run {	// make absolutely sure the value update is done on the SwiftUI thread
						llmResponse += s.text
					}
					break
				case .image(let s):
					print("> \(s)")
					break
				case .tool_call(let s):
					print("> \(s)")
					break
			}
			if chunk.event.event_type == .complete {
//				await MainActor.run {	// make absolutely sure the value update is done on the SwiftUI thread
//					llmResponse += "\n--end of response--\n"	// optionally add an end of message marker
//				}
			}
		}
	}
}
