//
//  Untitled.swift
//  Ingenia
//
//  Created by Omar Sánchez on 12/05/25.
//
import Foundation

struct Message: Identifiable {
    let id: UUID
    let sender: Character
    let text: String
    let timestamp: Date
    
    init(sender: Character, text: String, timestamp: Date) {
        self.id = UUID()
        self.sender = sender
        self.text = text
        self.timestamp = timestamp
    }
}

extension Message {
    static let mocks: [Message] = [
        Message(sender: Character.mocks[0], text: "Hello, how are you?", timestamp: Date()),
        Message(sender: Character.mocks[1], text: "I'm good, thanks! How about you?", timestamp: Date()),
        Message(sender: Character.mocks[2], text: "Doing well, just working on a project.", timestamp: Date()),
        Message(sender: Character.mocks[0], text: "That's great to hear! What project?", timestamp: Date()),
        Message(sender: Character.mocks[1], text: "I'm designing a new app.", timestamp: Date()),
    ]
}
