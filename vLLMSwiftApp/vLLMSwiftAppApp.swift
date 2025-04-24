//
//  vLLMSwiftAppApp.swift
//  vLLMSwiftApp
//
//  Created by Richard Naszcyniec on 4/15/25.
//

import SwiftUI
import SwiftData

@main
struct vLLMSwiftAppApp: App {
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

    var body: some Scene {
        WindowGroup {
			  MainAppView()	//  one main NavigationStackView for the app
        }
		  .modelContainer(sharedModelContainer)
    }
}
