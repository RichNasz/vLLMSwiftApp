//
//  MacPawOpenAIChatViewModel.swift
//  vLLMSwiftApp
//
//  Created by Richard Naszcyniec on 5/19/25.
//

import Foundation
import OpenAI


/// Model class for the MacPawOpenAIChatView
///
/// Uses @Observable macro instead of @ObservableObject and @Published as it is a more modern way to proagate changes
/// to  ``llmResponse``  for SwiftUI to detect and re-render.
///
@Observable class MacPawOpenAIChatViewModel: ObservableObject {
	
	/// Captures the text response from the LLM server. Is reset at the start of each new request.
	var llmResponse: String = ""
	/// stores llama-stack server to connect to, Nil value is allowed since the server might not be known at class instantiation
	private var server: Server?
	
	/// Placeholder for potential future initialization. Currently all instance properties are set to default values.
	init(){
		// do nothing for now since so far there are defaults for all values
	}
	
	/// Used to set the OpenAI-compatible sever to connect to
	///
	/// This function exists  since the class gets instantiated in a view struct before the user selects the server is to connect to for inference.
	/// - Parameter server: server that any inference call will be sent to
	///
	func setServer( server: Server) {
		self.server = server
		llmResponse = ""	// also reset the response since there is a new server
		// TODO: consider adding code to save the exisitng conversation before resetting so user can return to it
	}
	
	/// Send a message to the user selected server for inference.
	///
	/// Will check for any errors that would cause an error, and set the ``llmResponse`` with an eror string if an error occurs.
	/// 1. A ``Server`` has not been selected to send the message to
	/// - Parameter message: simple string value with the prompt to send to the server
	///
	func sendMessage(_ message: String) async {
		if server == nil {
			llmResponse = "Error: Server not set. Message could not be sent"
			return
		}
		
		do {
			try await sendLLMrequest(forPrompt: message, onServer: server!)
		}
		catch macPawOpenAIInferenceError.apiError (let statusCode, let description) {
			llmResponse = "API Error: <\(statusCode)>, \(description)"
		}
		catch macPawOpenAIInferenceError.invalidURL {
			llmResponse = "Error: Invalid server URL: \(server?.url ?? "No URL specified")"
		}
		catch {
			print("Error sending message: \(error)")
			llmResponse = "Error: \(error)"
		}
		
	}
	
	/// Define the full scope of errors that could be thrown within the class
	private enum macPawOpenAIInferenceError: Error {
		case invalidServerType
		case noURL
		case noModelName
		case invalidURL
		case apiError(statusCode: Int, description: String)
		case encodingError
		case decodingError
	}
	
	/// Function responsible for actually sending and LLM request to the server.
	///
	/// Private function for the class since we want to error checking done using the sendMessage function first.
	/// - Parameters:
	///   - prompt: the user request (prompt) to send for inference
	///   - lsServer: the llama-stack server definition to send the inference request to
	private func sendLLMrequest(forPrompt prompt: String, onServer: Server) async throws {
		
		// series of guard stements used since we will use the let values later in the code
		guard let urlComponents = URLComponents(string: onServer.url) else {
			throw macPawOpenAIInferenceError.invalidURL
		}
		
		// make sure scheme is valid (i.e. https) and host contains a value
		guard urlComponents.scheme != nil, urlComponents.host != nil else {
			throw macPawOpenAIInferenceError.invalidURL
		}
		
		guard let modelName = onServer.modelName else {
			throw macPawOpenAIInferenceError.noModelName
		}
		
		// Need to set up a configuration to use to create the OpenAI class.
		// Break down the URL string for the selected server to get the required connection parameters.
		// Set the API key from the selected server in the token parameter
		
		// Set the value used for the base path to empty if there server URL has no path component
		let serverPath = urlComponents.path.isEmpty ? "/v1" : urlComponents.path
		
		let defaultPort = (urlComponents.scheme ?? "https") == "https" ? 443 : 80
		
		let macPawOpenAIConfiguration = OpenAI.Configuration(
			token: onServer.apiKey ?? "",
			organizationIdentifier: nil,
			host: urlComponents.host ?? "localhost",
			port: urlComponents.port ?? defaultPort,
			scheme: urlComponents.scheme ?? "https",
			basePath: serverPath,
			timeoutInterval: 60
		)
		
		// create the service we need using the configuration from above
		let openAI = OpenAI(configuration: macPawOpenAIConfiguration)
		
		// Set the parameters that will be used to request inference.
		// Only two parameters are required, but there are many more available to enhance future code with.
		// Add a .system message in the future for prompt engineering
		let chatQuery = ChatQuery(messages: [.init(role: .user, content: prompt)!], model: modelName)
		
		llmResponse = "" // need to set the variable that holds the response to empty before inference call is made
		// use structured concurrency to make the inference request and process results
		do {
			for try await result in openAI.chatsStream(query: chatQuery) {
				// we need to check the result for errors first that are sent back as
				
				let content = result.choices.first?.delta.content ?? ""
				// Directly set the llmResponse in the for loop since the class is observable and we want updates
				self.llmResponse += content
				
				let finishReason = result.choices.first?.finishReason
				switch finishReason {
					case .stop:
						break // TODO: implement any code for last chunk returned
					case .length:
						throw macPawOpenAIInferenceError.apiError(statusCode: -1, description: "OpenAI cumulative tokens exceed max_tokens")
						// TODO: implement any code if the cumulative tokens exceed max_tokens
					case .contentFilter:
						throw macPawOpenAIInferenceError.apiError(statusCode: -1, description: "OpenAI safety filters were triggered")
						// TODO: code for when OpenAI safety filters are triggered
					case .error:
						throw macPawOpenAIInferenceError.apiError(statusCode: -1, description: "OpenAI Error: check prompt")
						// TODO: find where error details are available
					case .functionCall:
						break	// TODO: code for handling function calls
					case .toolCalls:
						break	// TODO: code for handling tool calls
					case .none:
						throw macPawOpenAIInferenceError.apiError(statusCode: -1, description: "OpenAI Error: response is incomplete or interrupted")
						// TODO: implement code for cases where the response is incomplete or interrupted.
				}
				
			}
		}
		catch let error as OpenAIError {
			let errorText = error.localizedDescription
			switch errorText {
				case let errorCheck where errorCheck.contains("400"):
					throw macPawOpenAIInferenceError.apiError(statusCode: 400, description: "Bad request: Check model name")
				case let errorCheck where errorCheck.contains("401"):
					throw macPawOpenAIInferenceError.apiError(statusCode: 401, description: "Invalid API key")
				case let errorCheck where errorCheck.contains("429"):
					throw macPawOpenAIInferenceError.apiError(statusCode: 429, description: "Rate limit of quota exceeded")
				case let errorCheck where errorCheck.contains("503"):
					throw macPawOpenAIInferenceError.apiError(statusCode: 429, description: "The engine is currently overloaded, please try again later")
				default:
					throw macPawOpenAIInferenceError.apiError(statusCode: -999, description: " Unkown API error: \(errorText)")
			}
		}
		catch {
			// Print error type and details when debugging
			//			print("Error type: \(type(of: error))")
			//			print("API error description: \(error)")
			let errorText = error.localizedDescription
			switch errorText {
				case let errorCheck where errorCheck.contains("-1004"):
					throw macPawOpenAIInferenceError.apiError(statusCode: -1004, description: "Could not connect to the server")
				default:
					throw macPawOpenAIInferenceError.apiError(statusCode: -999, description: " \(errorText)")
			}
		}
	}
}
