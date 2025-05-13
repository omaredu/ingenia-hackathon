//
//  IndividualChat.swift
//  Ingenia
//
//  Created by Alumno on 12/05/25.
//


import SwiftUI

struct IndividualChat: View {
    @State private var previewText: String = ""
    var messages: [Message] = []

    var body: some View {
        VStack {
            ScrollView(.vertical){
                MessageRowView(messages: messages)
            }
            Spacer() // This represents the chat messages area (you can fill this later with messages)

            FooterInputView(messageText: $previewText) {
                print("Send tapped with message: \(previewText)")
            }
        }
        .padding()
    }
}

#Preview {
    let messages: [Message] = Message.mocks

    IndividualChat(messages: messages)
}
