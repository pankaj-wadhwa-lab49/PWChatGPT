//
//  ChatGPTAPI.swift
//  PWChatGPT
//
//  Created by Pankaj Wadhwa on 09/08/23.
//

import Foundation

class ChatGPTAPI {
    private var apiKey: String {
        "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"
//        "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"
    }
    
    private var headers: [String: String] {
        [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(apiKey)"
        ]
    }
    
    private let jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        return jsonDecoder
    }()
    
    private var historyList = [Message]()
    private let systemMessage: Message
    private let temperature: Double
    private let model: String
    
    private let urlSession = URLSession.shared
    private var urlRequest: URLRequest {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        headers.forEach {  urlRequest.setValue($1, forHTTPHeaderField: $0) }
        return urlRequest
    }
    
    init(model: String = "gpt-3.5-turbo", systemPrompt: String = "You are a helpful assistant", temperature: Double = 0.5) {
        self.model = model
        self.systemMessage = .init(role: "system", content: systemPrompt)
        self.temperature = temperature
    }
    
    private func sendInitialStream() {
        Task {
            do {
                let stream = try await self.sendMessageStream(text: "What is James Bond")
                for try await line in stream {
                    print(line)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func jsonBody(text: String, stream: Bool = true) throws -> Data {
        let request = Request(model: model, temperature: temperature,
                              messages: generateMessages(from: text), stream: stream)
        return try JSONEncoder().encode(request)
    }
    
    private func generateMessages(from text: String) -> [Message] {
        var messages = [systemMessage] + historyList + [Message(role: "user", content: text)]
        
        if messages.contentCount > (4000 * 4) {
            _ = historyList.removeFirst()
            messages = generateMessages(from: text)
        }
        return messages
    }
    
    func sendMessageStream(text: String) async throws -> AsyncThrowingStream<String, Error> {
        var urlRequest = self.urlRequest
        urlRequest.httpBody = try jsonBody(text: text)
        
        let (result, response) = try await urlSession.bytes(for: urlRequest)
        try Task.checkCancellation()
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw "Invalid response"
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            var errorText = ""
            for try await line in result.lines {
                try Task.checkCancellation()
                errorText += line
            }
            
            if let data = errorText.data(using: .utf8), let errorResponse = try? jsonDecoder.decode(ErrorRootResponse.self, from: data).error {
                errorText = "\n\(errorResponse.message)"
            }
            
            throw "Bad Response: \(httpResponse.statusCode), \(errorText)"
        }
        
        
        return AsyncThrowingStream { continuation in
            Task(priority: .userInitiated) {
                do {
                    var responseText = ""
                    for try await line in result.lines {
                        try Task.checkCancellation()
                        if line.hasPrefix("data: "),
                           let data = line.dropFirst(6).data(using: .utf8),
                           let response = try? self.jsonDecoder.decode(StreamCompletionResponse.self, from: data),
                           let text = response.choices.first?.delta.content {
                            print(line)
                            responseText += text
                            continuation.yield(text)
                        }
                    }
                    self.appendToHistoryList(userText: text, responseText: responseText)
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
    
    private func appendToHistoryList(userText: String, responseText: String) {
        self.historyList.append(.init(role: "user", content: userText))
        self.historyList.append(.init(role: "assistant", content: responseText))
    }
}
