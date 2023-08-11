//
//  MessageRow.swift
//  PWChatGPT
//
//  Created by Pankaj Wadhwa on 8/10/23.
//

import Foundation

struct MessageRow: Identifiable {
    let id = UUID()
    var isInteractingWithChatGPT: Bool
    let sendImage: String
    let sendText: String
    let responseImage: String
    var responseText: String?
    var responseError: String?
}

struct AttributedOutput {
    let string: String
//    let results: [ParserResult]
}

enum MessageRowType {
    case attributed(AttributedOutput)
    case rawText(String)
    
    var text: String {
        switch self {
        case .attributed(let attributedOutput):
            return attributedOutput.string
        case .rawText(let string):
            return string
        }
    }
}
