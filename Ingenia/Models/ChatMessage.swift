import Foundation

struct ChatMessage: Identifiable, Codable, Equatable {
    let id: UUID
    let senderId: String
    let senderName: String
    let content: String
    let timestamp: Date
    let channelId: String
    let isPrivate: Bool
    var seenBy: [String: Date] // [ParticipantID: Timestamp when seen]
    
    init(senderId: String, senderName: String, content: String, channelId: String, isPrivate: Bool = false, id: UUID = UUID(), timestamp: Date = Date(), seenBy: [String: Date] = [:]) {
        self.id = id
        self.senderId = senderId
        self.senderName = senderName
        self.content = content
        self.timestamp = timestamp
        self.channelId = channelId
        self.isPrivate = isPrivate
        
        // Initialize seenBy, automatically marking it as seen by the sender
        var initialSeenBy = seenBy
        initialSeenBy[senderId] = Date() // Sender has seen their own message
        self.seenBy = initialSeenBy
    }
    
    // Helper to create a new ChatMessage instance with updated seenBy status
    func markedAsSeen(by participantId: String) -> ChatMessage {
        var updatedMessage = self
        if updatedMessage.seenBy[participantId] == nil { // Only update if not already seen to avoid redundant Date changes
            updatedMessage.seenBy[participantId] = Date()
        }
        return updatedMessage
    }
    
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        return lhs.id == rhs.id
    }
}

struct ChatMessageToSend {
    let content: String
    let targetChannelId: String
    let isPrivate: Bool
    let delay: TimeInterval?
    
    init(content: String, targetChannelId: String, isPrivate: Bool = false, delay: TimeInterval? = nil) {
        self.content = content
        self.targetChannelId = targetChannelId
        self.isPrivate = isPrivate
        self.delay = delay
    }
} 
