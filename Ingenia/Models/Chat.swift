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
