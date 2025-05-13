//
//  ProfileView.swift
//  Ingenia
//
//  Created by Alumno on 13/05/25.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    VStack(spacing: 30) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 150, height: 150)
                        Text("Mati")
                            .font(.title)
                            .bold()
                        
                        Text("Estudiante de preparatoria")
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(10)
                        

                    }
                    .padding(.top, 40)
                }
                
                HStack {
                    NavigationLink {
                        ChatView()
                    } label: {
                        VStack {
                            Image(systemName: "message.fill")
                            Text("Chat")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    VStack {
                        Image(systemName: "person.fill")
                        Text("Perfil")
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.blue)
                }
                .padding()
                .background(Color.gray.opacity(0.3))
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ChatView: View {
    var body: some View {
        Text("Vista pendiente de chat")
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
