//
//  ContactHeaderView.swift
//  Ingenia
//
//  Created by Alumno on 13/05/25.
//
import SwiftUI

struct ContactHeaderView: View {
    @Environment(\.dismiss) var dismiss

    var chatName: String = "Group Chat"
    var chatImage: String = "person.crop.circle.fill" // Can be any SF Symbol or custom asset

    var body: some View {
        ZStack {
            // Centered icon and name
            VStack(spacing: 4) {
                Image(systemName: chatImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)

                Text(chatName)
                    .font(.headline)
                    .foregroundColor(.primary)
            }

            // Left-aligned back button
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemGray6))
    }
}

#Preview {
    ContactHeaderView()
}
