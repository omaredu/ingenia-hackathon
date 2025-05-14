import SwiftUI

struct ChannelListView: View {
    @ObservedObject var chatManager: ChatManager
    @Binding var selectedChannelId: String?
    @Binding var showingCreateGroupSheet: Bool // To present the sheet from ContentView
    @Binding var newGroupName: String // Pass through for CreateGroupView
    @Binding var selectedAgentsForGroup: Set<String> // Pass through for CreateGroupView
    @State private var showCareerSummarySheet: Bool = false // State to control summary sheet

    var body: some View {
        List(chatManager.channels, selection: $selectedChannelId) { channel in
            NavigationLink(value: channel.id) {
                HStack {
                    if channel.isDirectMessage {
                        // For direct messages, show the agent's avatar
                        let agentId = channel.participants.first(where: { $0 != chatManager.userId }) ?? ""
                        if let agent = chatManager.agents.first(where: { $0.id == agentId }) {
                            AvatarView(avatarName: agent.avatar)
                        } else {
                            Image(systemName: "person.circle")
                                .resizable()
                                .frame(width: 30, height: 30)
                        }
                    } else {
                        // For group chats, show stacked avatars (up to 3)
                        StackedAvatarsView(participants: channel.participants, chatManager: chatManager)
                    }
                    Text(channel.name)
                }
            }
        }
        .navigationTitle("Chats")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if chatManager.orchestatorState.getProgress() >= 100 {
                    Button("Ver Resultados") {
                        showCareerSummarySheet = true
                    }
                } else {
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 4)
                            .frame(width: 20, height: 20)
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(chatManager.orchestatorState.getProgress() / 100))
                            .stroke(Color.primary, lineWidth: 4)
                            .frame(width: 20, height: 20)
                            .rotationEffect(Angle(degrees: -90))
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button("Nuevo Chat Grupal") {
                        selectedAgentsForGroup.removeAll()
                        newGroupName = ""
                        showingCreateGroupSheet = true
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showCareerSummarySheet) {
            CareerAffinitySummaryView(careerAffinity: chatManager.orchestatorState.careerAffinity)
        }
    }
}

// A view that displays stacked avatars for group chats
struct StackedAvatarsView: View {
    let participants: [String]
    let chatManager: ChatManager
    
    var body: some View {
        ZStack {
            // Display up to 3 avatars in a stacked format
            ForEach(0..<min(3, participantAgents.count), id: \.self) { index in
                AvatarView(avatarName: participantAgents[index].avatar)
                    .offset(x: CGFloat(index * 10))
            }
            
            // If no avatars available, show default group icon
            if participantAgents.isEmpty {
                Image(systemName: "person.3")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
            }
        }
        .frame(width: participantAgents.count > 1 ? 50 : 30, alignment: .leading)
    }
    
    // Get agents from participant IDs, excluding the current user
    private var participantAgents: [Agent] {
        let participantsWithoutUser = participants.filter { $0 != chatManager.userId }
        return participantsWithoutUser.compactMap { participantId in
            chatManager.agents.first(where: { $0.id == participantId })
        }
    }
}

// Preview for ChannelListView if needed
// struct ChannelListView_Previews: PreviewProvider {
// static var previews: some View {
// // You'll need to provide mock data for chatManager and bindings
// // For example:
// struct MockChatManagerWrapper: View {
// @StateObject var chatManager = ChatManager(userId: "previewUser", userName: "Preview User", apiKey: "dummy_key_channel_list")
// @State var selectedChannelId: String? = nil
// @State var showingCreateGroupSheet: Bool = false
// @State var newGroupName: String = ""
// @State var selectedAgentsForGroup: Set<String> = []
//            
// init() {
// // Populate with some sample channels for preview
// chatManager.channels = [
// ChatChannel(id: "1", name: "General", participants: [], isDirectMessage: false, lastMessage: nil, unreadCount: 0, isTyping: false, lastSeenMessageId: [:]),
// ChatChannel(id: "2", name: "Random", participants: [], isDirectMessage: false, lastMessage: nil, unreadCount: 1, isTyping: false, lastSeenMessageId: [:])
// ]
// // To test the summary sheet presentation, you can set progress to 100
// // chatManager.orchestatorState.objectives.forEach { objective in
// // if let index = chatManager.orchestatorState.objectives.firstIndex(where: { $0.id == objective.id }) {
// // chatManager.orchestatorState.objectives[index].status = .completed
// // }
// // }
// }
//            
// var body: some View {
// NavigationView {
// ChannelListView(
// chatManager: chatManager,
// selectedChannelId: $selectedChannelId,
// showingCreateGroupSheet: $showingCreateGroupSheet,
// newGroupName: $newGroupName,
// selectedAgentsForGroup: $selectedAgentsForGroup
// )
// }
// }
// }
// return MockChatManagerWrapper()
// }
// } 
