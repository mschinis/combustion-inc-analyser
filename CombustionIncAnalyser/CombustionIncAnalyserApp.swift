//
//  CombustionIncAnalyserApp.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 11/11/2023.
//

import SwiftUI
import SwiftData

@main
struct CombustionIncAnalyserApp: App {
    
    @StateObject private var homeViewModel = HomeViewModel()
    
    var body: some Scene {
        WindowGroup {
            HomeView(viewModel: homeViewModel)
        }
        .commands {
            CommandGroup(after: .newItem) {
                Button("Open") {
                    homeViewModel.didTapOpenFilepicker()
                }
                .keyboardShortcut("o")
                
                Button("Save") {
                    homeViewModel.didTapSave()
                }
                .disabled(homeViewModel.selectedFileURL == nil)
                .keyboardShortcut("s")
            }
        }
    }
}
