import Foundation

protocol TextEmbeddingClientProtocol {
    func getEmbedding(for text: String) async throws -> [Double]
}

class OpenAIEmbeddingClient: TextEmbeddingClientProtocol {
    private let apiKey: String
    private let model: String
    
    init(apiKey: String, model: String = "text-embedding-3-small") {
        self.apiKey = apiKey
        self.model = model
    }
    
    func getEmbedding(for text: String) async throws -> [Double] {
        let url = URL(string: "https://api.openai.com/v1/embeddings")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": model,
            "input": text,
            "encoding_format": "float"
        ]
        
        let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "OpenAIError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorString = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(domain: "OpenAIError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "API error: \(errorString)"])
        }
        
        guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let dataArray = jsonObject["data"] as? [[String: Any]],
              let firstItem = dataArray.first,
              let embedding = firstItem["embedding"] as? [Double] else {
            throw NSError(domain: "OpenAIError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse embedding response"])
        }
        
        return embedding
    }
} 
