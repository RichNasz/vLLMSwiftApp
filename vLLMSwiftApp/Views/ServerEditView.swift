//
//  ServerEditView.swift
//  vLLMSwiftApp
//
//  Created by Richard Naszcyniec on 4/28/25.
//

import SwiftUI
import SwiftData

struct ServerEditView: View {
//	@Environment(\.modelContext) private var modelContext
	private let server: Server?
	private let onSave: (Server) -> Void
	private let onCancel: () -> Void
	
	@State private var draftName: String
	@State private var draftURL: String
	@State private var draftApiKey: String
	@State private var draftApiType: APIEndpointType
	@State private var draftModelName: String
	
	init(server: Server?, onSave: @escaping (Server) -> Void, onCancel: @escaping () -> Void) {
		self.server = server
		self.onSave = onSave			// defer save activity to closure
		self.onCancel = onCancel	// defer cancel activity to closure
		
		// copy the server conent into state variables for editing
		self.draftName = server?.name ?? ""
		self.draftURL = server?.url ?? ""
		self.draftApiKey = server?.apiKey ?? ""
		self.draftApiType = server?.apiType ?? .llamaStack
		self.draftModelName = server?.modelName ?? ""
	}
	
    var body: some View {
		 VStack {
			 Text(server == nil ? "New Server" : "Edit Server")
				 .font(.headline)
				 .padding(.bottom, 5)
			 Form {
				 Section {
					 TextField("Server Name", text: $draftName)
						 .textFieldStyle(.roundedBorder)
					 TextField("Server URL", text: $draftURL)
						 .textFieldStyle(.roundedBorder)
					 SecureField("Server API Key", text: $draftApiKey)
						 .textFieldStyle(.roundedBorder)
				 } header: {
					 Text("Server Configuration")
						 .font(.subheadline)
						 .foregroundColor(.primary)
				 } footer: {
					 Text("Sprecify the parameter values to connect to the vLLM server.")
						 .font(.caption)
						 .foregroundColor(.secondary)
						 .padding(.bottom)
				 }
				 Section {
					 TextField("Model Name", text: $draftModelName)
						 .textFieldStyle(.roundedBorder)
					 Picker("API Type", selection: $draftApiType) {
						 Text("Llama-stack").tag(APIEndpointType.llamaStack)
						 Text("OpenAI-compatible").tag(APIEndpointType.openAI)
					 }
#if os(macOS)
					 .pickerStyle(.radioGroup)
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
			 HStack {
				 Spacer()
				 Button("Cancel") {
					 onCancel()
				 }
				 .buttonStyle(.automatic)
				 
				 Button("Save") {
					 let targetServer = Server(
						name: draftName,			// required
						url: draftURL,				// required
						apiType: draftApiType,	// default value set
						apiKey: draftApiKey.isEmpty ? nil : draftApiKey,
						modelName: draftModelName.isEmpty ? nil : draftModelName
					 )
					 // call the closure with the temp server so caller can take action
					 onSave(targetServer)
				 }
				 .buttonStyle(.borderedProminent)
				 .disabled(draftName.isEmpty || draftURL.isEmpty) // required fields
				 
				 Spacer()
			 }
			 .padding()
			 
			 Spacer()
		 }
		 .onChange(of: server) {
			 // make sure we update the state fields when the server value changes
			 // this is critical since this view is used as an inspector, which means
			 // that init will only be call once from a parent view
			 self.draftName = server?.name ?? ""
			 self.draftURL = server?.url ?? ""
			 self.draftApiKey = server?.apiKey ?? ""
			 self.draftApiType = server?.apiType ?? .llamaStack
			 self.draftModelName = server?.modelName ?? ""
		 }
    }
}

//
// The following code is for preview purposes only
//
///
// Below is just for Previewing in Xcode
private struct PreviewWrapper: View {
	
	init()
	{
		// code for trying a new server
	}
	
	var body: some View {
		ServerEditView(server: nil,
							onSave: { server in print ("Saved")},
							onCancel: {  print ("Canceled")}
		)
			.modelContainer(for: Server.self, inMemory: true)
	}
}

#Preview {
	PreviewWrapper()
}
