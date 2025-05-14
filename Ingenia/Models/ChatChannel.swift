import Foundation

struct ChatChannel: Identifiable, Codable {
    let id: String
    let name: String
    let participants: [String]
    var messages: [ChatMessage]
    let isDirectMessage: Bool
    
    init(id: String = UUID().uuidString, name: String, participants: [String], messages: [ChatMessage] = [], isDirectMessage: Bool = false) {
        self.id = id
        self.name = name
        self.participants = participants
        self.messages = messages
        self.isDirectMessage = isDirectMessage
    }
    
    func messagesVisibleTo(userId: String) -> [ChatMessage] {
        return messages.filter { message in
            !message.isPrivate || message.senderId == userId || (message.isPrivate && participants.count == 2)
        }
    }
} 
