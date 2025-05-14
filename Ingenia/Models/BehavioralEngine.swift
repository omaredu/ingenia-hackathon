import Foundation

class BehavioralEngine {
    enum BehaviorType {
        case normal
        case multiShort
        case `private`
        case silent
        case waitForContext
    }
    
    struct ParsedResponse {
        let behaviorType: BehaviorType
        let messages: [String]
        
        // Utility to check if there's any content to send
        var hasContent: Bool {
            return !messages.isEmpty && behaviorType != .silent && behaviorType != .waitForContext
        }
    }
    
    // Parse raw LLM response and determine the behavior and message content(s)
    static func parseResponse(_ rawResponse: String) -> ParsedResponse {
        let trimmedResponse = rawResponse.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check for silent behavior
        if trimmedResponse.contains("[BEHAVIOR_SILENT]") {
            return ParsedResponse(behaviorType: .silent, messages: [])
        }
        
        // Check for wait for context
        if trimmedResponse.contains("[BEHAVIOR_WAIT_FOR_CONTEXT]") {
            // No message content is expected with this tag, just the decision to wait
            return ParsedResponse(behaviorType: .waitForContext, messages: [])
        }
        
        // Determine behavior type
        let behaviorType: BehaviorType
        if trimmedResponse.contains("[BEHAVIOR_MULTI_SHORT]") {
            behaviorType = .multiShort
        } else if trimmedResponse.contains("[BEHAVIOR_PRIVATE]") {
            behaviorType = .private
        } else {
            // Default to normal behavior
            behaviorType = .normal
        }
        
        // Extract content based on behavior type
        var contentWithoutTag = trimmedResponse
        
        // Remove behavior tags
        for tag in ["[BEHAVIOR_NORMAL]", "[BEHAVIOR_MULTI_SHORT]", "[BEHAVIOR_PRIVATE]", "[BEHAVIOR_SILENT]", "[BEHAVIOR_WAIT_FOR_CONTEXT]"] {
            contentWithoutTag = contentWithoutTag.replacingOccurrences(of: tag, with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        // Process message content based on behavior type
        var messages: [String] = []
        
        if behaviorType == .multiShort {
            // Split into multiple messages
            messages = contentWithoutTag.components(separatedBy: "[SPLIT_MESSAGE_HERE]")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        } else if !contentWithoutTag.isEmpty {
            // Single message for normal or private
            messages = [contentWithoutTag]
        }
        
        return ParsedResponse(behaviorType: behaviorType, messages: messages)
    }
    
    // Convert a parsed response into message(s) to send
    static func createMessagesToSend(
        parsedResponse: ParsedResponse,
        senderId: String,
        senderName: String,
        channelId: String
    ) -> [ChatMessageToSend] {
        guard parsedResponse.hasContent else { return [] }
        
        return parsedResponse.messages.enumerated().map { index, content in
            // Add a slight delay for multi-message behavior to simulate typing
            let delay: TimeInterval? = parsedResponse.behaviorType == .multiShort ? 
                TimeInterval(index) * 1.0 + Double.random(in: 0.5...1.5) : nil
            
            return ChatMessageToSend(
                content: content,
                targetChannelId: channelId,
                isPrivate: parsedResponse.behaviorType == .private,
                delay: delay
            )
        }
    }
} 