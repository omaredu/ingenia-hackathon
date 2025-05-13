//
//  MessageView.swift
//  Ingenia
//
//  Created by Alumno on 12/05/25.
//

import SwiftUI

struct MessageBubbleView: View {
    // let text: String
    // let sender: MessageSender
    // let timestamp: Date
    let message: Message

    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: message.timestamp)
    }

    var body: some View {
        VStack(alignment: message.sender.sender == .mine ? .trailing : .leading) {
            Text(message.sender.name)
                .font(.system(size: 15))
                .foregroundColor(.gray)
                .padding(.horizontal, 10)
                .padding(.top, 10)
            
            HStack{
                if (message.sender.sender == .theirs){
                    Image(systemName: "checkmark")
                        .resizable()
                        .frame(width: 5, height: 5)
                        .foregroundColor(.white)
                        .padding(15)
                        .background(Color.green)
                        .clipShape(Circle())
                }
                Text(message.text)
                    .padding(10)
                    .foregroundColor(message.sender.sender == .mine ? .white : .black)
                    .background(message.sender.sender == .mine ? Color.blue : Color.gray.opacity(0.3))
                    .cornerRadius(12)
            }
                Text(formattedTime)
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 25)
            
        }
        .frame(maxWidth: 250, alignment: message.sender.sender == .mine ? .trailing : .leading)
    }
}

#Preview {
    VStack {
        MessageBubbleView(message: Message.mocks[0])
        MessageBubbleView(message: Message.mocks[1])
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.white)
}
