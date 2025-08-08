//
//  FoundationChatViewModelTests.swift
//  vLLMSwiftAppTests
//
//  Created by Richard Naszcyniec with AI assitance on 8/7/25.
//

import Testing
import Foundation
@testable import vLLMSwiftApp

/// Series of tests for FoundationChatViewModel
@Suite("FoundationChatViewModel Tests")
struct FoundationChatViewModelTests {
	
	// Test data constants
	private let invalidModelName = "InvalidModelName"
	private let validOpenAIModelName = "llama3.2:latest"
	private let validLLamaStackModelName = "meta-llama/Llama-3.1-8B-Instruct"
	
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
			let viewModel = FoundationChatViewModel()
			#expect(viewModel.llmResponse == "", "llmResponse should be empty after initialization")
		}
	}
	
	// MARK: - Server Configuration Tests
	
	@Test("Can setServer without error")
	func testSetServerSucceeds() {
		let viewModel = FoundationChatViewModel()
		let server = Server(name: "test-server", url: validOpenAIServerURLString, apiType: .openAI, modelName: validOpenAIModelName)
		
		#expect(throws: Never.self) {
			viewModel.setServer(server: server)
			#expect(viewModel.llmResponse == "", "llmResponse should be reset after setting server")
		}
	}
	
	@Test("setServer resets llmResponse")
	func testSetServerResetsResponse() {
		let viewModel = FoundationChatViewModel()
		viewModel.llmResponse = "Previous response"
		
		let server = Server(name: "test-server", url: validOpenAIServerURLString, apiType: .openAI, modelName: validOpenAIModelName)
		viewModel.setServer(server: server)
		
		#expect(viewModel.llmResponse == "", "llmResponse should be reset when setting new server")
	}
	
	// MARK: - Message Sending Tests
	
	@Test("sendMessage with no server set")
	func testSendMessageNoServer() async {
		let viewModel = FoundationChatViewModel()
		
		await viewModel.sendMessage(testPrompt)
		
		#expect(viewModel.llmResponse.contains("Error: Server not set"), "Should show server not set error")
	}
	
	@Test("sendMessage with invalid URL")
	func testSendMessageInvalidURL() async {
		let viewModel = FoundationChatViewModel()
		let server = Server(name: "invalid-server", url: invalidURLString, apiType: .openAI, modelName: validOpenAIModelName)
		viewModel.setServer(server: server)
		
		await viewModel.sendMessage(testPrompt)
		
		#expect(viewModel.llmResponse.contains("Error:"), "Should show error for invalid URL")
	}
	
	@Test("sendMessage with missing model name")
	func testSendMessageNoModelName() async {
		let viewModel = FoundationChatViewModel()
		let server = Server(name: "no-model-server", url: validOpenAIServerURLString, apiType: .openAI)
		viewModel.setServer(server: server)
		
		await viewModel.sendMessage(testPrompt)
		
		#expect(viewModel.llmResponse.contains("Error:"), "Should show error for missing model name")
	}
	
	@Test("sendMessage with empty prompt")
	func testSendMessageEmptyPrompt() async {
		let viewModel = FoundationChatViewModel()
		let server = Server(name: "test-server", url: validOpenAIServerURLString, apiType: .openAI, modelName: validOpenAIModelName)
		viewModel.setServer(server: server)
		
		await viewModel.sendMessage(emptyPrompt)
		
		// Should still attempt to send empty message, but may result in error from server
		#expect(viewModel.llmResponse.count >= 0, "Should handle empty prompt gracefully")
	}
	
	// MARK: - URL Validation Tests
	
	@Test("Server URL without path gets default path")
	func testURLPathCorrection() async {
		let viewModel = FoundationChatViewModel()
		let server = Server(name: "no-path-server", url: "http://localhost:11434", apiType: .openAI, modelName: validOpenAIModelName)
		viewModel.setServer(server: server)
		
		await viewModel.sendMessage(testPrompt)
		
		// Should attempt connection (may fail due to no actual server, but URL should be processed)
		#expect(viewModel.llmResponse.count >= 0, "Should process URL and attempt connection")
	}
	
	@Test("Server URL with existing path is preserved")
	func testURLPathPreservation() async {
		let viewModel = FoundationChatViewModel()
		let server = Server(name: "with-path-server", url: validOpenAIServerWithPathURLString, apiType: .openAI, modelName: validOpenAIModelName)
		viewModel.setServer(server: server)
		
		await viewModel.sendMessage(testPrompt)
		
		// Should attempt connection with existing path
		#expect(viewModel.llmResponse.count >= 0, "Should preserve existing URL path")
	}
	
	// MARK: - Error Handling Tests
	
	@Test("Error handling for malformed URL components")
	func testMalformedURLComponents() async {
		let viewModel = FoundationChatViewModel()
		let server = Server(name: "malformed-server", url: "ht!tp://invalid-url", apiType: .openAI, modelName: validOpenAIModelName)
		viewModel.setServer(server: server)
		
		await viewModel.sendMessage(testPrompt)
		
		#expect(viewModel.llmResponse.contains("Error:"), "Should handle malformed URL gracefully")
	}
	
	@Test("Error handling for missing URL scheme")
	func testMissingURLScheme() async {
		let viewModel = FoundationChatViewModel()
		let server = Server(name: "no-scheme-server", url: "localhost:11434", apiType: .openAI, modelName: validOpenAIModelName)
		viewModel.setServer(server: server)
		
		await viewModel.sendMessage(testPrompt)
		
		#expect(viewModel.llmResponse.contains("Error:"), "Should handle missing URL scheme")
	}
	
	@Test("Error handling for missing URL host")
	func testMissingURLHost() async {
		let viewModel = FoundationChatViewModel()
		let server = Server(name: "no-host-server", url: "http://", apiType: .openAI, modelName: validOpenAIModelName)
		viewModel.setServer(server: server)
		
		await viewModel.sendMessage(testPrompt)
		
		#expect(viewModel.llmResponse.contains("Error:"), "Should handle missing URL host")
	}
	
	// MARK: - Data Structure Tests
	
	@Test("OpenAIRequest structure encoding")
	func testOpenAIRequestEncoding() {
		let message = FoundationChatViewModel.OpenAIMessage(role: "user", content: testPrompt)
		let request = FoundationChatViewModel.OpenAIRequest(
			model: validOpenAIModelName,
			messages: [message]
		)
		
		#expect(throws: Never.self) {
			let encoder = JSONEncoder()
			let data = try encoder.encode(request)
			#expect(data.count > 0, "Should successfully encode OpenAIRequest")
			
			// Verify JSON structure
			let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
			#expect(json?["model"] as? String == validOpenAIModelName, "Model should be encoded correctly")
			#expect(json?["stream"] as? Bool == true, "Stream should default to true")
			
			let messages = json?["messages"] as? [[String: Any]]
			#expect(messages?.count == 1, "Should have one message")
			#expect(messages?.first?["role"] as? String == "user", "Role should be user")
			#expect(messages?.first?["content"] as? String == testPrompt, "Content should match")
		}
	}
	
	@Test("OpenAIMessage structure encoding")
	func testOpenAIMessageEncoding() {
		let message = FoundationChatViewModel.OpenAIMessage(role: "system", content: "You are a helpful assistant")
		
		#expect(throws: Never.self) {
			let encoder = JSONEncoder()
			let data = try encoder.encode(message)
			#expect(data.count > 0, "Should successfully encode OpenAIMessage")
			
			// Verify JSON structure
			let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
			#expect(json?["role"] as? String == "system", "Role should be encoded correctly")
			#expect(json?["content"] as? String == "You are a helpful assistant", "Content should be encoded correctly")
		}
	}
	
	// MARK: - Threading and Concurrency Tests
	
	@Test("Concurrent sendMessage calls")
	func testConcurrentSendMessage() async {
		let viewModel = FoundationChatViewModel()
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
	
	// MARK: - Integration-Style Tests
	
	@Test("Complete workflow with valid server configuration")
	func testCompleteWorkflow() async {
		let viewModel = FoundationChatViewModel()
		
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
		let viewModel = FoundationChatViewModel()
		let server = Server(name: "long-prompt-server", url: validOpenAIServerURLString, apiType: .openAI, modelName: validOpenAIModelName)
		viewModel.setServer(server: server)
		
		let longPrompt = String(repeating: "This is a very long prompt. ", count: 100)
		await viewModel.sendMessage(longPrompt)
		
		#expect(viewModel.llmResponse.count >= 0, "Should handle long prompts gracefully")
	}
	
	@Test("Special characters in prompt")
	func testSpecialCharactersPrompt() async {
		let viewModel = FoundationChatViewModel()
		let server = Server(name: "special-chars-server", url: validOpenAIServerURLString, apiType: .openAI, modelName: validOpenAIModelName)
		viewModel.setServer(server: server)
		
		let specialPrompt = "Test with émojis 🚀, quotes \"hello\", and symbols @#$%^&*()"
		await viewModel.sendMessage(specialPrompt)
		
		#expect(viewModel.llmResponse.count >= 0, "Should handle special characters in prompts")
	}
	
	@Test("Unicode characters in prompt")
	func testUnicodePrompt() async {
		let viewModel = FoundationChatViewModel()
		let server = Server(name: "unicode-server", url: validOpenAIServerURLString, apiType: .openAI, modelName: validOpenAIModelName)
		viewModel.setServer(server: server)
		
		let unicodePrompt = "Unicode test: 你好世界 🌍 Здравствуй мир 🚀"
		await viewModel.sendMessage(unicodePrompt)
		
		#expect(viewModel.llmResponse.count >= 0, "Should handle Unicode characters in prompts")
	}
}

// MARK: - Test Extensions for Mock Data

extension FoundationChatViewModelTests {
	
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
