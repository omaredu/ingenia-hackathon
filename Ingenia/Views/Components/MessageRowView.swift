//
//  MessageRowView.swift
//  Ingenia
//
//  Created by Alumno on 12/05/25.
//
import SwiftUI

struct MessageRowView: View {
    var messages: [Message] = []
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(messages) { message in
                HStack {
                    if message.sender.sender == .mine {
                        Spacer()
                    }
                    
                    MessageBubbleView(message: message)
                    
                    if message.sender.sender == .theirs {
                        Spacer()
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}
#Preview {
    let messages: [Message] = Message.mocks

    return MessageRowView(messages: messages)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
}
