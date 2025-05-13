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
        HStack {
            if sender == .mine {
                Spacer()
            }
            VStack(alignment : sender == .mine ? .trailing : .leading){
                MessageBubbleView(text: text, sender: sender, timestamp: Date())
                
            }
            if sender == .theirs {
                Spacer()
            }
            
        }
        .padding(.leading, 20)
        .padding(.trailing, 20)
    }
}

    #Preview {
        VStack(spacing: 10) {
            MessageRowView(text: "Du Hast eine Nachricht! sdasasasasdasdasdasdasdasdaasda", sender: .mine, timestamp: Date())
            MessageRowView(text: "This is their message", sender: .theirs, timestamp: Date())
            MessageRowView(text: "this", sender: .mine, timestamp: Date())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }

