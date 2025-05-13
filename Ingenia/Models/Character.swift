//
//  Character.swift
//  Ingenia
//
//  Created by Omar Sánchez on 12/05/25.
//

import Foundation

struct Character: Identifiable {
    let id: UUID
    let name: String
    let age: Int
    let profession: String
    let description: String
    let traits: [String]
    let avatar: String
    
    init(name: String, age: Int, profession: String, description: String, traits: [String], avatar: String) {
        self.id = UUID()
        self.name = name
        self.age = age
        self.profession = profession
        self.description = description
        self.traits = traits
        self.avatar = avatar
    }
}

extension Character {
    static let mocks : [Character] = [
        Character(name: "Alice", age: 30, profession: "Engineer", description: "A brilliant engineer with a knack for problem-solving.", traits: ["Intelligent", "Creative"], avatar: "alice_avatar"),
        Character(name: "Bob", age: 25, profession: "Designer", description: "A talented designer with an eye for aesthetics.", traits: ["Artistic", "Detail-oriented"], avatar: "bob_avatar"),
        Character(name: "Charlie", age: 35, profession: "Manager", description: "An experienced manager with strong leadership skills.", traits: ["Organized", "Decisive"], avatar: "charlie_avatar")
    ]
}
