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
    @State private var isSettingsSheetVisible = false

    @StateObject private var homeViewModel = HomeViewModel()
    @State private var popupMessage: PopupMessage?
    
    @Environment(\.openWindow) private var openWindow
    
    /// Opens:
    /// - a window on MacOS
    /// - a sheet on iOS
    ///
    /// - Parameter window: The type of window to open
    func openCrossCompatibleWindow(_ window: CrossCompatibleWindow) {
        #if os(macOS)
        openWindow(id: window.rawValue)
        #else
        switch window {
        case .settings:
            self.isSettingsSheetVisible = true
        }
        #endif
    }
    
    init() {
        // We use Firebase to allow users to share their CSV data with us
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            HomeView(viewModel: homeViewModel)
                .environment(\.openCrossCompatibleWindow, openCrossCompatibleWindow(_:))
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
                #if os(iOS)
                // Settings sheet
                .sheet(isPresented: $isSettingsSheetVisible, content: {
                    SettingsView()
                })
                #endif
        }
        .commands {
            CommandGroup(after: .appSettings) {
                Button("Settings...") {
                    openCrossCompatibleWindow(.settings)
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

        WindowGroup("Settings", id: CrossCompatibleWindow.settings.rawValue) {
            SettingsView()
        }
    }
}
