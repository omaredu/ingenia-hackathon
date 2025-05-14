import SwiftUI

struct CreateGroupView: View {
    @ObservedObject var chatManager: ChatManager
    @Binding var newGroupName: String
    @Binding var selectedAgentsForGroup: Set<String>
    @Binding var showingCreateGroupSheet: Bool
    @Binding var selectedChannelId: String? // To select the new channel

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Nombre del grupo")) {
                    TextField("Ingresa el nombre del grupo", text: $newGroupName)
                }
                
                Section(header: Text("Seleccionar Personas")) {
                    ForEach(chatManager.agents.filter { !$0.isGlobalAgent }) { agent in
                        Button {
                            if selectedAgentsForGroup.contains(agent.id) {
                                selectedAgentsForGroup.remove(agent.id)
                            } else {
                                selectedAgentsForGroup.insert(agent.id)
                            }
                        } label: {
                            HStack {
                                Text(agent.name)
                                Spacer()
                                if selectedAgentsForGroup.contains(agent.id) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .foregroundColor(.primary) // Ensure button text is visible
                    }
                }
            }
            .navigationTitle("Nuevo Chat Grupal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        showingCreateGroupSheet = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Crear") {
                        if !newGroupName.isEmpty && !selectedAgentsForGroup.isEmpty {
                            chatManager.createGroupChat(
                                name: newGroupName,
                                agentIds: Array(selectedAgentsForGroup)
                            )
                            showingCreateGroupSheet = false
                            
                            // Select the newly created channel
                            if let newChannel = chatManager.channels.last {
                                selectedChannelId = newChannel.id
                            }
                        }
                    }
                    .disabled(newGroupName.isEmpty || selectedAgentsForGroup.isEmpty)
                }
            }
        }
    }
}

// Preview for CreateGroupView if needed
// struct CreateGroupView_Previews: PreviewProvider {
// static var previews: some View {
// struct MockCreateGroupWrapper: View {
// @StateObject var chatManager = ChatManager(userId: "previewUser", userName: "Preview User", apiKey: "dummy_key_create_group")
// @State var newGroupName: String = "Test Group"
// @State var selectedAgentsForGroup: Set<String> = []
// @State var showingCreateGroupSheet: Bool = true
// @State var selectedChannelId: String? = nil
//            
// init() {
// // Populate with some sample agents for preview
// chatManager.agents = [
// Agent(id: "agent1", name: "Agent 1", description: "", systemMessage: "", isGlobalAgent: false),
// Agent(id: "agent2", name: "Agent 2", description: "", systemMessage: "", isGlobalAgent: false)
// ]
// }
//            
// var body: some View {
// CreateGroupView(
// chatManager: chatManager,
// newGroupName: $newGroupName,
// selectedAgentsForGroup: $selectedAgentsForGroup,
// showingCreateGroupSheet: $showingCreateGroupSheet,
// selectedChannelId: $selectedChannelId
// )
// }
// }
// return MockCreateGroupWrapper()
// }
// } 