//
//  ChatGPTAPIModels.swift
//  PWChatGPT
//
//  Created by Pankaj Wadhwa on 09/08/23.
//

import Foundation

struct Message: Codable {
    let role: String
    let content: String
}
struct Request: Codable {
    let model: String
    let temperature: Double
    let messages: [Message]
    let stream: Bool
}

extension Array where Element == Message {
    var contentCount: Int { reduce(0, { $0 + $1.content.count })}
}

extension String: CustomNSError {
    
    public var errorUserInfo: [String : Any] {
        [
            NSLocalizedDescriptionKey: self
        ]
    }
}

struct ErrorRootResponse: Decodable {
    let error: ErrorResponse
}

struct ErrorResponse: Decodable {
    let message: String
    let type: String?
}

struct StreamCompletionResponse: Decodable {
    let choices: [StreamChoice]
}

struct StreamChoice: Decodable {
    let finishReason: String?
    let delta: StreamMessage
}

struct StreamMessage: Decodable {
    let role: String?
    let content: String?
}
