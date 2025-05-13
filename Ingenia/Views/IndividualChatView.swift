//
//  IndividualChat.swift
//  Ingenia
//
//  Created by Alumno on 12/05/25.
//


import SwiftUI

struct IndividualChat: View {
    @State private var previewText: String = ""

    var body: some View {
        VStack {
            MessageRowView(text: "Du Hast", sender:  .theirs, timestamp: Date())
            MessageRowView(text: "Du Hast", sender:  .mine, timestamp: Date())
            Spacer() // This represents the chat messages area (you can fill this later with messages)

            FooterInputView(messageText: $previewText) {
                print("Send tapped with message: \(previewText)")
            }
        }
        .padding()
    }
}

#Preview {
    IndividualChat()
}
