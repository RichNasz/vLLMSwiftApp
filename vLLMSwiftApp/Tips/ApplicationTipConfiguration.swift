//
//  ApplicationTipConfiguration.swift
//  vLLMSwiftApp
//
//  Created by Richard Naszcyniec on 4/28/25.
//

import Foundation
import TipKit

public struct ApplicationTipConfiguration {
	
	public static var storeLocation: Tips.ConfigurationOption.DatastoreLocation {
		var url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
		url = url.appending(path: "tipstore")
		return .url(url)
	}
	
	public static var displayFrequency: Tips.ConfigurationOption.DisplayFrequency {
		.immediate // Show all tips as soon as eligible.
	}
	
}
