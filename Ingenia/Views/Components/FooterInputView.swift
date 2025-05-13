//
//  FooterInputView.swift
//  Ingenia
//
//  Created by Alumno on 13/05/25.
//
import SwiftUI

struct FooterInputView: View {
    @Binding var messageText: String
    var onSend: () -> Void

    var body: some View {
        HStack {
            TextField("Type a message...", text: $messageText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.vertical, 8)

            Button(action: {
                onSend()
            }) {
                Image(systemName: "paperplane.fill")
                    .rotationEffect(.degrees(45))
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.blue)
                    .clipShape(Circle())
            }
            .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal)
        .background(Color(UIColor.systemBackground))
    }
}


#Preview {
    FooterInputPreviewWrapper()
}

struct FooterInputPreviewWrapper: View {
    @State private var previewText = ""

    var body: some View {
        FooterInputView(messageText: $previewText) {
            print("Send tapped with message: \(previewText)")
        }
    }
}
