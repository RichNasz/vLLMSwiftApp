//
//  MainAppView.swift
//  vLLMSwiftApp
//
//  Created by Richard Naszcyniec on 4/15/25.
//

import SwiftUI
import SwiftData
import TipKit

// valid navigation destinations are added as available so the navigation menu can be dynamic
private enum DynamicNavigationDestination: Hashable {
	case vllmServers
	case llamaStackChat
}

/// structure for an indidividual navigaiton item used in the view
private struct NavItem: Identifiable, Hashable {
	let id = UUID()
	let title: String	// used for the menu label & used to set the dynamic view destination
	let icon: String 	// SF Symbol name
	
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
///  structure for sections within the navigation sidebar
///
///  Each section can contain multiple ``NavItem`` which allows grouping of like items
private struct NavSection: Identifiable, Hashable {
	let id = UUID()
	let title: String		// title is used for the menu label
	let items: [NavItem]	// each section can have multiple navigation items
}

/// Main view for the application
///
/// This view gets created when the applicaiton starts up, and is established the base of the view navigation heiracrchy that all subviews are used within. Creation of the menu in the left hand sidebar is built dynamically with menu items enabled or disabled based on applicaiton state, or availability of a coded subview to implement functionality. Review the <doc:Understanding-basic-application-structure> article for more information on basic application structure.
struct MainAppView: View {
	/// access the Swift data content
	@Environment(\.modelContext) private var modelContext
	/// list of servers to use for determining what menu items should be enabled.
	@Query(sort: \Server.name, order: .forward) var serverList: [Server]	// need list of servers for dynamic functionality
	
	@State private var columnVisibility = NavigationSplitViewVisibility.automatic
	@State private var selectedItem: NavItem? // Track selected item
	
	@State private var lastValidSelection: NavItem? // must allow for nil to avoid default selection
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

	@State private var mustCreateSever: Bool = false
	private var chooseMenuItemTip = ChooseMenuItemTip()
	
	/// the base view for the entire application
    var body: some View {
		 NavigationSplitView(columnVisibility: $columnVisibility) {
			 // Build the sidebar dynamically and only enable items that have views implemented
			 List(selection: $selectedItem) {
				 ForEach(navSections) { section in
					 Section(section.title) {
						 ForEach(section.items) { item in
							 // Only place menu items with a destination view in a NavigationLink
							 // This is cleaner and will allow proper operation of selectionDisabled modifier
							 if( item.destination == nil ) {
								 Label(item.title, systemImage: item.icon)
									 .padding(.vertical, 4)
									 .foregroundColor(.gray)
									 .accessibilityLabel("\(item.title) navigation item")
									 .selectionDisabled(true)
							 } else {
								 NavigationLink(value: item) {
									 Label(item.title, systemImage: item.icon)
										 .padding(.vertical, 4)
										 .foregroundColor(.primary)
										 .accessibilityLabel("\(item.title) navigation item")
										 .selectionDisabled(false)
								 }
							 }
						 }
					 }
				 }
			 }
			 .navigationSplitViewColumnWidth( min: 205, ideal: 210, max: 225)
		 } detail: {
			 VStack {	// create a view so we can put the condition inside of it
				 if !serverList.isEmpty && selectedItem == nil {
					 TipView(chooseMenuItemTip, arrowEdge: .leading)
					 .padding(.vertical, 8)
				 }
			 }
			 // using a navigation stack here so we can drill down an infinite number of times in the detail
			 // area, and automatically get the ability to pop the stack going back.
			 NavigationStack(path: $navPath) {
				 if let currentItem = selectedItem, let destination = currentItem.destination {
					 switch destination {
						 case .vllmServers:
							 ServerListView()
						 case .llamaStackChat:
							 LlamaStackChatView()
					 }
				 }
			 }
			 
		 }
		 .onAppear {
			 if serverList.isEmpty {
				 selectedItem = navSections.flatMap { $0.items }.first { $0.title == "vLLM Servers" }
			 }
		 }
		 .onChange(of: selectedItem) {	// check for any conditions why the selected item shouldn't change
			 if serverList.isEmpty {
				 selectedItem = navSections.flatMap { $0.items }.first { $0.title == "vLLM Servers" }
			 }
		 }
	 }
}

//
// Below is just for Previewing in Xcode
private struct PreviewWrapper: View {
	
	init()
	{
		try? Tips.resetDatastore()
		Tips.showAllTipsForTesting()
	}
	
	var body: some View {
		MainAppView()
			.navigationTitle("vLLM Inference Endpoint Examples") // Set sidebar title
	}
}

#Preview {
//	MainAppView()
//		.navigationTitle("vLLM Inference Endpoint Examples") // Set sidebar title
	PreviewWrapper()
}
