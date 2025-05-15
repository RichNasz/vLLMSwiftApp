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

/// Model class for the LlamaStackChatView
///
///Uses @Observable macro instead of @ObservableObject and @Published as it is easier to proagate changes
/// to the llmResponse for the UI to pick up on.
///
@Observable class LlamaStackChatViewModel: ObservableObject {
	
	/// stores the response from the LLM server
	var llmResponse: String = ""
	/// stores llama-stack server to connect to, Nil value is allowed since the server might not be known at class instantiation
	private var server: Server?
	
	init(){
		// do nothing for now since so far there are defaults for all values
	}
	
	//
	// we need this function since the class may be instantiated in a view struct before the server is known
	//
	/// Used to set the llama-stack sever to connect to
	///
	/// This function since the class may be instantiated in a view struct before the server is known.
	/// - Parameter server: llama-server that any inference call will be sent to
	///
	func setServer( server: Server) {
		self.server = server
		llmResponse = ""	// also reset the response since there is a new server
		// TODO: consider adding code to save the exisitng conversation before resetting so user can return to it
	}
	

	/// function called to send a message to the llama-stack for inference
	///
	/// Will check for any errors that would cause an error:
	/// 1. A ``Server`` has not been selected to send the message to
	/// - Parameter message: simple string value with the prompt to send to the server
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
	
	/// define the full scope of errors that could be thrown within the class
	enum LlamaStackError: Error {
		case invalidServerType
		case noURL
		case noModelName
		case invalidURL
		case apiError(statusCode: Int)
		case encodingError
		case decodingError
	}
	
	/// Sends an request to the LLM server for inference
	///
	/// Private function for the class since we want to error checking done using the sendMessage function first.
	/// - Parameters:
	///   - prompt: the user request (prompt) to send for inference
	///   - lsServer: the llama-stack server definition to send the inference request to
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
										.InterleavedContentItem(
											.text(
												Components.Schemas.TextContentItem(
													_type: .text,
													text: prompt
												)
											)
										)
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
				//	placeholder for potential action such as shown below
				//	llmResponse += "\n--end of response--\n"	// optionally add an end of message marker
			}
		}
	}
}
