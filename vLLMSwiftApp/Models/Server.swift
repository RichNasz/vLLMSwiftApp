//
//  Server.swift
//  vLLMSwiftApp
//
//  Created by Richard Naszcyniec on 4/15/25.
//

import Foundation
import SwiftData


// valid API enpoint types. Must include Codeable protocol for Swift Data
enum APIEndpointType: Codable {
	case openAI
	case llamaStack
}

@Model
final class Server {
	@Attribute(.unique) var name: String
	var url: String
	var apiKey: String?
	var apiType: APIEndpointType
	var modelName: String?
	
	init( name: String, url: String, apiType: APIEndpointType, apiKey: String? = nil, modelName: String? = nil) {
		self.name = name
		self.url = url
		self.apiType = apiType
		self.apiKey = apiKey
		self.modelName = modelName
	}
}
