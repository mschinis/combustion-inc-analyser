//
//  CombustionIncAnalyserApp.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 11/11/2023.
//

import PopupView
import SwiftUI
import SwiftData
import FirebaseCore

@main
struct CombustionIncAnalyserApp: App {
    @State private var isSettingsVisible = false

    @StateObject private var homeViewModel = HomeViewModel()
    @State private var popupMessage: PopupMessage?

    init() {
        // We use Firebase to allow users to share their CSV data with us
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            HomeView(viewModel: homeViewModel)
                .environment(\.isSettingsVisible, $isSettingsVisible)
                .environment(\.popupMessage, $popupMessage)
                .popup(item: $popupMessage) { item in
                    PopupMessageView(
                        message: item
                    )
                    .shadow(color: .black.opacity(0.08), radius: 2, x: 0, y: 0)
                    .shadow(color: .black.opacity(0.16), radius: 24, x: 0, y: 0)

                } customize: {
                    $0
                        .type(.floater())
                        .autohideIn(2)
                        .position(.top)
                }
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
