//
//  CombustionIncAnalyserApp.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 11/11/2023.
//

import SwiftUI
import SwiftData
import FirebaseCore

@main
struct CombustionIncAnalyserApp: App {
    @State private var isSettingsVisible = false

    @StateObject private var homeViewModel = HomeViewModel()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            HomeView(viewModel: homeViewModel)
                .environment(\.isSettingsVisible, $isSettingsVisible)
            
        }
        .commands {
            CommandGroup(after: .appSettings) {
                Button("Settings...") {
                    isSettingsVisible = true
                }
                .keyboardShortcut(",")
            }
            
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
