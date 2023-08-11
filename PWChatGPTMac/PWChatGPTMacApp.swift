//
//  PWChatGPTMacApp.swift
//  PWChatGPTMac
//
//  Created by Pankaj Wadhwa on 8/11/23.
//

import SwiftUI

@main
struct PWChatGPTMacApp: App {
    @StateObject var vm = ViewModel(api: ChatGPTAPI())
    var body: some Scene {
        MenuBarExtra("PW ChatGPT", image: "openai") {
            VStack(spacing: 0) {
                HStack {
                    Text("XCA ChatGPT")
                        .font(.title)
                    Spacer()
                    
                    Button {
                        guard !vm.isInteractingWithChatGPT else { return }
                        vm.clearMessages()
                    } label: {
                        Image(systemName: "trash")
                            .symbolRenderingMode(.multicolor)
                            .font(.system(size: 24))
                    }
                    
                    .buttonStyle(.borderless)
                    
                    
                    Button {
                        exit(0)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .symbolRenderingMode(.multicolor)
                            .font(.system(size: 24))
                    }
                    
                    .buttonStyle(.borderless)
                }
                .padding()
                ContentView(vm: vm)
            }
            
            .frame(width: 480, height: 576)
        }
        .menuBarExtraStyle(.window)
    }
}
