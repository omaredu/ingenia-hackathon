//
//  IngeniaApp.swift
//  Ingenia
//
//  Created by Omar Sánchez on 12/05/25.
//

import SwiftUI

@main
struct IngeniaApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    print("Ingenia Chat Application Started")
                    
                    // Check API key status
                    if let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] {
                        print("OpenAI API key found in environment variables")
                    } else {
                        print("WARNING: OpenAI API key not found in environment variables. Set OPENAI_API_KEY in your scheme or use a different secure method for storing the key.")
                    }
                }
        }
    }
}
