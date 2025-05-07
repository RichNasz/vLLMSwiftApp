//
//  vLLMSwiftAppApp.swift
//  vLLMSwiftApp
//
//  Created by Richard Naszcyniec on 4/15/25.
//

import SwiftUI
import SwiftData
import TipKit

/// Entry point for the applicaiton
///
/// This is the entry point for the application. Setup for both Swift Data and TipKit are performed.
/// ``MainAppView`` is the view that is shown, and controls navigation for the application.
///
@main
struct vLLMSwiftApp: App {
   /// stores the container for the application data
	var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Server.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
	
	/// SwiftUI view definition
    var body: some Scene {
        WindowGroup {
			  MainAppView()	//  one main NavigationStackView for the app
        }
		  .modelContainer(sharedModelContainer)
    }
	
	/// Executes required code when the view initializes
	///
	/// Currently there is limited initialization required when the applications starts.
	/// - TipKit initialization to provide user guidance
	///
	init() {
		configureTips()
		try? Tips.resetDatastore() // allows usage of app as if launched for first time
	}
	
	/// Configure the application's available Tips.
	///
	/// - seealso: ``ApplicationTipConfiguration``
	func configureTips() {
		try? Tips.configure([.datastoreLocation(ApplicationTipConfiguration.storeLocation),
									.displayFrequency(ApplicationTipConfiguration.displayFrequency)])
	}
}
