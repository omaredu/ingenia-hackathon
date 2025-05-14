import Foundation

class Agent: Identifiable, ObservableObject, Equatable {
    let id: String
    let name: String
    let persona: String
    let isGlobalAgent: Bool
    let avatar: String
    
    private let llmClient: LLMClientProtocol
    private let embeddingClient: TextEmbeddingClientProtocol
    private let ltm: LocalAgentLTM
    private var shortTermMemory: [ChatMessage] = []
    private let shortTermMemoryLimit = 20
    
    // State for waiting for context
    @Published private(set) var isWaitingForContext: Bool = false
    private var messageAwaitedContext: ChatMessage? = nil
    private var waitingContinuationTask: Task<Void, Never>? = nil
    private let maxContextWaitTime: TimeInterval = 15.0 // Wait 15 seconds for more context
    private var lastAgentInteractionTime: Date?
    private let agentInteractionCooldown: TimeInterval = 3.0 // 3 seconds cooldown for agent-to-agent replies

    init(id: String = UUID().uuidString, name: String, persona: String, llmClient: LLMClientProtocol, embeddingClient: TextEmbeddingClientProtocol, isGlobalAgent: Bool = false, avatar: String = "Avatar") {
        self.id = id
        self.name = name
        self.persona = persona
        self.llmClient = llmClient
        self.embeddingClient = embeddingClient
        self.ltm = LocalAgentLTM(agentId: id, embeddingClient: embeddingClient)
        self.isGlobalAgent = isGlobalAgent
        self.avatar = avatar
    }
    
    static func == (lhs: Agent, rhs: Agent) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Cancels any ongoing wait for context task
    private func cancelWaitingTask() {
        waitingContinuationTask?.cancel()
        waitingContinuationTask = nil
    }
    
    // Resets the waiting state
    private func resetWaitingState() {
        cancelWaitingTask()
        isWaitingForContext = false
        messageAwaitedContext = nil
        // If using @MainActor for Agent, ensure this is on main thread if it modifies @Published vars
        // Task { @MainActor in self.isWaitingForContext = false }
    }
    
    func processMessage(
        incomingMessage: ChatMessage,
        channel: ChatChannel,
        allParticipants: [(id: String, name: String, isUser: Bool)],
        isInterAgentMessage: Bool
    ) async throws -> [ChatMessageToSend] {
        // 1. Handle Cooldown for Inter-Agent Messages
        if isInterAgentMessage {
            if let lastTime = lastAgentInteractionTime, Date().timeIntervalSince(lastTime) < agentInteractionCooldown {
                if incomingMessage.senderId != self.id { // Don't cooldown self-originated propagation (though this shouldn't happen)
                    print("Agent \(self.name) on inter-agent cooldown. Staying silent for message from \(incomingMessage.senderName).")
                    return [] // Silent due to cooldown
                }
            }
            // Update interaction time only if we actually process/respond to an agent message
            // This will be updated later if a response is generated.
        }

        // 2. Handle Continuation of a Waited Message
        var actualMessageToProcess = incomingMessage
        var previouslyAwaited: ChatMessage? = nil

        if isWaitingForContext,
           let awaitedMsg = messageAwaitedContext,
           awaitedMsg.senderId == incomingMessage.senderId, // Same sender
           awaitedMsg.channelId == incomingMessage.channelId { // Same channel
            print("Agent \(self.name) received continuation message from \(incomingMessage.senderName). Processing with original context.")
            previouslyAwaited = awaitedMsg // Pass the original message to prompter
            resetWaitingState() // We got the context, no longer waiting
            // actualMessageToProcess is already the new incomingMessage
        }
        
        // If we are waiting, but this message is NOT a continuation, ignore this incoming message for now.
        // The timeout will handle the original awaited message eventually.
        else if isWaitingForContext && messageAwaitedContext?.id != incomingMessage.id {
            print("Agent \(self.name) is waiting for context for another message, ignoring current: \(incomingMessage.content)")
            return []
        }

        // 3. Update Short-Term Memory with the message we are actually processing
        updateShortTermMemory(with: actualMessageToProcess)

        // 4. Query Long-Term Memory
        let relevantMemories = try await queryRelevantMemories(incomingMessage: actualMessageToProcess, channel: channel, allParticipantsInContext: allParticipants)

        // 5. Build Prompt
        let prompt = ContextualPrompter.buildPrompt(
            agentPersona: persona,
            shortTermMemory: shortTermMemory,
            relevantLongTermMemories: relevantMemories,
            chatParticipants: allParticipants,
            currentChannelName: channel.name,
            incomingMessage: actualMessageToProcess,
            isGroupChat: !channel.isDirectMessage,
            isInterAgentMessage: isInterAgentMessage,
            previousMessageAwaited: previouslyAwaited
        )

        // 6. Generate Response from LLM
        let rawResponse = try await llmClient.generateResponse(prompt: prompt)

        // 7. Parse Response
        let parsedResponse = BehavioralEngine.parseResponse(rawResponse)

        // 8. Handle [BEHAVIOR_WAIT_FOR_CONTEXT]
        if parsedResponse.behaviorType == .waitForContext {
            // Cannot wait if we were just processing a message after waiting.
            guard previouslyAwaited == nil else {
                print("Agent \(self.name) tried to WAIT again after just processing an awaited message. Defaulting to SILENT.")
                resetWaitingState() // Ensure we are not stuck
                return [] // Default to silent in this edge case
            }
            
            print("Agent \(self.name) is choosing to wait for more context after message: '\(actualMessageToProcess.content)'")
            await MainActor.run { // Ensure @Published var is updated on main thread
                self.isWaitingForContext = true
            }
            self.messageAwaitedContext = actualMessageToProcess
            cancelWaitingTask() // Cancel any previous task

            let originalMessageIdToWaitFor = actualMessageToProcess.id // Capture for closure
            waitingContinuationTask = Task {
                do {
                    try await Task.sleep(for: .seconds(maxContextWaitTime))
                    
                    // Check if still waiting for THIS specific message
                    if self.isWaitingForContext && self.messageAwaitedContext?.id == originalMessageIdToWaitFor {
                        print("Agent \(self.name) timed out waiting for context on message ID: \(originalMessageIdToWaitFor).")
                        // Simplified: Agent gives up and resets. No proactive response to timed-out message.
                        // More complex: Could re-process `messageAwaitedContext` here with a "timeout" prompt.
                        await MainActor.run { // Ensure @Published var is updated on main thread
                             resetWaitingState()
                        }
                        // To trigger a response after timeout, you'd need to call ChatManager or re-process.
                        // For now, it just stops waiting.
                    }
                } catch is CancellationError {
                    print("Agent \(self.name) waiting task was cancelled (likely because context arrived or new wait initiated).")
                } catch {
                    print("Agent \(self.name) waiting task failed: \(error)")
                    await MainActor.run { resetWaitingState() }
                }
            }
            return [] // No messages to send now
        }
        
        // If we reach here, it means we are not waiting for context (or just finished waiting and got a new message)
        // So, ensure any prior waiting state is fully cleared.
        if previouslyAwaited != nil { // If we just processed a message after waiting
            resetWaitingState() // Ensure all wait states are clear
        }

        // 9. Create Messages to Send (if not waiting)
        let messagesToSend = BehavioralEngine.createMessagesToSend(
            parsedResponse: parsedResponse,
            senderId: id,
            senderName: name,
            channelId: channel.id // Messages are for the current channel by default
        )
        
        // 10. Update Inter-Agent Cooldown if we are sending a message in response to another agent
        if isInterAgentMessage && !messagesToSend.isEmpty && parsedResponse.behaviorType != .silent {
            self.lastAgentInteractionTime = Date()
        }

        // 11. Decide on LTM Storage
        if shouldStoreInLTM(incomingMessage: actualMessageToProcess, isInterAgentMessage: isInterAgentMessage, agentResponded: !messagesToSend.isEmpty && parsedResponse.behaviorType != .silent) {
            try await storeInLTM(message: actualMessageToProcess)
        }

        return messagesToSend
    }
    
    private func updateShortTermMemory(with message: ChatMessage) {
        // Avoid adding duplicate if already present (can happen with complex flows)
        if !shortTermMemory.contains(where: { $0.id == message.id }) {
            shortTermMemory.append(message)
        }
        if shortTermMemory.count > shortTermMemoryLimit {
            shortTermMemory.removeFirst(shortTermMemory.count - shortTermMemoryLimit)
        }
    }
    
    private func queryRelevantMemories(incomingMessage: ChatMessage, channel: ChatChannel, allParticipantsInContext: [(id: String, name: String, isUser: Bool)]) async throws -> [String] {
        let participantNames = channel.participants.map { participantId -> String in
            if let participant = allParticipantsInContext.first(where: { $0.id == participantId }) {
                return participant.name
            } else if participantId == self.id { // Should be covered by allParticipantsInContext
                return self.name
            }
            return participantId // Fallback to ID if name not found
        }.joined(separator: ", ")
        
        let queryText = "Context: Chat in '\(channel.name)'. Participants: \(participantNames). Incoming Message from \(incomingMessage.senderName): \(incomingMessage.content)"
        return try await ltm.queryMemories(queryText: queryText, maxResults: 5)
    }
    
    private func shouldStoreInLTM(incomingMessage: ChatMessage, isInterAgentMessage: Bool, agentResponded: Bool) -> Bool {
        let messageContent = incomingMessage.content
        if messageContent.count < 20 { return false } // Slightly higher threshold

        // Don't store if this agent itself sent the message
        if incomingMessage.senderId == self.id { return false }

        // If it's an inter-agent message, be more selective
        if isInterAgentMessage {
            // Only store if this agent actually responded to it, or if it contains a question mark (implying it might be important for future context)
            if !agentResponded && !messageContent.contains("?") {
                print("Agent \(self.name) chose not to store inter-agent message: '\(messageContent)' because it didn't respond and no question mark.")
                return false
            }
        }
        
        // Avoid storing very similar messages quickly from the same sender
        let recentSimilarMessages = shortTermMemory.filter { $0.senderId == incomingMessage.senderId && $0.id != incomingMessage.id }.suffix(3)
        for memory in recentSimilarMessages {
            if let similarity = stringSimilarity(messageContent, memory.content), similarity > 0.85 {
                print("Agent \(self.name) chose not to store message due to high similarity with recent memory: '\(messageContent)'")
                return false
            }
        }
        print("Agent \(self.name) storing message in LTM: '\(messageContent)'")
        return true
    }
    
    private func storeInLTM(message: ChatMessage) async throws {
        let memoryText = "In the chat '\(message.channelId)', \(message.senderName) said: \(message.content)"
        try await ltm.addMemory(
            text: memoryText,
            associatedUserId: message.senderId,
            importance: 1.0 // Could adjust importance based on factors like `isInterAgentMessage`
        )
    }
    
    private func stringSimilarity(_ a: String, _ b: String) -> Double? {
        let aCount = a.count
        let bCount = b.count
        if aCount == 0 && bCount == 0 { return 1.0 }
        if aCount == 0 || bCount == 0 { return 0.0 }
        if abs(aCount - bCount) > max(aCount, bCount) / 2 { return 0.0 } // If lengths are too different

        var distance = Array(repeating: Array(repeating: 0, count: bCount + 1), count: aCount + 1)
        for i in 0...aCount { distance[i][0] = i }
        for j in 0...bCount { distance[0][j] = j }

        for i in 1...aCount {
            for j in 1...bCount {
                let cost = a[a.index(a.startIndex, offsetBy: i - 1)] == b[b.index(b.startIndex, offsetBy: j - 1)] ? 0 : 1
                distance[i][j] = min(distance[i - 1][j] + 1, distance[i][j - 1] + 1, distance[i - 1][j - 1] + cost)
            }
        }
        let maxLen = Double(max(aCount, bCount))
        return maxLen > 0 ? (maxLen - Double(distance[aCount][bCount])) / maxLen : 1.0
    }
}
