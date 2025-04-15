//
//  ServerListView.swift
//  vLLMSwiftApp
//
//  Created by Richard Naszcyniec on 4/15/25.
//

import SwiftUI
import SwiftData

struct ServerListView: View {
	// get the Swift Data context and get the current sorted data for use in this view
	@Environment(\.modelContext) private var modelContext
	@Query(sort: \Server.name, order: .forward)
	var serverList: [Server]
	
	
	@State private var selectedServer: Server?	// what item is selected in the list
	

	// Delete server donfirmation dialog state variables
	@State private var showDeleteConfirmation: Bool = false
	@State private var serverToDelete: Server? // For toolbar deletion
	@State private var indicesToDelete: IndexSet? // For swipe-to-delete
	
	// variables needed in inspector
	@State private var isShowingInspector: Bool = false 	// needed to toggle the inspector sheet on and off
	@State private var serverName: String = ""
	@State private var serverURL: String = ""
	@State private var serverApiKey: String = ""
	@State private var serverApiType: APIEndpointType = .llamaStack	// no nil values, so default value is set
	@State private var serverModelName: String = ""
	
	// needed to check values have changes to trigger enabling of Save/Add buttons
	@State private var originalName: String = ""
	@State private var originalURL: String = ""
	@State private var originalApiKey: String = ""
	@State private var originalApiType: APIEndpointType = .llamaStack
	@State private var originalModelName: String = ""
	
	// Computed property for save button state
	private var isSaveDisabled: Bool {
		if selectedServer == nil {
			return serverName.isEmpty || serverURL.isEmpty	// adding a new server requires a name and URL
		} else {
			// For editing: enable only if something has changed
			return serverName == originalName &&
			serverURL == originalURL &&
			serverApiKey == originalApiKey &&
			serverApiType == originalApiType &&
			serverModelName ==	originalModelName
		}
	}
	
	// MARK: ServerList view content definition
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
					serverName = server.name
					serverURL = server.url
					serverApiKey = server.apiKey ?? ""
					serverApiType = server.apiType
					serverModelName = server.modelName ?? ""
					// remember values so we can determine if they changd
					// TODO: see if this can done using Swift Data functionality instead of variables
					originalName = server.name
					originalURL = server.url
					originalApiKey = server.apiKey ?? ""
					originalModelName = server.modelName ?? ""
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
						serverName = ""
						serverURL = ""
						serverApiKey = ""
						serverApiType = .llamaStack
						serverModelName = ""
						isShowingInspector = true	// show the inspector so user can edit values
					}) {
						Label("Add Server", systemImage: "plus")
//							.symbolEffect( .pulse , options: .repeat(.periodic(delay: 2)), isActive: serverList.isEmpty )
							.symbolEffect(.breathe.plain.byLayer, options: .repeat(.continuous), isActive: serverList.isEmpty)
					}
					
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
				VStack {
					Text(selectedServer == nil ? "Add Server" : "Edit Server")
						.font(.title2)
						.bold()
						.padding()
						.frame(maxWidth: .infinity, alignment: .leading)
					Form {
						Section {
							TextField("Server Name", text: $serverName)
								.textFieldStyle(.roundedBorder)
							TextField("Server URL", text: $serverURL)
								.textFieldStyle(.roundedBorder)
							SecureField("Server API Key", text: $serverApiKey)
								.textFieldStyle(.roundedBorder)
						} header: {
							Text("Server Configuration")
								.font(.subheadline)
								.foregroundColor(.primary)
						} footer: {
							Text("Sprecify the parameter values to connect to the vLLM server.")
								.font(.caption)
								.foregroundColor(.secondary)
						}
						
						Section {
							TextField("Model Name", text: $serverModelName)
								.textFieldStyle(.roundedBorder)
							Picker("API Type", selection: $serverApiType) {
								Text("Llama-stack").tag(APIEndpointType.llamaStack)
								Text("OpenAI-compatible").tag(APIEndpointType.openAI)
							}
							#if os(macOS)
							.pickerStyle(.radioGroup)
							#else
							.pickerStyle(.automatic)
							#endif
							
						} header: {
							Text("API Configuration")
								.font(.subheadline)
								.foregroundColor(.primary)
						} footer: {
							Text("Select the API calling parameters that match your server's endpoint configuration.")
								.font(.caption)
								.foregroundColor(.secondary)
						}
					}
					.scrollContentBackground(.hidden)
					HStack {
						Spacer()
						Button("Cancel", action: {
							isShowingInspector = false
							selectedServer = nil
						})
						Button(selectedServer == nil ? "Add" : "Save") {
							if let selectedServer {
								// Update existing server
								selectedServer.name = serverName
								selectedServer.url = serverURL
								selectedServer.apiKey = serverApiKey
								selectedServer.apiType = serverApiType
								selectedServer.modelName = serverModelName
							} else {
								// Add new server
								let newServer = Server(name: serverName, url: serverURL, apiType: serverApiType, apiKey: serverApiKey, modelName: serverModelName)
								modelContext.insert(newServer)
							}
							do {
								try modelContext.save()
							} catch {
								print("Failed to save: \(error)")
							}
							isShowingInspector = false
						}
						.disabled(isSaveDisabled)
					}
					.padding()
					Spacer()
				}
			}
		}
	}
}


#Preview {
	ServerListView()
		.modelContainer(for: Server.self, inMemory: true)
}

