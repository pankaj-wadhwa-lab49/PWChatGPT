//
//  ParserResult.swift
//  PWChatGPT
//
//  Created by Pankaj Wadhwa on 8/12/23.
//

import Foundation
struct ParserResult: Identifiable {
    let id = UUID()
    let attributedString: AttributedString
    let isCodeBlock: Bool
    let codeBlockLanguage: String?
}
