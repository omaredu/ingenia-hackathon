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
}
