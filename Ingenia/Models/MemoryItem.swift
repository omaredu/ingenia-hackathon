import Foundation

struct MemoryItem: Identifiable, Codable {
    let id: UUID
    let text: String
    let embedding: [Double]?
    let timestamp: Date
    let associatedUserId: String?
    let topic: String?
    let importance: Double
    
    init(text: String, embedding: [Double]? = nil, associatedUserId: String? = nil, topic: String? = nil, importance: Double = 1.0, id: UUID = UUID(), timestamp: Date = Date()) {
        self.id = id
        self.text = text
        self.embedding = embedding
        self.timestamp = timestamp
        self.associatedUserId = associatedUserId
        self.topic = topic
        self.importance = importance
    }
    
    enum CodingKeys: String, CodingKey {
        case id, text, embedding, timestamp, associatedUserId, topic, importance
    }
    
    // Custom encoding/decoding to handle embedding data efficiently
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        text = try container.decode(String.self, forKey: .text)
        embedding = try container.decodeIfPresent([Double].self, forKey: .embedding)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        associatedUserId = try container.decodeIfPresent(String.self, forKey: .associatedUserId)
        topic = try container.decodeIfPresent(String.self, forKey: .topic)
        importance = try container.decode(Double.self, forKey: .importance)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(text, forKey: .text)
        try container.encodeIfPresent(embedding, forKey: .embedding)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encodeIfPresent(associatedUserId, forKey: .associatedUserId)
        try container.encodeIfPresent(topic, forKey: .topic)
        try container.encode(importance, forKey: .importance)
    }
} 
