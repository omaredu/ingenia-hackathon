import Foundation

class ContextualPrompter {
    // Builds a prompt for the agent with context from various sources
    static func buildPrompt(
        agentPersona: String,
        shortTermMemory: [ChatMessage],
        relevantLongTermMemories: [String],
        chatParticipants: [(id: String, name: String, isUser: Bool)],
        currentChannelName: String,
        incomingMessage: ChatMessage,
        isGroupChat: Bool,
        // New parameters
        isInterAgentMessage: Bool,
        previousMessageAwaited: ChatMessage? 
    ) -> String {
        var prompt = """
        You are an AI agent with the following persona:
        \(agentPersona)
        
        Current time: \(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short))
        
        You are in a conversation with the following participants:
        """
        
        // Add information about each participant
        for participant in chatParticipants {
            let participantType = participant.isUser ? "Human user" : "AI agent"
            prompt += "\n- \(participant.name) (ID: \(participant.id), Type: \(participantType))"
        }
        
        prompt += "\n\nThis is a \(isGroupChat ? "group chat" : "direct message") named: \(currentChannelName)"
        
        // Add relevant information from long-term memory if available
        if !relevantLongTermMemories.isEmpty {
            prompt += "\n\nRelevant information from your memory:"
            for (index, memory) in relevantLongTermMemories.enumerated() {
                prompt += "\n\(index + 1). \(memory)"
            }
        }
        
        // Add recent conversation history
        prompt += "\n\nRecent conversation history (up to last 20 messages):"
        for message in shortTermMemory {
            let senderName = chatParticipants.first { $0.id == message.senderId }?.name ?? message.senderName
            prompt += "\n\(senderName): \(message.content)"
        }
        
        // Context about the current interaction
        prompt += "\n\nInteraction Context:"
        
        if let awaitedMsg = previousMessageAwaited {
            let awaitingSenderName = chatParticipants.first { $0.id == awaitedMsg.senderId }?.name ?? awaitedMsg.senderName
            prompt += "\nYou previously decided to wait for more context after receiving this message from \(awaitingSenderName): '\(awaitedMsg.content)'."
            prompt += "\nThe waiting period is now over or a new message has arrived."
        }
        
        // Add the current message
        let senderName = chatParticipants.first { $0.id == incomingMessage.senderId }?.name ?? incomingMessage.senderName
        if isInterAgentMessage {
             prompt += "\nFellow AI agent, \(senderName), just said: \(incomingMessage.content)"
        } else {
             prompt += "\n\(senderName) (the user) just said: \(incomingMessage.content)"
        }
        
        // Behavioral Instructions Update
        prompt += """
        
        Instructions for your response:
        - Be *very* concise and relevant, only speak when needed.
        - Avoid unnecessary repetition and filler content.
        - Answer in a very condensed brief format and a WhatsApp style, as if you were a human. Do not use markdown or code blocks.
        - Be careful with overusing emojis. Use them only when appropriate for your persona and when they add value to the message.
        - Based on your persona and the entire context (history, memory, current interaction), formulate your response and choose a behavior pattern.
        
        Available Behavior Patterns:
        1. [BEHAVIOR_NORMAL]: Respond with a single message.
        2. [BEHAVIOR_MULTI_SHORT]: Split your response into multiple short messages using [SPLIT_MESSAGE_HERE].
        3. [BEHAVIOR_PRIVATE]: Send a private message (only visible to the original sender of the message you are replying to). Use this cautiously in group chats when you want to address a specific participant without involving others.
        4. [BEHAVIOR_SILENT]: Choose not to respond at all. Use if no response is needed or appropriate for your persona. Use if the incoming message is not relevant enough to you or your persona.
        5. [BEHAVIOR_WAIT_FOR_CONTEXT]: If the latest incoming message seems incomplete AND you strongly anticipate a direct follow-up message very soon from the same sender that will provide crucial missing context, you can choose to wait. Use this sparingly and only when essential for a meaningful response.
        
        How to format your output:
        Start your response *immediately* with the chosen behavior tag (e.g., "[BEHAVIOR_NORMAL] <your_message>").
        Do not add explanations about your chosen behavior.
        If using [BEHAVIOR_SILENT] or [BEHAVIOR_WAIT_FOR_CONTEXT], output only the tag itself.
        Stay in character according to your persona.
        """

        if isInterAgentMessage {
             prompt += "\nConsider *very* carefully if responding to another agent is necessary. Prioritize only meaningful interaction and avoid redundant messages. [BEHAVIOR_SILENT] is appropriate when replying to other agents unless you have a specific contribution."
        }

        if previousMessageAwaited != nil {
            prompt += "\nDo not choose [BEHAVIOR_WAIT_FOR_CONTEXT] again for this specific interaction sequence."
        }
        
        prompt += "\n\nYour response (begin immediately with a behavior tag):"
        
        return prompt
    }
} 
