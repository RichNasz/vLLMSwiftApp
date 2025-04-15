//
//  MainAppView.swift
//  vLLMSwiftApp
//
//  Created by Richard Naszcyniec on 4/15/25.
//

import SwiftUI
import SwiftData

// valid navigation destinations
enum DynamicNavigationDestination: Hashable {
	case vllmServers
	case llamaStackChat
}

// Define a simple struct for navigation items
struct NavItem: Identifiable, Hashable {
	let id = UUID()
	let title: String	// used for the menu label & used to set the dynamic view destination
	let icon: String // SF Symbol name
	
	// used in code to dynamically set the view to use based on menu item selected
	var destination: DynamicNavigationDestination? {
		switch title {		// NOTE: the case statement relies on finding matches to title values
			case "vLLM Servers": return .vllmServers
			case "Llama-Stack Chat": return .llamaStackChat
			default: return nil
		}
	}
}

// Define section struct
struct NavSection: Identifiable, Hashable {
	let id = UUID()
	let title: String		// title is used for the menu label
	let items: [NavItem]	// each section can have multiple navigation items
}

struct MainAppView: View {
	
	// get the Swift Data context and get the current sorted data for use in this view
	@Environment(\.modelContext) private var modelContext
	// TODO: fix the query to just use llama-stack server definitions
	@Query(sort: \Server.name, order: .forward) var serverList: [Server]
	
	@State private var columnVisibility = NavigationSplitViewVisibility.automatic
	@State private var selectedItem: NavItem? // Track selected item
	@State private var lastValidSelection: NavItem? 	// last valid selection which can be nil
	@State private var navPath = NavigationPath()
	
	// Define your navigation items array
	private let navSections = [
		NavSection(title: "Settings", items: [
			NavItem(title: "vLLM Servers", icon: "server.rack"),
			NavItem(title: "Chat Preferences", icon: "ellipsis.message")
		]),
		NavSection(title: "Llama-Stack example", items: [
			NavItem(title: "Llama-Stack Chat", icon: "message")
		]),
		NavSection(title: "OpenAI examples", items: [
			NavItem(title: "URLSession Chat", icon: "message"),
			NavItem(title: "AlamoFire Chat", icon: "message"),
			NavItem(title: "SwiftOpenAPI Chat", icon: "message"),
			NavItem(title: "MacPaw -> OpenAI Chat", icon: "message")
		])
	]
	
	var noServersDefined: Bool {
		serverList.isEmpty
	}
	
    var body: some View {
		 NavigationSplitView(columnVisibility: $columnVisibility) {
			 // create the sidebar here
			 List(selection: $selectedItem) {
				 ForEach(navSections) { section in
					 Section(section.title) {
						 ForEach(section.items) { item in
							 // Only place menu items with a destination view in a NavigationLink
							 // This is cleaner and will allow proper operation of selectionDisabled modifier
							 if( item.destination == nil ) {
								 Label(item.title, systemImage: item.icon)
									 .padding(.vertical, 4)
									 .foregroundColor(item.destination != nil ? .primary : .gray)
									 .accessibilityLabel("\(item.title) navigation item")
									 .selectionDisabled(true)
							 } else {
								 NavigationLink(value: item) {
									 Label(item.title, systemImage: item.icon)
										 .padding(.vertical, 4)
										 .foregroundColor(item.destination != nil ? .primary : .gray)
										 .accessibilityLabel("\(item.title) navigation item")
										 .selectionDisabled(noServersDefined)
								 }
							 }
						 }
					 }
				 }
			 }
			 .navigationSplitViewColumnWidth( min: 205, ideal: 210, max: 225)
		 } detail: {
			 // using a navigation stack here so we can drill down an infinite number of times in the detail
			 // area, and automatically get the ability to pop the stack going back.
			 NavigationStack(path: $navPath) {
				 if let currentItem = selectedItem, let destination = currentItem.destination {
					 switch destination {
						 case .vllmServers:
							 ServerListView()
						 case .llamaStackChat:
							 LlamaStackChatView()
						 default:
							 Text("View not implemented yet")
								 .foregroundColor(.orange)
					 }
				 } else {
					 Text("Select a valid item from the sidebar")
						 .foregroundColor(.red)
				 }
			 }
		 }
	 }
}


#Preview {
	MainAppView()
		.navigationTitle("vLLM Inference Endpoint Examples") // Set sidebar title
}
