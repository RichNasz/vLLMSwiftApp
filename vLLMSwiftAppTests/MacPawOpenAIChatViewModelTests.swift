//
//  MacPawOpenAIChatViewModelTests.swift
//  vLLMSwiftAppTests
//
//  Created by Richard Naszcyniec on 5/20/25.
//

import Testing
import OpenAI
@testable import vLLMSwiftApp

/// Series of tests for MacPawOpenAIChatViewModel
@Suite("MacPawOpenAIChatViewModelTests Tests")
struct MacPawOpenAIChatViewModelTests {
	
	private let invalidModelName = "InvalidModelName"
	private let validOpenAIModelName = "llama3.2:latest"
	private let validLLAMAStackModelName = "meta-llama/Llama-3.1-8B-Instruct"
	
	private let invalidURLString = "invalid url"
	private let validLlamaStackServerURLString = "http://127.0.0.1:5001"
	private let validOpenAIServerURLString = "http://localhost:11434"
	
	private let validAPIKey = ""
	private let invalidAPIKey = "invalid api key"
	
	@Test("Valid initialization")
	func testInitialization() {
		#expect(throws: Never.self) {
			let viewModel = MacPawOpenAIChatViewModel()
			#expect(viewModel.llmResponse == "", "llmResponse should be empty after initialization")
		}
	}
	
	@Test("Can setServer without error")
	func testSetServerFails() {
		let viewModel = MacPawOpenAIChatViewModel()
		let server = Server(name: "test-server", url: validOpenAIServerURLString, apiType: .openAI)
		
		#expect(throws: Never.self) {
			viewModel.setServer(server: server)
			#expect(viewModel.llmResponse == "", "llmResponse should be reset")
		}
	}
	
	@Test("sendMessage with no server")
	func testSendMessageNoServer() async {
		let viewModel = MacPawOpenAIChatViewModel()
		
		await viewModel.sendMessage("Hello")
		
		#expect(viewModel.llmResponse == "Error: Server not set. Message could not be sent")
	}
	
	@Test("Invalid URL results in an error")
	func testSendMessageInvalidURLSet() async {
		let viewModel = MacPawOpenAIChatViewModel()
		let server = Server(name: "test-server", url: invalidURLString, apiType: .openAI)
		viewModel.setServer(server: server)
		
		await viewModel.sendMessage("test prompt")
		#expect(viewModel.llmResponse.starts(with: "Error:"))
	}
	
	
	@Test("Invalid model name results in an error")
	func testSendMessageInvalidModelName() async {
		let viewModel = MacPawOpenAIChatViewModel()
		let server = Server(name: "test-server", url: validOpenAIServerURLString, apiType: .openAI, modelName: invalidModelName)
		viewModel.setServer(server: server)
		
		await viewModel.sendMessage("test prompt")
		#expect(viewModel.llmResponse.starts(with: "API Error:"))
	}
	
	@Test("Valid model name succeeds")
	func testSendMessageValidModelName() async {
		let viewModel = MacPawOpenAIChatViewModel()
		let server = Server(name: "test server", url: validOpenAIServerURLString, apiType: .openAI, modelName: validOpenAIModelName)
		viewModel.setServer(server: server)
		
		await viewModel.sendMessage("say hello")
		#expect(viewModel.llmResponse.starts(with: "Error:") == false)
	}
	
	@Test("Valid apiKey succeeds")
	func testSendMessageValidApiKey() async {
		let viewModel = MacPawOpenAIChatViewModel()
		let server = Server(name: "test-server", url: validOpenAIServerURLString, apiType: .openAI, apiKey: validAPIKey, modelName: validOpenAIModelName)
		viewModel.setServer(server: server)
		
		await viewModel.sendMessage("say hello")
		#expect(viewModel.llmResponse.starts(with: "Error:") == false)
	}
	
	@Test("Invalid apiKey results in an error")
	func testSendMessageInvalidApiKey() async {
		let viewModel = MacPawOpenAIChatViewModel()
		let server = Server(name: "test-server", url: validOpenAIServerURLString, apiType: .openAI, apiKey: invalidAPIKey, modelName: validOpenAIModelName)
		viewModel.setServer(server: server)
		
		await viewModel.sendMessage("say hello")
		#expect(viewModel.llmResponse.starts(with: "Error:") == false)
	}
	
}
