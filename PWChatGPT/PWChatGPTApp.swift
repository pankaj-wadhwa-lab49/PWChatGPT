//
//  PWChatGPTApp.swift
//  PWChatGPT
//
//  Created by Pankaj Wadhwa on 09/08/23.
//

import SwiftUI

@main
struct PWChatGPTApp: App {
    @StateObject var vm = ViewModel(api: ChatGPTAPI())
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView(vm: vm)
            }
        }
    }
}
