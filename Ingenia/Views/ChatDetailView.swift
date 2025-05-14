import SwiftUI

struct ChatDetailView: View {
    let channel: ChatChannel
    @ObservedObject var chatManager: ChatManager
    @Binding var messageText: String
    @State private var scrollProxy: ScrollViewProxy? = nil
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(chatManager.getVisibleMessages(for: channel.id)) { message in
                            MessageView(message: message, 
                                        isFromUser: message.senderId == chatManager.userId,
                                        chatManager: chatManager,
                                        channel: channel)
                                .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: chatManager.getVisibleMessages(for: channel.id)) { newMessages in
                    if let lastMessage = newMessages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
                .onAppear {
                    scrollProxy = proxy
                    Task {
                        await chatManager.markAllMessagesInChannelAsSeenByCurrentUser(channelId: channel.id)
                    }
                    if let lastMessage = chatManager.getVisibleMessages(for: channel.id).last {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
            
            HStack {
                TextField("Mensaje", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(chatManager.isProcessingMessage)
                
                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .resizable()
                        .frame(width: 32, height: 32)
                }
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || chatManager.isProcessingMessage)
            }
            .padding()
        }
        .navigationTitle(channel.name)
        .onChange(of: channel.id) { newChannelId in
            Task {
                await chatManager.markAllMessagesInChannelAsSeenByCurrentUser(channelId: newChannelId)
            }
            DispatchQueue.main.async {
                if let scrollProxy = scrollProxy, let lastMessage = chatManager.getVisibleMessages(for: newChannelId).last {
                    scrollProxy.scrollTo(lastMessage.id, anchor: .bottom)
                }
            }
        }
    }
    
    private func sendMessage() {
        let trimmedMessage = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty else { return }
        
        Task {
            let messageCopy = trimmedMessage
            messageText = ""
            await chatManager.sendUserMessage(content: messageCopy, to: channel.id)
        }
    }
}

// Preview for ChatDetailView if needed
// struct ChatDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        // Mock data required for preview
//        // Assuming ChatChannel and ChatManager can be initialized for preview
//        let mockChannel = ChatChannel(id: "previewChannel", name: "Preview Channel", participants: ["user-1", "agent-1"], isDirectMessage: false, lastMessage: nil, unreadCount: 0, isTyping: false, lastSeenMessageId: [:])
//        let mockChatManager = ChatManager(userId: "user-1", userName: "User", apiKey: "dummy_key")
//        @State var mockMessageText = ""
//        
//        return ChatDetailView(channel: mockChannel, chatManager: mockChatManager, messageText: $mockMessageText)
//    }
// } 