//
//  ServerListView.swift
//  vLLMSwiftApp
//
//  Created by Richard Naszcyniec on 4/15/25.
//

import SwiftUI
import SwiftData

/// View for maintaining the list of know servers the application can connect to
///  
///  The user can create, update, and delete server definitions that are persisted using Swift Data.
struct ServerListView: View {
	// get the Swift Data context and get the current sorted data for use in this view
	@Environment(\.modelContext) private var modelContext
	/// list of known servers that are stored in Swift Data
	@Query(sort: \Server.name, order: .forward)
	var serverList: [Server]
	
	private var createServerTip = CreateServerTip()
	@State private var selectedServer: Server?	// what item is selected in the list
	
	
	// Delete server donfirmation dialog state variables
	@State private var showDeleteConfirmation: Bool = false
	@State private var serverToDelete: Server? // For toolbar deletion
	@State private var indicesToDelete: IndexSet? // For swipe-to-delete
	
	// variables needed in inspector
	@State private var isShowingInspector: Bool = false 	// needed to toggle the inspector sheet on and off
	
	/// view used to present the list of servers
	var body: some View {
		NavigationStack {
			List( serverList, selection: $selectedServer ) { server in
				HStack {
					Image(systemName: "server.rack")
						.foregroundColor(.gray)
					VStack(alignment: .leading) {
						Text(server.name)
							.font(.headline)
						HStack{
							if let apiKey = server.apiKey, !apiKey.isEmpty {
								Image(systemName: "lock")
									.foregroundColor(.gray)
									.font(.subheadline)
							} else {
								Image(systemName: "lock.open")
									.foregroundColor(.gray)
									.font(.subheadline)
							}
							Text(server.modelName ?? "")
								.font(.subheadline)
								.foregroundColor(.secondary)
								.lineLimit(1)
							Text(" @ \(server.url)")
								.font(.subheadline)
								.foregroundColor(.secondary)
								.lineLimit(1)
						}
					}
					Spacer()	// force left alignment
				}
				.padding(.vertical, 4)
				.background(
					selectedServer == server
					? Color.accentColor.opacity(0.3) // Highlight for selected item
					: Color.clear
				)
				.clipShape(RoundedRectangle(cornerRadius: 10))
				.onTapGesture {
					// Populate inspector fields and show it when a server is tapped
					selectedServer = server
					// Show the inspector so edits can be done
					isShowingInspector = true
				}
			}	// end of list
			.navigationTitle("Servers")
			.toolbar {
				ToolbarItem(placement: .primaryAction) {
					Button(action: {
						// Clear fields to default values for a new server
						selectedServer = nil
						isShowingInspector = true	// show the inspector so user can edit values
					}) {
						Label("Add Server", systemImage: "plus")
							.symbolEffect(.breathe.plain.byLayer, options: .repeat(.continuous), isActive: serverList.isEmpty)
					}
					.popoverTip(createServerTip)
					
				}
				if !serverList.isEmpty {
					ToolbarItem(placement: .cancellationAction) {
						Button(action: {
							// Store server and show confirmation for toolbar deletion
							serverToDelete = selectedServer
							showDeleteConfirmation = true	// trigger the conformationDialog modifier to run
						}) {
							Label("Delete Server", systemImage: "minus")
						}
						.disabled(selectedServer == nil)
					}
				}
			}
			.onAppear() {
				CreateServerTip.aServerIsDefined = !serverList.isEmpty
			}
			// MARK: code for deletion of a server
			.confirmationDialog(
				serverToDelete != nil ? "Delete \(serverToDelete?.name ?? "server")?" : "Delete server?",
				isPresented: $showDeleteConfirmation,
				titleVisibility: .visible
			) {
				Button("Delete", role: .destructive) {
					if let server = serverToDelete {
						// Handle toolbar deletion
						modelContext.delete(server)
						if selectedServer == server {
							selectedServer = nil
							isShowingInspector = false
						}
					}
					do {
						try modelContext.save()
					} catch {
						print("Failed to save: \(error)")
					}
					
					// Reset dialog state
					serverToDelete = nil
				}
				Button("Cancel", role: .cancel) {
					// Reset dialog state
					serverToDelete = nil
					indicesToDelete = nil
				}
			}
			// using an inspector with inline code instead of a seperate view for simplicity
			.inspector(isPresented: $isShowingInspector) {
				ServerEditView(server: selectedServer,
									onSave: { server in
					if selectedServer == nil {
						modelContext.insert(server)
					} else {
						// copy values from the inspector to the selected server
						selectedServer?.name = server.name
						selectedServer?.url = server.url
						selectedServer?.apiKey = server.apiKey
						selectedServer?.apiType = server.apiType
						selectedServer?.modelName = server.modelName
						
						withAnimation {
							try? modelContext.save()
						}
					}
					isShowingInspector = false
					print ("Saved")
				},
									onCancel: {
					// don't need to do anything to manage Swift Data here
					isShowingInspector = false
					selectedServer = nil
					print ("Canceled")
				})
			}
		}
	}
}


#Preview {
	ServerListView()
		.modelContainer(for: Server.self, inMemory: true)
}

