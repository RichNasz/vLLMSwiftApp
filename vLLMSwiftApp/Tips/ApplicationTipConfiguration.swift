//
//  ApplicationTipConfiguration.swift
//  vLLMSwiftApp
//
//  Created by Richard Naszcyniec on 4/28/25.
//

import Foundation
import TipKit

/// Struct that defines the values that will be used to configure the TipKit frameowrk
public struct ApplicationTipConfiguration {
	
	/// Defines the location for TipKit data to be the URL for the Application Support directory in the user’s domain. This is a standard location on macOS or iOS for storing app-specific data that isn’t user-facing (e.g., ~/Library/Application Support/ on macOS)
	public static var storeLocation: Tips.ConfigurationOption.DatastoreLocation {
		var url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
		url = url.appending(path: "tipstore")
		return .url(url)
	}
	
	/// The displayFrequency property configures TipKit to control the timing of when tips are displayed to the user. By setting it to .immediate, the  app ensures that any tip that becomes eligible (based on its defined rules) is shown to the user right away, without artificial delays or frequency caps.
	public static var displayFrequency: Tips.ConfigurationOption.DisplayFrequency {
		.immediate // Show all tips as soon as eligible.
	}
	
}
