//
//  MessageView.swift
//  Ingenia
//
//  Created by Alumno on 12/05/25.
//

import SwiftUI

struct MessageBubbleView: View {
    let text: String
    let sender: MessageSender
    let timestamp: Date

    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: timestamp)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(text)
                .padding(10)
                .foregroundColor(sender == .mine ? .white : .black)
                .background(sender == .mine ? Color.blue : Color.gray.opacity(0.3))
                .cornerRadius(12)
            Text(formattedTime)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: 250, alignment: .leading)
    }
}

#Preview {
    MessageBubbleView(text: "Du Hast", sender: MessageSender.theirs, timestamp: Date())
}
