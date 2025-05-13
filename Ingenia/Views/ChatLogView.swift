import SwiftUI

struct ChatLogView: View {
    @State private var searchText = ""
    @State private var selectedChat: Chat? = nil
    @State private var chats: [Chat] = Chat.mocks
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredChats) { chat in
                    NavigationLink {
                        IndividualChat(messages: chat.messages)
                    } label: {
                        chatRow(chat: chat)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            deleteChat(chat)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .listStyle(.plain)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .navigationTitle("Chats")

            HStack {
                NavigationLink {
                    ChatView()
                } label: {
                    VStack {
                        Image(systemName: "message.fill")
                        Text("Chat")
                    }
                    .frame(maxWidth: .infinity)
                }
                
                VStack {
                    Image(systemName: "person.fill")
                    Text("Perfil")
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(.blue)
            }
            .padding()
            .background(Color.gray.opacity(0.3))
        }
    }
    
    private var filteredChats: [Chat] {
        if searchText.isEmpty {
            return chats
        } else {
            return chats.filter { chat in
                chat.characters.contains { character in
                    character.name.localizedCaseInsensitiveContains(searchText)
                }
            }
        }
    }
    
    private func chatRow(chat: Chat) -> some View {
        HStack(spacing: 12) {
            let character = chat.characters.first ?? Character.mocks[0]
            
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.gray)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(chat.characters.map { $0.name }.joined(separator: ", "))
                    .font(.headline)
                
                if let lastMessage = chat.messages.last {
                    Text(lastMessage.text)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            
            
            if let lastMessage = chat.messages.last {
                Text(lastMessage.timestamp, style: .time)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func deleteChat(_ chat: Chat) {
        withAnimation {
            chats.removeAll { $0.id == chat.id }
        }
    }
}

#Preview {
    ChatLogView()
}
