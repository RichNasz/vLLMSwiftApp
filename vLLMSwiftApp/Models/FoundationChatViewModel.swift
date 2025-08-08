//
//  FoundationChatViewModel.swift
//  vLLMSwiftApp
//
//  Created by Richard Naszcyniec on 6/21/25.
//

import Foundation

/// Model class for the FoundationChatView
///
/// Responsible for handling all the data associated with the vLLM inference call, as well as making the call.
/// Handles all network, HTTP, and OpenAI API errors.
///
/// Uses @Observable macro instead of @ObservableObject and @Published as it is easier to proagate changes
/// to the ``llmResponse`` for SwiftUI to detect and re-render.
///
@Observable class FoundationChatViewModel: ObservableObject {
	/// Captures the text response from the LLM server. Is reset at the start of each new request.
	var llmResponse: String = ""
	/// stores vLLM server to connect to, Nil value is allowed since the server might not be known at class instantiation
	private var server: Server?
	
	/// Placeholder for potential future initialization. Currently all instance properties are set to default values.
	init(){
		// do nothing for now since so far there are defaults for all values
	}
	
	/// Used to set the OpenAI-compatible sever endpoint to connect to
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
	/// Will check for any errors that would cause an error, and set the ``llmResponse`` with a string associated with the error if it exists.
	/// 1. A ``Server`` has not been selected to send the message to
	/// - Parameter message: simple string value with the prompt to send to the server
	///
	/// - Throws
	/// 	`foundationAIInferenceError` of various types as well as any other thrown error types that result from downstream calls.
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
			print("FoundationChatViewModel: error sending message: \(error)")
			llmResponse = "Error: \(error)"
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
		
		/// used to encode the constants above.
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
		/// see spec for message types: developer (for o1+ models), system (for -o1 models), user, assistant, tool
		let role: String
		/// string value of the message
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
	/// Since the struct will only be used for reponses, it is marked Decodable.
	struct OpenAIErrorResponse: Decodable {
		let error: OpenAIError
	}
	
	/// Structure for an individual error.
	/// See [OpenAI documentation](https://platform.openai.com/docs/api-reference/responses-streaming/error) for more details.
	///
	struct OpenAIError: Decodable {
		let message: String?	// descriptive error message
		let type: String? 	// error_type",
		let param: String?	// affected_parameter
		let code: String? 	// specific_error_code
	}
	
	/// Define the full scope of errors that could be thrown within the class
	private enum foundationAIInferenceError: Error {
		case noModelName
		case invalidURL
		case httpError(statusCode: Int, description: String)
		case encodingError
		case decodingError
		case apiError(statusCode: Int, description: String)
	}
	
	/// Function responsible for actually sending and LLM request to the server.
	///
	/// Private function for the class since we want to error checking done using the sendMessage function first.
	///  If the URL in the selected server is empty, then a default path ("/v1/chat/completions") for OpenAI is provided.
	///
	/// - Parameters:
	///   - prompt: the user request (prompt) to send for inference
	///   - onServer: the server definition to send the inference request to
	///
	/// - Throws: A range ``foundationAIInferenceError`` values
	///
	private func sendLLMrequest(forPrompt prompt: String, onServer: Server) async throws {
		// prepare the URL request to send
		let request = try prepareURLRequest(forPrompt: prompt, onServer: onServer)
		
		// Time to make the call to the vLLM server.
		// Calling a function to modularize the associated error handling
		let (bytes, response) = try await setupURLSession(request: request)
		
		// First error check is to see if we got an HTTP response from the request
		guard let httpResponse = response as? HTTPURLResponse else {
			throw foundationAIInferenceError.httpError( statusCode: -1, description: "Did not get an HTTP response from the URL")
		}
		
		llmResponse = ""	// reset before processing results.
		// If we don't get a successful HTTP response, then there are errors that need to be processed
		if !( 200...299 ~= httpResponse.statusCode ) {
			
			//
			// First check for known OpenAI error codes that can be returned.
			// ([More details.](https://platform.openai.com/docs/guides/error-codes)
			let openAIErrorCodes = [400, 401, 429, 403, 404, 500]
			
			
			// will need to process the stream to get the chunk with the error information in it.
			for try await line in bytes.lines {
				
				// if we know that we have an OpenAI error then there should be a predictable
				// line being returned that is JSON formatted
				if openAIErrorCodes.contains(httpResponse.statusCode) {
					guard line.contains("error") else {	// don't blindly trust that return will be as expected
						continue	// keep processing chunks
					}

					do {
						//let responseData = try responseDecoder.decode(OpenAIErrorResponse.self, from: data)
						let responseData: OpenAIErrorResponse = try decodeJSON( line )
						throw foundationAIInferenceError.apiError(statusCode: httpResponse.statusCode, description: responseData.error.message ?? "\(line)" )
						
					} catch DecodingError.dataCorrupted {	// be specific so we can throw the apiError above if needed
						throw foundationAIInferenceError.decodingError
					}
				} else { // we have an error, but it is not one that is expected, so just give the raw data in the error thrown
					throw foundationAIInferenceError.apiError(statusCode: httpResponse.statusCode, description: "\(line)" )
				}
			}
			return // execution should never reach here, but added anyway
		}
		
		// With response error checking complete, can proceed to process valid response chunks.
		//
		for try await line in bytes.lines {
			
			// Data is steaming with Server-Sent Events (SSE) protocol.
			// Each line returned that we want to process will have a prefix of "data:" in front of it.
			//
			// Skip empty lines or non-data lines
			guard line.starts(with: "data: "), !line.contains("[DONE]") else {
				continue
			}
			
			// Remove "data: " prefix and trim whitespace
			let jsonString = line.dropFirst("data: ".count).trimmingCharacters(in: .whitespaces)
			try processChatCompletionChunk(responseString: jsonString, httpResponseCode: httpResponse.statusCode)
			
		}
	}
	
	/// Method responsible for creating a ``URLRequest`` that will be used in a ``URLSession``
	///
	/// Robust error checking is performed to screen for potential errors that would cause a future error.
	/// See documented code for more information.
	///
	/// - Parameters:
	///   - prompt: the user request (prompt) to send for inference
	///   - onServer: the server definition to send the inference request to
	///
	/// - Returns: A properly configured ``URLRequest`` that can be used to create a ``URLSession`` with.
	///
	/// - Throws:
	/// 	- ``foundationAIInferenceError.invalidURL``
	/// 	- ``foundationAIInferenceError.noModelName``
	///
	private func prepareURLRequest(forPrompt prompt: String, onServer: Server) throws -> URLRequest {
		// series of guard stements used since we will use the let values later in the code
		// break down URL string into URL components if we can
		guard var urlComponents = URLComponents(string: onServer.url) else {
			throw foundationAIInferenceError.invalidURL
		}
		// make sure scheme is valid (i.e. https) and host contains a value
		guard urlComponents.scheme != nil, urlComponents.host != nil else {
			throw foundationAIInferenceError.invalidURL
		}
		// make sure a model name is provided
		guard let modelName = onServer.modelName else {
			throw foundationAIInferenceError.noModelName
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
		
		
		// if you need to increase the time out interval, then override the default init value for timeoutInterval
		// If you want to simplify the following line, you can split out the URL creation
		var request = URLRequest( url: (urlComponents.url ?? URL(string: urlComponents.string!))! )
		// make a request using POST
		request.httpMethod = "POST"
		
		// set the headers
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		request.setValue("Bearer \(onServer.apiKey ?? "")", forHTTPHeaderField: "Authorization")
		// convert struct data to JSON and create the message body that is part of the request
		request.httpBody = try JSONEncoder().encode(requestBody)
		
		return request
	}
	
	/// function responsible for setting up the URL session and handling any errors that may result.
	/// Seperated into a function for clarity as well as to isolate a robust catch block dedicates to low level URL errors
	///
	/// - Parameters:
	///   - request : The  ``URLRequest`` to create the URL sesssion
	///
	/// - Returns: A tuple that includes and async byte stream, and the URLResponse that are returned by ``URLSession.shared.bytes``
	///
	/// - Throws: ``foundationAIInferenceError.httpError``
	///
	private func setupURLSession(request: URLRequest) async throws -> (URLSession.AsyncBytes, URLResponse)
	{
		do {
			return try await URLSession.shared.bytes(for: request)
		} catch let error as URLError {
			// Handle specific URLErrors
			switch error.code {
				case .badURL:
					throw foundationAIInferenceError.invalidURL
				case .cannotConnectToHost:
					throw foundationAIInferenceError.httpError( statusCode: -1, description: "Attempt to connect to a host failed.")
				case .cannotFindHost:
					throw foundationAIInferenceError.httpError( statusCode: -1, description: "Could not find the server. Please check the address.")
				case .notConnectedToInternet:
					throw foundationAIInferenceError.httpError( statusCode: -1, description: "No internet connection")
				case .timedOut:
					throw foundationAIInferenceError.httpError( statusCode: -1, description: "The request timed out")
				default:
					throw foundationAIInferenceError.httpError( statusCode: -1, description: "An unexpected network error occurred: \(error.localizedDescription)")
			}
		} catch {
			throw foundationAIInferenceError.httpError( statusCode: -1, description: "An unexpected error occurred establishing URLSession: \(error.localizedDescription)")
		}
	}
	
	
	/// Method responsible for processing a chat completion request chunk.
	///
	/// - Parameters:
	///   - responseString : the JSON string containing a chat completion request chuck that needs to be decoded
	///   - httpResponseCode: is there is an error indicated in response, then the HTTP response code is included in any error thrown
	///
	/// - Throws:
	/// 	- ``foundationAIInferenceError.apiError``
	///
	private func processChatCompletionChunk( responseString: String, httpResponseCode: Int ) throws {
		do {
			let responseData: OpenAIStreamResponse = try decodeJSON( responseString )	// Swift will infer type to decode to from the explicit constant type
			
			// Check is we got a chunk with something other than text to append to the response
			if let choice = responseData.choices.first
			{
				if choice.finishReason != nil
				{
					// OpenAI can return a finishReason that may indicate a situation where we want to throw an error
					switch choice.finishReason! {
						case "stop":				//  model hit a natural stop point or a provided stop sequence
							break
						case "length":
							throw foundationAIInferenceError.apiError(statusCode: httpResponseCode, description: "The maximum number of tokens specified in the request was reached, and the model did not generate any more text.")
							
						case "content_filter":
							throw foundationAIInferenceError.apiError(statusCode: httpResponseCode, description: "Model omitted content due to a flag in a content filter.")
							
						case "tool_calls":
							throw foundationAIInferenceError.apiError(statusCode: httpResponseCode, description: "Model called a tool, but code doesn't support this.")
							
						case "function_call":	// deprecated
							throw foundationAIInferenceError.apiError(statusCode: httpResponseCode, description: "Model called a function, but code doesn't support this.")
							
						default:
							throw foundationAIInferenceError.apiError(statusCode: httpResponseCode, description: "Received and unknown finish reason from the API: \(choice.finishReason!)")
					}
				} else {
					// during a normal chat response, the finishReason will be nil, so add the chunk of text
					if let inferenceText = choice.delta.content, !inferenceText.isEmpty {
						llmResponse += inferenceText
					}
					
				}
			}
		} catch is DecodingError {
			throw foundationAIInferenceError.decodingError
		} catch {
			throw foundationAIInferenceError.apiError(statusCode: -1 , description: "Unexpected error encountered: \(error)")
		}
		
	}
	
	
	/// Utility method to centralize all JSON decoding from strings with associated error handling.
	/// The key decoding strategy is set to convert snake-case keys (used by OpenAI) to camel-case keys used in the code.
	///
	/// This is a generic method since there may be multiple types to decode.
	/// For example, in the following sample code, the type destination (T) is specified by the assigning the type to the constant named responseData, which Swift uses to infer the type when the method is called.
	/// ```swift
	///	let responseData: OpenAIStreamResponse = try decodeJSON( jsonString )
	/// ```
	/// @typeParam T - The typ that implements the Decodable protocol that the JSON string will be be deconded into
	///
	/// - Parameters:
	///   - jsonString : the string to decode
	///
	/// - Returns: An instance of the generic populated with data decoded from the JSON string
	///
	/// - Throws: ``foundationAIInferenceError.decodingError`` if there is an issue with the source JSON string
	///
	private func decodeJSON<T: Decodable>(_ jsonString: String) throws -> T {
		// Set up the JSON decoder
		let responseDecoder = JSONDecoder()
		responseDecoder.keyDecodingStrategy = .convertFromSnakeCase
		
		guard let data = jsonString.data(using: .utf8) else {
			throw foundationAIInferenceError.decodingError
		}
		do {
			return try responseDecoder.decode(T.self, from: data)
		} catch {
			throw foundationAIInferenceError.decodingError
		}
	}
	
}
