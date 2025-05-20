//
//  Server.swift
//  vLLMSwiftApp
//
//  Created by Richard Naszcyniec on 4/15/25.
//

import Foundation
import SwiftData



/// The class models a server entity.
///
/// Values are used for configuring and managing connections to API endpoints in the application.
/// It is designed to be identifiable and selectable in UI components like dropdown lists.
/// Use of @Model makes it clear that the class is used with Swift Data.
@Model
final class Server {
	/// A user-assigned name for the server, intended to be recognizable and descriptive.
	/// Swift Data will ensure that values will be unique
	@Attribute(.unique) var name: String
	/// The URL of the server, specifying the base address for API requests
	var url: String
	/// optional API key for authenticating requests to the server.
	var apiKey: String?
	/// Enumeration that must be one of the value API types defeined in ``APIEndpointType``
	var apiType: APIEndpointType
	/// Optional name of the model to send inference requests to
	var modelName: String?
	
	/// represents an the complete list of value API endpoint types the application can connect to
	enum APIEndpointType: Codable {
		case openAI
		case llamaStack
	}
	
	/// only initializer provided for class instantiation
	/// - Parameters:
	///   - name: server name to set
	///   - url: base URL of the server to set
	///   - apiType: valid API type to ser
	///   - apiKey: optional API key to set
	///   - modelName: optional model name to set
	init( name: String, url: String, apiType: APIEndpointType, apiKey: String? = nil, modelName: String? = nil) {
		self.name = name
		self.url = url
		self.apiType = apiType
		self.apiKey = apiKey
		self.modelName = modelName
	}
}
