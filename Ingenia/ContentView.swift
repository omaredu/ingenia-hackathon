//
//  ContentView.swift
//  Ingenia
//
//  Created by Omar Sánchez on 12/05/25.
//

import SwiftUI

// Read API key from environment variables or use a secure storage solution
private func getAPIKey() -> String {
    // For development, use environment variables (replace this with a secure storage solution for production)
    // You can set this in Xcode: Edit Scheme > Run > Arguments > Environment Variables
    if let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"], !apiKey.isEmpty, apiKey != "YOUR_API_KEY_HERE" {
        print("Using API Key from environment variable.")
        return apiKey
    }
    // Fallback to a placeholder IF you absolutely must for quick testing, but warn.
    // It's better to crash or show an error if no valid key is found.
    print("WARNING: No valid OPENAI_API_KEY environment variable set. Falling back to potentially invalid placeholder. Please set the environment variable.")
    return "" // This should ideally prompt user or fail gracefully
}

struct ContentView: View {
    @StateObject private var chatManager = ChatManager(
        userId: "user-1",
        userName: "User",
        apiKey: getAPIKey()
    )
    @State private var selectedChannelId: String? = nil
    @State private var messageText: String = ""
    @State private var showingCreateGroupSheet = false
    @State private var newGroupName = ""
    @State private var selectedAgentsForGroup: Set<String> = []
    
    var body: some View {
        NavigationSplitView {
            ChannelListView(
                chatManager: chatManager,
                selectedChannelId: $selectedChannelId,
                showingCreateGroupSheet: $showingCreateGroupSheet,
                newGroupName: $newGroupName,
                selectedAgentsForGroup: $selectedAgentsForGroup
            )
        } detail: {
            if let channelId = selectedChannelId,
               let channel = chatManager.channels.first(where: { $0.id == channelId }) {
                ChatDetailView(
                    channel: channel,
                    chatManager: chatManager,
                    messageText: $messageText
                )
            } else {
                ChatDetailPlaceholderView()
            }
        }
        .sheet(isPresented: $showingCreateGroupSheet) {
            CreateGroupView(
                chatManager: chatManager,
                newGroupName: $newGroupName,
                selectedAgentsForGroup: $selectedAgentsForGroup,
                showingCreateGroupSheet: $showingCreateGroupSheet,
                selectedChannelId: $selectedChannelId
            )
        }
            
    }
}

#Preview {
    ContentView()
}
