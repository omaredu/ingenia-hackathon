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
