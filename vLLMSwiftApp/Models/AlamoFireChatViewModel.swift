//
//  AlamoFireChatViewModel.swift
//  vLLMSwiftApp
//
//  Created by Richard Naszcyniec on 6/17/25.
//
//
// Manages the interaction with the vllm server, and updates the UI with streaming responses and chat history.
//

import Foundation
import Alamofire


/// Model class for the AlamoFireChatView.
/// OpenAI endpoint communications are performed using the [Alamofire](https://github.com/Alamofire/Alamofire) open source project.
///
///Uses @Observable macro instead of @ObservableObject and @Published as it is easier to proagate changes
/// to the ``llmResponse`` for SwiftUI to detect and re-render.
///
@Observable class AlamoFireChatViewModel: ObservableObject {
	/// Captures the text response from the LLM server. Is reset at the start of each new request.
	var llmResponse: String = ""
	/// stores vLLM server to connect to, Nil value is allowed since the server might not be known at class instantiation
	private var server: Server?
	
	/// Placeholder for potential future initialization. Currently all instance properties are set to default values.
	init(){
		// do nothing for now since so far there are defaults for all values
	}
	
	/// Method used to set the OpenAI-compatible sever to connect to
	///
	/// This function exists since the class gets instantiated in a view struct before the user selects the server is to connect to for inference.
	/// - Parameter server: server that any inference call will be sent to
	///
	func setServer( server: Server) {
		self.server = server
		llmResponse = ""	// also reset the response since there is a new server
		// TODO: consider adding code to save the exisitng conversation before resetting so user can return to it
	}
	
	/// Send a message to the user selected server for inference.
	/// This is the method that kicks off communications with the vLLM server.
	///
	/// Will check for any errors that would cause an error, and set the ``llmResponse`` with an eror string if an error occurs.
	/// 1. A ``Server`` has not been selected to send the message to
	///
	/// - Parameter message: simple string value with the prompt to send to the server
	///
	/// - Throws
	/// 	`alamoFireAIInferenceError` of various types as well as any other thrown error types that result from downstream calls.
	///
	func sendMessage(_ message: String) async {
		if server == nil {
			llmResponse = "Error: Server not set. Message could not be sent"
			return
		}
		
		do {
			try await sendLLMrequest(forPrompt: message, onServer: server!)
		}
		catch {
			print("Alamofire error sending message: \(error)")
			llmResponse = "Alamofire Error: \(error)"
		}
	}
	
	/// Structure that represens a request to the OpenAI chat completions endpoint.
	///
	/// >Note: The structure does not include all of the parameters that can be sent to an OpenAI endpoint for a streaming request.
	/// See the [OpenAI chat completion](https://platform.openai.com/docs/api-reference/chat/create) documentation for more details on additional keys that can be added to the structure.
	///
	struct OpenAIRequest: Encodable {
		/// Model ID used to generate the response
		let model: String
		/// A list of messages comprising the conversation so far.
		let messages: [OpenAIMessage]
		/// If set to true, the model response data will be streamed to the client as it is generated using server-sent events.
		let stream: Bool = true
		
		/// used to encode the constants above. If a constant needs another encode value then provide the string value. i.e. case maxCompletionTokens = "max_completion_tokens"
		enum CodingKeys: String, CodingKey {
			case model
			case messages
			case stream
		}
	}
	
	/// Represents a Developer or System message to send in a OpenAI API chat completion request.
	/// See the [OpenAI chat completion](https://platform.openai.com/docs/api-reference/chat/create) documentation for more details
	///
	/// >Warning: Sending Assistant, Tool, and Function messages are not supported.
	///
	struct OpenAIMessage: Encodable {
		/// see OpenAI spec for message types: developer (for o1+ models), system (for -o1 models), user, assistant, tool
		let role: String
		/// contents fo the message
		let content: String
	}
	
	/// Used to capture the data that comes from an OpenAI API response to a chat completion request.
	/// > Important: Not every value possible to send for a chat streaming response is incuded.
	/// Review the [OpenAI create chat streaming documentation](https://platform.openai.com/docs/api-reference/chat-streaming)
	/// for more details.
	///
	/// We don't need to implement all of the possible values that are returned since the JSONDecoder does not force that behavior.
	/// Since the struct will only be used for reponses, it is marked Decodable instead of Codable.
	/// Finally, we are using camel case, and the OpenAI API returns snake case. Code relies on the JSONDecoder to handle the conversion.
	///
	struct OpenAIStreamResponse: Decodable {
		/// A unique identifier for the chat completion. Each chunk has the same ID.
		let id: String
		/// The object type, which is always chat.completion.chunk
		let object: String
		/// A list of chat completion choices.
		let choices: [Choice]
		
		/// Struct for the individual choice keys that can appear in `OpenAIStreamResponse.choices`
		struct Choice: Decodable {
			/// A chat completion delta generated by streamed model responses.
			let delta: Delta
			/// The reason the model stopped generating tokens.
			let finishReason: String?
		}
		
		/// A chat completion delta generated by streamed model responses
		struct Delta: Decodable {
			/// The contents of the chunk message.
			let content: String?
			/// The role of the author of this message.
			let role: String?
		}
	}
	
	/// Used to capture errors that may result from an OpenAI call.
	/// Since the struct will only be used for reponses, it is marked Decodable instead of Codable.
	struct OpenAIErrorResponse: Decodable {
		let error: OpenAIError
	}
	
	/// Structure for an individual error.
	/// See [OpenAI documentation](https://platform.openai.com/docs/api-reference/responses-streaming/error) for more details.
	///
	struct OpenAIError: Decodable {
		// descriptive error message
		let message: String?
		/// The type of the event. Always error.
		let type: String?
		/// The error parameter.
		let param: String?
		/// The error code.
		let code: String?
	}
	
	
	/// Defines the full scope of errors that could be thrown specific to this class.
	private enum alamoFireAIInferenceError: Error {
		case noModelName
		case invalidURL
		case httpError(statusCode: Int, description: String)
		case encodingError
		case decodingError
		case apiError(statusCode: Int, description: String)
	}
	
	/// Function responsible for actually sending an inference request to the vLLM server.
	///
	/// Private function for the class since we want to error checking done using the sendMessage function first.
	///
	/// Includes the following runtime behaviors to attempt auto correction of errors:
	/// * Automatically adds a default URL path if none is provided in the server definition: "/v1/chat/completions"
	///
	/// - Parameters:
	///   - prompt: the user request (prompt) to send for inference
	///   - onServer: the server definition to send the inference request to
	///
	/// - Throws
	/// 	`alamoFireAIInferenceError` of various types as well as any other thrown error types that result from downstream calls.
	///
	private func sendLLMrequest(forPrompt prompt: String, onServer: Server) async throws {
		// Series of guard statements on important variables, constants and values used in code
		// Stops execution if a problem is encounterd.
		// break down URL string into URL components if we can
		guard var urlComponents = URLComponents(string: onServer.url) else {
			throw alamoFireAIInferenceError.invalidURL
		}
		// make sure scheme is valid (i.e. https) and host contains a value
		guard urlComponents.scheme != nil, urlComponents.host != nil else {
			throw alamoFireAIInferenceError.invalidURL
		}
		// make sure a model name is provided
		guard let modelName = onServer.modelName else {
			throw alamoFireAIInferenceError.noModelName
		}
		
		// if the path is empty then, add in the default path for OpenAI
		if urlComponents.path.isEmpty {
			urlComponents.path = "/v1/chat/completions"
		}
		
		//
		// start setting up for the OpenAI call
		//
		// Body conforms to the streaming call defined here: https://platform.openai.com/docs/api-reference/chat/create
		let requestBody = OpenAIRequest(
			model: modelName,
			messages: [OpenAIMessage(role: "user", content: prompt)],
		)
		
		let headers: HTTPHeaders = [
			"Authorization": "Bearer \(onServer.apiKey ?? "")",
			"Content-Type": "application/json"
		]
		
		// Assigned a DataStremRequest
		let dataStreamRequest = AF.streamRequest(
			urlComponents.string ?? onServer.url,
			method: .post,
			parameters: requestBody,
			encoder: JSONParameterEncoder.default,
			headers: headers
		)
			.validate(statusCode: [200])	// only status code 200 is a success
		
		defer { dataStreamRequest.cancel() } // make sure the request gets cancelled no matter where we exit
		// check to see if an error is captured by alamofire during requst
		if let afError = dataStreamRequest.error {
			throw alamoFireAIInferenceError.apiError(statusCode: afError.responseCode ?? -1, description: afError.underlyingError?.localizedDescription ?? "No description available.")
		}
			
		// HTTP error codes that OpenAI may generate
		let openAIErrorCodes = [400, 401, 403, 429, 404, 500, 503]
		
		llmResponse = ""	// reset the observed variable for vLLM response before processing streaming return chunks.
		
		// Create a DataStreamTask used to await streams of serialized values.
		let streamTask = dataStreamRequest.streamTask()
		do {
			streamTask.resume()	// Make sure the stream is running
			for try await stringStream in streamTask.streamingStrings() { // asynchronous sequence of strings to proces
				// check to see if an error is captured by alamofire during a chunk retrieval
				if let afError = dataStreamRequest.error {
					throw alamoFireAIInferenceError.apiError(statusCode: afError.responseCode ?? -1, description: afError.underlyingError?.localizedDescription ?? "No description available.")
				}
				
//				let result = stringStream.result
				let value = (stringStream.value ?? "") as String
				
				if let completion = stringStream.completion, let error = completion.error {
					switch error {
						case .responseValidationFailed(let reason):
							switch reason {
								case .unacceptableStatusCode(let code):	// where we can pick up the HTTP error code
									if openAIErrorCodes.contains(code) {
										throw alamoFireAIInferenceError.apiError(statusCode: code, description: value)
									} else {
										throw alamoFireAIInferenceError.apiError(statusCode: code, description: "unexpected error: \(value)")
									}
								default:
									throw alamoFireAIInferenceError.apiError(statusCode: -1, description: "unexpected response validation error: \(reason)")
							}
						case .invalidURL:
							throw alamoFireAIInferenceError.invalidURL
						default:
							throw alamoFireAIInferenceError.apiError(statusCode: -1, description: "unexpected alamofire completion error: \(error)")
					}
				}
				
				// check for a known HTTP error that is part of the value string
				let firstSpace = value.firstIndex(of: " ") ?? value.endIndex
				let firstWord = value[..<firstSpace]
				if let statusCode = Int(String(firstWord)) {
					if openAIErrorCodes.contains(statusCode) {
						throw alamoFireAIInferenceError.apiError(statusCode: statusCode, description: value)
					}
				}
				
				// Data is steaming with Server-Sent Events (SSE) protocol.
				// Each line returned that we want to process will have a prefix of "data:" in front of it.
				//
				// Skip empty lines or non-data lines
				guard value.starts(with: "data: "), !value.contains("[DONE]") else {
					continue
				}
				
				// Remove SSE "data: " prefix and trim whitespace
				let jsonString = value.dropFirst("data: ".count).trimmingCharacters(in: .whitespaces)
				let responseData: OpenAIStreamResponse = try decodeJSON( jsonString )	// Swift will infer type to decode to from the explicit constant type
				
				// With all error checking done, and the JSON decoded, the results can be processed
				try processChatCompletionChunk( responseData )
			}
		}
	}
	
	/// Process a valid chunk of text from an OpenAI call.
	/// The chunk may include a finish reason that may trigger throwing an error.
	/// See [chat completion chunk object information for more details.](https://platform.openai.com/docs/api-reference/chat-streaming)
	private func processChatCompletionChunk(_ response: OpenAIStreamResponse) throws {
		if let finishReason = response.choices.first?.finishReason {
			// Handle specific finish reasons
			switch finishReason {
				case "stop":
					return // Normal completion. Do nothing
				case "length":
					throw alamoFireAIInferenceError.apiError(
						statusCode: -1,
						description: "The maximum number of tokens specified in the request was reached, and the model did not generate any more text."
					)
				case "content_filter":
					throw alamoFireAIInferenceError.apiError(
						statusCode: -1,
						description: "Model omitted content due to a flag in a content filter.")
				case "tool_calls":
					throw alamoFireAIInferenceError.apiError(
						statusCode: -1,
						description: "Model called a tool, but code doesn't support this.")
				case "function_call":	// deprecated
					throw alamoFireAIInferenceError.apiError(
						statusCode: -1,
						description: "Model called a function, but code doesn't support this.")
				default:
					throw alamoFireAIInferenceError.apiError(
						statusCode: -1,
						description: "Received and unknown finish reason from the API: \(finishReason)"
					)
			}
		}
		
		// Append content if available
		if let content = response.choices.first?.delta.content {
			llmResponse += content
		}
	}
	
	/// Utility method to centralize all JSON decoding from strings with assocaited error handling.
	/// The key decoding strategy is set to convert snake-case keys (used by OpenAI) to camel-case keys used in the code.
	///
	/// This is a generic method since there may be multipe types to decode.
	/// For example, in the following sample code, the type destination (T) is specified by the assigning the type to the constant named responseData, which Swift uses to infer the type when the method is called.
	/// ```swift
	///	let responseData: OpenAIStreamResponse = try decodeJSON( jsonString )
	/// ```
	/// @typeParam T - The typ that implements the Decodable protocol that the JSON string will be be deconded into
	///
	/// - Parameters:
	///   - jsonString : the string to decode
	///
	/// - Throws
	/// 	`alamoFireAIInferenceError.decodingError` if there is an issue with the source JSON string
	///
	private func decodeJSON<T: Decodable>(_ jsonString: String) throws -> T {
		// Set up the JSON decoder
		let responseDecoder = JSONDecoder()
		responseDecoder.keyDecodingStrategy = .convertFromSnakeCase
		
		guard let data = jsonString.data(using: .utf8) else {
			throw alamoFireAIInferenceError.decodingError
		}
		do {
			return try responseDecoder.decode(T.self, from: data)
		} catch {
			throw alamoFireAIInferenceError.decodingError
		}
	}
	
}

