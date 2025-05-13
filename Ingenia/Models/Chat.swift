//
//  Chat.swift
//  Ingenia
//
//  Created by Omar Sánchez on 12/05/25.
//

import Foundation

struct Chat: Identifiable {
    let id: UUID
    let characters: [Character]
    let messages: [Message]
    
    init(characters: [Character], messages: [Message]) {
        self.id = UUID()
        self.characters = characters
        self.messages = messages
    }
}

extension Chat {
    static let mocks: [Chat] = [
        Chat(characters: Character.mocks, messages: Message.mocks),
        Chat(characters: [Character.mocks[0], Character.mocks[1]], messages: [Message.mocks[0], Message.mocks[1]]),
        Chat(characters: [Character.mocks[2]], messages: [Message.mocks[2]])
    ]
}
