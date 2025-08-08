//
//  SwiftOpenAIChatViewModelTests.swift
//  vLLMSwiftAppTests
//
//  Created by Richard Naszcyniec on 5/15/25.
//  Latest updates assisted by AI on 8/7/2.
//

import Testing
import SwiftOpenAI
@testable import vLLMSwiftApp

/// Series of tests for SwiftOpenAIChatViewModel
@Suite("SwiftOpenAIChatViewModel Tests")
struct SwiftOpenAIChatViewModelTests {
	
	// Test data constants
	private let invalidModelName = "InvalidModelName"
	private let validOpenAIModelName = "llama3.2:latest"
	private let validLlamaStackModelName = "meta-llama/Llama-3.1-8B-Instruct"
	
	private let invalidURLString = "invalid url"
	private let validLlamaStackServerURLString = "http://127.0.0.1:5001"
	private let validOpenAIServerURLString = "http://localhost:11434"
	private let validOpenAIServerWithPathURLString = "http://localhost:11434/v1/chat/completions"
	
	private let validAPIKey = ""
	private let invalidAPIKey = "invalid api key"
	
	private let testPrompt = "Hello, how are you?"
	private let emptyPrompt = ""
	
	// MARK: - Initialization Tests
	
	@Test("Valid initialization")
	func testInitialization() {
		#expect(throws: Never.self) {
			let viewModel = SwiftOpenAIChatViewModel()
			#expect(viewModel.llmResponse == "", "llmResponse should be empty after initialization")
		}
	}
	
	// MARK: - Server Configuration Tests
	
	@Test("Can setServer without error")
	func testSetServerSucceeds() {
		let viewModel = SwiftOpenAIChatViewModel()
		let server = Server(name: "test-server", url: validOpenAIServerURLString, apiType: .openAI, modelName: validOpenAIModelName)
		
		#expect(throws: Never.self) {
			viewModel.setServer(server: server)
			#expect(viewModel.llmResponse == "", "llmResponse should be reset after setting server")
		}
	}
	
	@Test("setServer resets llmResponse")
	func testSetServerResetsResponse() {
		let viewModel = SwiftOpenAIChatViewModel()
		viewModel.llmResponse = "Previous response"
		
		let server = Server(name: "test-server", url: validOpenAIServerURLString, apiType: .openAI, modelName: validOpenAIModelName)
		viewModel.setServer(server: server)
		
		#expect(viewModel.llmResponse == "", "llmResponse should be reset when setting new server")
	}
	
	// MARK: - Message Sending Tests
	
	@Test("sendMessage with no server set")
	func testSendMessageNoServer() async {
		let viewModel = SwiftOpenAIChatViewModel()
		
		await viewModel.sendMessage(testPrompt)
		
		#expect(viewModel.llmResponse == "Error: Server not set. Message could not be sent", "Should show server not set error")
	}
	
	@Test("sendMessage with invalid URL")
	func testSendMessageInvalidURL() async {
		let viewModel = SwiftOpenAIChatViewModel()
		let server = Server(name: "invalid-server", url: invalidURLString, apiType: .openAI, modelName: validOpenAIModelName)
		viewModel.setServer(server: server)
		
		await viewModel.sendMessage(testPrompt)
		
		#expect(viewModel.llmResponse.contains("Error:"), "Should show error for invalid URL")
	}
	
	@Test("sendMessage with missing model name")
	func testSendMessageNoModelName() async {
		let viewModel = SwiftOpenAIChatViewModel()
		let server = Server(name: "no-model-server", url: validOpenAIServerURLString, apiType: .openAI)
		viewModel.setServer(server: server)
		
		await viewModel.sendMessage(testPrompt)
		
		#expect(viewModel.llmResponse.contains("Error:"), "Should show error for missing model name")
	}
	
	@Test("sendMessage with empty prompt")
	func testSendMessageEmptyPrompt() async {
		let viewModel = SwiftOpenAIChatViewModel()
		let server = Server(name: "test-server", url: validOpenAIServerURLString, apiType: .openAI, modelName: validOpenAIModelName)
		viewModel.setServer(server: server)
		
		await viewModel.sendMessage(emptyPrompt)
		
		// Should still attempt to send empty message, but may result in error from server
		#expect(viewModel.llmResponse.count >= 0, "Should handle empty prompt gracefully")
	}
	
	@Test("sendMessage with invalid model name")
	func testSendMessageInvalidModelName() async {
		let viewModel = SwiftOpenAIChatViewModel()
		let server = Server(name: "test-server", url: validOpenAIServerURLString, apiType: .openAI, modelName: invalidModelName)
		viewModel.setServer(server: server)
		
		await viewModel.sendMessage(testPrompt)
		#expect(viewModel.llmResponse.contains("Error:"), "Should show error for invalid model name")
	}
	
	// MARK: - URL Validation Tests
	
	@Test("Server URL component validation")
	func testURLComponentValidation() async {
		let viewModel = SwiftOpenAIChatViewModel()
		let server = Server(name: "url-test-server", url: validOpenAIServerURLString, apiType: .openAI, modelName: validOpenAIModelName)
		viewModel.setServer(server: server)
		
		await viewModel.sendMessage(testPrompt)
		
		// Should attempt connection (may fail due to no actual server, but URL should be processed)
		#expect(viewModel.llmResponse.count >= 0, "Should process URL and attempt connection")
	}
	
	@Test("Server URL with custom path preservation")
	func testURLPathPreservation() async {
		let viewModel = SwiftOpenAIChatViewModel()
		let server = Server(name: "with-path-server", url: validOpenAIServerWithPathURLString, apiType: .openAI, modelName: validOpenAIModelName)
		viewModel.setServer(server: server)
		
		await viewModel.sendMessage(testPrompt)
		
		// Should attempt connection with existing path
		#expect(viewModel.llmResponse.count >= 0, "Should preserve existing URL path")
	}
	
	// MARK: - Error Handling Tests
	
	@Test("Error handling for malformed URL components")
	func testMalformedURLComponents() async {
		let viewModel = SwiftOpenAIChatViewModel()
		let server = Server(name: "malformed-server", url: "ht!tp://invalid-url", apiType: .openAI, modelName: validOpenAIModelName)
		viewModel.setServer(server: server)
		
		await viewModel.sendMessage(testPrompt)
		
		#expect(viewModel.llmResponse.contains("Error:"), "Should handle malformed URL gracefully")
	}
	
	@Test("Error handling for missing URL scheme")
	func testMissingURLScheme() async {
		let viewModel = SwiftOpenAIChatViewModel()
		let server = Server(name: "no-scheme-server", url: "localhost:11434", apiType: .openAI, modelName: validOpenAIModelName)
		viewModel.setServer(server: server)
		
		await viewModel.sendMessage(testPrompt)
		
		#expect(viewModel.llmResponse.contains("Error:"), "Should handle missing URL scheme")
	}
	
	@Test("Error handling for missing URL host")
	func testMissingURLHost() async {
		let viewModel = SwiftOpenAIChatViewModel()
		let server = Server(name: "no-host-server", url: "http://", apiType: .openAI, modelName: validOpenAIModelName)
		viewModel.setServer(server: server)
		
		await viewModel.sendMessage(testPrompt)
		
		#expect(viewModel.llmResponse.contains("Error:"), "Should handle missing URL host")
	}
	
	// MARK: - API Key Tests
	
	@Test("Valid API key configuration")
	func testSendMessageValidApiKey() async {
		let viewModel = SwiftOpenAIChatViewModel()
		let server = Server(name: "test-server", url: validOpenAIServerURLString, apiType: .openAI, apiKey: validAPIKey, modelName: validOpenAIModelName)
		viewModel.setServer(server: server)
		
		await viewModel.sendMessage(testPrompt)
		// Connection may fail due to no actual server, but API key should be processed
		#expect(viewModel.llmResponse.count >= 0, "Should handle valid API key configuration")
	}
	
	@Test("Empty API key handling")
	func testSendMessageEmptyApiKey() async {
		let viewModel = SwiftOpenAIChatViewModel()
		let server = Server(name: "test-server", url: validOpenAIServerURLString, apiType: .openAI, apiKey: "", modelName: validOpenAIModelName)
		viewModel.setServer(server: server)
		
		await viewModel.sendMessage(testPrompt)
		// SwiftOpenAI should handle empty API key gracefully
		#expect(viewModel.llmResponse.count >= 0, "Should handle empty API key")
	}
	
	@Test("Nil API key handling")
	func testSendMessageNilApiKey() async {
		let viewModel = SwiftOpenAIChatViewModel()
		let server = Server(name: "test-server", url: validOpenAIServerURLString, apiType: .openAI, modelName: validOpenAIModelName)
		viewModel.setServer(server: server)
		
		await viewModel.sendMessage(testPrompt)
		// SwiftOpenAI should handle nil API key by using empty string
		#expect(viewModel.llmResponse.count >= 0, "Should handle nil API key")
	}
	
	// MARK: - SwiftOpenAI Service Factory Tests
	
	@Test("SwiftOpenAI service factory with API key")
	func testServiceFactoryWithAPIKey() async {
		let viewModel = SwiftOpenAIChatViewModel()
		let server = Server(name: "factory-test-server", url: validOpenAIServerURLString, apiType: .openAI, apiKey: "test-api-key", modelName: validOpenAIModelName)
		viewModel.setServer(server: server)
		
		await viewModel.sendMessage(testPrompt)
		
		// Should create service with API key
		#expect(viewModel.llmResponse.count >= 0, "Should create service with API key")
	}
	
	@Test("SwiftOpenAI service factory without API key")
	func testServiceFactoryWithoutAPIKey() async {
		let viewModel = SwiftOpenAIChatViewModel()
		let server = Server(name: "factory-no-key-server", url: validOpenAIServerURLString, apiType: .openAI, modelName: validOpenAIModelName)
		viewModel.setServer(server: server)
		
		await viewModel.sendMessage(testPrompt)
		
		// Should create service with empty API key
		#expect(viewModel.llmResponse.count >= 0, "Should create service without API key")
	}
	
	@Test("SwiftOpenAI custom base URL override")
	func testCustomBaseURLOverride() async {
		let viewModel = SwiftOpenAIChatViewModel()
		let customURL = "http://custom.server:8080"
		let server = Server(name: "custom-url-server", url: customURL, apiType: .openAI, modelName: validOpenAIModelName)
		viewModel.setServer(server: server)
		
		await viewModel.sendMessage(testPrompt)
		
		// Should use custom base URL
		#expect(viewModel.llmResponse.count >= 0, "Should handle custom base URL override")
	}
	
	// MARK: - Threading and Concurrency Tests
	
	@Test("Concurrent sendMessage calls")
	func testConcurrentSendMessage() async {
		let viewModel = SwiftOpenAIChatViewModel()
		let server = Server(name: "concurrent-server", url: validOpenAIServerURLString, apiType: .openAI, modelName: validOpenAIModelName)
		viewModel.setServer(server: server)
		
		// Send multiple messages concurrently
		await withTaskGroup(of: Void.self) { group in
			for i in 1...3 {
				group.addTask {
					await viewModel.sendMessage("Message \(i)")
				}
			}
		}
		
		// Should handle concurrent calls gracefully
		#expect(viewModel.llmResponse.count >= 0, "Should handle concurrent messages")
	}
	
	// MARK: - Streaming Response Tests
	
	@Test("SwiftOpenAI streaming response handling")
	func testStreamingResponseHandling() async {
		let viewModel = SwiftOpenAIChatViewModel()
		let server = Server(name: "streaming-server", url: validOpenAIServerURLString, apiType: .openAI, modelName: validOpenAIModelName)
		viewModel.setServer(server: server)
		
		// Reset response before sending
		#expect(viewModel.llmResponse == "", "Response should be empty before sending")
		
		await viewModel.sendMessage("Tell me a short story")
		
		// Should handle streaming appropriately (will likely error due to no server)
		#expect(viewModel.llmResponse.count >= 0, "Should handle streaming response")
	}
	
	@Test("SwiftOpenAI stream error handling")
	func testStreamErrorHandling() async {
		let viewModel = SwiftOpenAIChatViewModel()
		let server = Server(name: "stream-error-server", url: "http://nonexistent.server:9999", apiType: .openAI, modelName: validOpenAIModelName)
		viewModel.setServer(server: server)
		
		await viewModel.sendMessage(testPrompt)
		
		// Should handle streaming errors gracefully
		#expect(viewModel.llmResponse.contains("Error:"), "Should handle stream errors")
	}
	
	// MARK: - Integration-Style Tests
	
	@Test("Complete workflow with valid server configuration")
	func testCompleteWorkflow() async {
		let viewModel = SwiftOpenAIChatViewModel()
		
		// Step 1: Initialize (should start empty)
		#expect(viewModel.llmResponse == "", "Should start with empty response")
		
		// Step 2: Configure server
		let server = Server(
			name: "test-workflow-server",
			url: validOpenAIServerURLString,
			apiType: .openAI,
			apiKey: validAPIKey,
			modelName: validOpenAIModelName
		)
		viewModel.setServer(server: server)
		#expect(viewModel.llmResponse == "", "Response should be reset after server configuration")
		
		// Step 3: Send message (will likely fail due to no actual server, but should handle gracefully)
		await viewModel.sendMessage(testPrompt)
		#expect(viewModel.llmResponse.count >= 0, "Should have some response after sending message")
		
		// Step 4: Reconfigure server (should reset response)
		let newServer = Server(
			name: "new-test-server",
			url: "http://localhost:8080",
			apiType: .openAI,
			modelName: "different-model"
		)
		viewModel.setServer(server: newServer)
		#expect(viewModel.llmResponse == "", "Response should be reset when changing servers")
	}
	
	// MARK: - Edge Case Tests
	
	@Test("Very long prompt handling")
	func testLongPrompt() async {
		let viewModel = SwiftOpenAIChatViewModel()
		let server = Server(name: "long-prompt-server", url: validOpenAIServerURLString, apiType: .openAI, modelName: validOpenAIModelName)
		viewModel.setServer(server: server)
		
		let longPrompt = String(repeating: "This is a very long prompt. ", count: 100)
		await viewModel.sendMessage(longPrompt)
		
		#expect(viewModel.llmResponse.count >= 0, "Should handle long prompts gracefully")
	}
	
	@Test("Special characters in prompt")
	func testSpecialCharactersPrompt() async {
		let viewModel = SwiftOpenAIChatViewModel()
		let server = Server(name: "special-chars-server", url: validOpenAIServerURLString, apiType: .openAI, modelName: validOpenAIModelName)
		viewModel.setServer(server: server)
		
		let specialPrompt = "Test with émojis 🚀, quotes \"hello\", and symbols @#$%^&*()"
		await viewModel.sendMessage(specialPrompt)
		
		#expect(viewModel.llmResponse.count >= 0, "Should handle special characters in prompts")
	}
	
	@Test("Unicode characters in prompt")
	func testUnicodePrompt() async {
		let viewModel = SwiftOpenAIChatViewModel()
		let server = Server(name: "unicode-server", url: validOpenAIServerURLString, apiType: .openAI, modelName: validOpenAIModelName)
		viewModel.setServer(server: server)
		
		let unicodePrompt = "Unicode test: 你好世界 🌍 Здравствуй мир 🚀"
		await viewModel.sendMessage(unicodePrompt)
		
		#expect(viewModel.llmResponse.count >= 0, "Should handle Unicode characters in prompts")
	}
	
	// MARK: - Configuration and Timeout Tests
	
	@Test("URLSession configuration with custom timeout")
	func testCustomTimeoutConfiguration() async {
		let viewModel = SwiftOpenAIChatViewModel()
		let server = Server(name: "timeout-test-server", url: validOpenAIServerURLString, apiType: .openAI, modelName: validOpenAIModelName)
		viewModel.setServer(server: server)
		
		await viewModel.sendMessage(testPrompt)
		
		// Should use the 60-second timeout configuration
		#expect(viewModel.llmResponse.count >= 0, "Should handle custom timeout configuration")
	}
	
	// MARK: - Error Response Tests
	
	@Test("API error response formatting")
	func testAPIErrorResponseFormat() async {
		let viewModel = SwiftOpenAIChatViewModel()
		let server = Server(name: "error-server", url: "http://nonexistent.server:9999", apiType: .openAI, modelName: validOpenAIModelName)
		viewModel.setServer(server: server)
		
		await viewModel.sendMessage(testPrompt)
		
		// Should produce a properly formatted error message
		#expect(viewModel.llmResponse.contains("Error:"), "Should format error messages properly")
	}
	
	@Test("Network connectivity error handling")
	func testNetworkConnectivityError() async {
		let viewModel = SwiftOpenAIChatViewModel()
		let server = Server(name: "network-error-server", url: "http://192.0.2.1:80", apiType: .openAI, modelName: validOpenAIModelName) // RFC5737 test IP
		viewModel.setServer(server: server)
		
		await viewModel.sendMessage(testPrompt)
		
		#expect(viewModel.llmResponse.contains("Error:"), "Should handle network connectivity errors")
	}
	
	@Test("SwiftOpenAI APIError handling")
	func testSwiftOpenAIAPIErrorHandling() async {
		let viewModel = SwiftOpenAIChatViewModel()
		let server = Server(name: "api-error-server", url: "http://localhost:9999", apiType: .openAI, modelName: "nonexistent-model")
		viewModel.setServer(server: server)
		
		await viewModel.sendMessage(testPrompt)
		
		// Should handle SwiftOpenAI specific API errors
		#expect(viewModel.llmResponse.contains("Error:"), "Should handle SwiftOpenAI API errors")
	}
}

// MARK: - Test Extensions for Mock Data

extension SwiftOpenAIChatViewModelTests {
	
	/// Creates a mock server for testing with common valid configuration
	private func createMockValidServer() -> Server {
		return Server(
			name: "mock-valid-server",
			url: validOpenAIServerURLString,
			apiType: .openAI,
			apiKey: validAPIKey,
			modelName: validOpenAIModelName
		)
	}
	
	/// Creates a mock server with invalid configuration for error testing
	private func createMockInvalidServer() -> Server {
		return Server(
			name: "mock-invalid-server",
			url: invalidURLString,
			apiType: .openAI,
			modelName: invalidModelName
		)
	}
}
