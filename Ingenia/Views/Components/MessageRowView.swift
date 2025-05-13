//
//  MessageRowView.swift
//  Ingenia
//
//  Created by Alumno on 12/05/25.
//

import SwiftUI

struct MessageRowView: View {
    let text: String
    let sender: MessageSender
    let timestamp: Date
    
    var body: some View {
        VStack {
            if sender == .mine {
                MessageBubbleView(text: text, sender: sender, timestamp: timestamp)
                    
                    
            } else {
                MessageBubbleView(text: text, sender: sender, timestamp: timestamp)
                Spacer()
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(.green)
    }
}


#Preview {
    VStack{
        MessageRowView(text: "Stringer", sender: .mine, timestamp: Date())
        MessageRowView(text: "Stringer", sender: .theirs, timestamp: Date())
    }.frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
}
