import SwiftUI

struct MessageView: View {
    let message: ChatMessage
    let isFromUser: Bool
    @ObservedObject var chatManager: ChatManager
    let channel: ChatChannel

    private var seenByOthersText: String? {
        guard isFromUser else { return nil }

        let otherParticipantIds = channel.participants.filter { $0 != chatManager.userId && $0 != message.senderId }
        let seenByParticipantNames = otherParticipantIds.compactMap { participantId -> String? in
            if message.seenBy[participantId] != nil {
                return chatManager.agents.first(where: { $0.id == participantId })?.name ?? (participantId == chatManager.userId ? nil : "OtherUser")
            }
            return nil
        }
        
        if seenByParticipantNames.isEmpty {
            return nil
        } else if seenByParticipantNames.count == 1 {
            return "Visto por \(seenByParticipantNames.joined())"
        } else {
            return "Visto por \(seenByParticipantNames.joined(separator: ", "))"
        }
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            if isFromUser {
                Spacer()
                VStack(alignment: .trailing) {
                    Text(message.content)
                        .padding(10)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    if let seenText = seenByOthersText {
                        Text(seenText)
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
                .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .trailing)
                // User's avatar
                if let userAgent = chatManager.agents.first(where: { $0.id == chatManager.userId }) {
                    AvatarView(avatarName: userAgent.avatar)
                } else { // userAgent not found
                    AvatarView(avatarName: "Avatar") // User's specified fallback
                }
            } else {
                // Sender's avatar
                if let senderAgent = chatManager.agents.first(where: { $0.id == message.senderId }) {
                    AvatarView(avatarName: senderAgent.avatar)
                } else { // senderAgent not found
                    AvatarView(avatarName: nil) // Placeholder for sender avatar
                }
                VStack(alignment: .leading) {
                    Text(message.senderName)
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(message.content)
                        .padding(10)
                        .background(Color(UIColor.systemGray5))
                        .foregroundColor(Color(UIColor.label))
                        .cornerRadius(10)
                }
                .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .leading)
                Spacer()
            }
        }
    }
}

// Preview for MessageView if needed
// struct MessageView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Mock data required for preview
//        let mockMessageUser = ChatMessage(id: "msg1", channelId: "ch1", senderId: "user-1", senderName: "User", content: "Hello from user!", timestamp: Date(), seenBy: [:], isPrivate: false)
//        let mockMessageAgent = ChatMessage(id: "msg2", channelId: "ch1", senderId: "agent-1", senderName: "Agent", content: "Hello from agent!", timestamp: Date(), seenBy: [:], isPrivate: false)
//        let mockChannel = ChatChannel(id: "ch1", name: "Preview Channel", participants: ["user-1", "agent-1"], isDirectMessage: false, lastMessage: nil, unreadCount: 0, isTyping: false, lastSeenMessageId: [:])
//        let mockChatManager = ChatManager(userId: "user-1", userName: "User", apiKey: "dummy_key")
//        
//        return VStack {
//            MessageView(message: mockMessageUser, isFromUser: true, chatManager: mockChatManager, channel: mockChannel)
//            MessageView(message: mockMessageAgent, isFromUser: false, chatManager: mockChatManager, channel: mockChannel)
//        }
//        .padding()
//    }
// } 
