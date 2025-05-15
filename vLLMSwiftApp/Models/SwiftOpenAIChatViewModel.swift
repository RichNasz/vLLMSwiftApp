//
//  SwiftOpenAIChatViewModel.swift
//  vLLMSwiftApp
//
//  Created by Richard Naszcyniec on 5/14/25.
//

import Foundation
import SwiftOpenAI


/// Model class for the SwiftOpenAIChatView
///
///Uses @Observable macro instead of @ObservableObject and @Published as it is easier to proagate changes
/// to the llmResponse for the UI to pick up on.
///
@Observable class SwiftOpenAIChatViewModel: ObservableObject {
	
	/// Captures the text response from the LLM server
	var llmResponse: String = ""
	/// stores llama-stack server to connect to, Nil value is allowed since the server might not be known at class instantiation
	private var server: Server?
	
	/// Placeholder for potential future initialization. Currently all instance properties are set to default values.
	init(){
		// do nothing for now since so far there are defaults for all values
	}
	
	/// Used to set the OpenAI-compatible sever to connect to
	///
	/// This function must exits since the class gets instantiated in a view struct before the server is to connect to is selected by the user..
	/// - Parameter server: server that any inference call will be sent to
	///
	func setServer( server: Server) {
		self.server = server
		llmResponse = ""	// also reset the response since there is a new server
		// TODO: consider adding code to save the exisitng conversation before resetting so user can return to it
	}
	
	/// Send a message to the user selected server for inference
	/// 
	/// Will check for any errors that would cause an error, and set the ``llmResponse`` with an eror string if an error occures.
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
	
	/// Define the full scope of errors that could be thrown within the class
	private enum swiftOpenAIInferenceError: Error {
		case invalidServerType
		case noURL
		case noModelName
		case invalidURL
		case apiError(statusCode: Int, description: String)
		case encodingError
		case decodingError
	}

	/// Sends an request to the LLM server for inference
	///
	/// Private function for the class since we want to error checking done using the sendMessage function first.
	/// - Parameters:
	///   - prompt: the user request (prompt) to send for inference
	///   - lsServer: the llama-stack server definition to send the inference request to
	private func sendLLMrequest(forPrompt prompt: String, onServer openAIServer: Server) async throws {
		
		// series of guard stements used since we will use the let values later in the code
		guard let url = URL(string: openAIServer.url) else {
			throw swiftOpenAIInferenceError.invalidURL
		}
		guard let modelName = openAIServer.modelName else {
			throw swiftOpenAIInferenceError.noModelName
		}
		
		let inferenceService: OpenAIService // allowed due to deferred initialization
		if let apiKey = openAIServer.apiKey {	// if we have an API key then use it
			inferenceService = OpenAIServiceFactory.service(apiKey: .apiKey(apiKey), baseURL: openAIServer.url, )
		} else {
			inferenceService = OpenAIServiceFactory.service(baseURL: openAIServer.url)
		}
		
		// Set the parameters that will be used to request inference.
		// Only two parameters are required, but there are many more available to enhance future code with.
		// Add a .system message in the future for prompt engineering
		let inferenceParameters = ChatCompletionParameters(
			messages: [.init(role: .user, content: .text(prompt))],
			model: .custom(modelName)
		)
		
		// Start the stream
		do {
			llmResponse = "" // need to set the variable that holds the response to empty before inference call is made
			let stream = try await inferenceService.startStreamedChat(parameters: inferenceParameters)
			for try await result in stream {
				let content = result.choices?.first?.delta?.content ?? ""
				// Directly set the llmResponse in the for loop since the class is observable and we want updates
				self.llmResponse += content
			}
		}
		catch APIError.responseUnsuccessful(let description, let statusCode) {
			throw swiftOpenAIInferenceError.apiError(statusCode: statusCode, description: description)
		}
		catch {
			throw swiftOpenAIInferenceError.apiError(statusCode: -999, description: "Unexpected error: \(error.localizedDescription)" )
		}
		
		
	}
	
}
