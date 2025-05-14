import Foundation

protocol LLMClientProtocol {
    func generateResponse(prompt: String) async throws -> String
}

class OpenAIClient: LLMClientProtocol {
    private let apiKey: String
    private let model: String
    
    init(apiKey: String, model: String = "gpt-4.1") {
        self.apiKey = apiKey
        self.model = model
    }
    
    func generateResponse(prompt: String) async throws -> String {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": model,
            "messages": [
                ["role": "system", "content": "You are a helpful AI assistant."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.5
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
              let choices = jsonObject["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw NSError(domain: "OpenAIError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response"])
        }
        
        return content
    }
} 
