import Foundation

class LocalAgentLTM: ObservableObject {
    private let embeddingClient: TextEmbeddingClientProtocol
    private let agentId: String
    @Published private(set) var memories: [MemoryItem] = []
    private let persistenceManager: LTMPersistenceManager
    
    init(agentId: String, embeddingClient: TextEmbeddingClientProtocol) {
        self.agentId = agentId
        self.embeddingClient = embeddingClient
        self.persistenceManager = LTMPersistenceManager(agentId: agentId)
        
        // Load saved memories from storage
        Task {
            await loadMemories()
        }
    }
    
    private func loadMemories() async {
        do {
            let loadedMemories = try await persistenceManager.loadMemories()
            await MainActor.run {
                self.memories = loadedMemories
            }
        } catch {
            print("Error loading memories: \(error)")
        }
    }
    
    func addMemory(text: String, associatedUserId: String? = nil, topic: String? = nil, importance: Double = 1.0) async throws {
        // Generate embedding for the memory text
        let embedding = try await embeddingClient.getEmbedding(for: text)
        
        let newMemory = MemoryItem(
            text: text,
            embedding: embedding,
            associatedUserId: associatedUserId,
            topic: topic,
            importance: importance
        )
        
        await MainActor.run {
            memories.append(newMemory)
        }
        
        // Save the updated memories
        try await persistenceManager.saveMemories(memories)
    }
    
    func queryMemories(queryText: String, maxResults: Int = 5) async throws -> [String] {
        guard !memories.isEmpty else { return [] }
        
        let queryEmbedding = try await embeddingClient.getEmbedding(for: queryText)
        
        var memoriesWithScores: [(memory: MemoryItem, score: Double)] = []
        
        for memory in memories where memory.embedding != nil {
            let similarity = cosineSimilarity(queryEmbedding, memory.embedding!)
            memoriesWithScores.append((memory: memory, score: similarity))
        }
        
        memoriesWithScores.sort { $0.score > $1.score }
        
        let topMemories = memoriesWithScores.prefix(maxResults).map { $0.memory.text }
        return topMemories
    }
    
    private func cosineSimilarity(_ a: [Double], _ b: [Double]) -> Double {
        guard a.count == b.count && !a.isEmpty else { return 0.0 }
        
        var dotProduct: Double = 0.0
        var magnitudeA: Double = 0.0
        var magnitudeB: Double = 0.0
        
        for i in 0..<a.count {
            dotProduct += a[i] * b[i]
            magnitudeA += a[i] * a[i]
            magnitudeB += b[i] * b[i]
        }
        
        magnitudeA = sqrt(magnitudeA)
        magnitudeB = sqrt(magnitudeB)
        
        if magnitudeA == 0 || magnitudeB == 0 {
            return 0.0
        }
        
        return dotProduct / (magnitudeA * magnitudeB)
    }
}

// Persistence manager for saving and loading memories
class LTMPersistenceManager {
    private let agentId: String
    private var fileURL: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("agent_\(agentId)_memories.json")
    }
    
    init(agentId: String) {
        self.agentId = agentId
    }
    
    func saveMemories(_ memories: [MemoryItem]) async throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(memories)
        try data.write(to: fileURL)
    }
    
    func loadMemories() async throws -> [MemoryItem] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return []
        }
        
        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([MemoryItem].self, from: data)
    }
} 
