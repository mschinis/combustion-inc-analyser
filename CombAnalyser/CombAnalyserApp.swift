//
//  CombAnalyserApp.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 11/11/2023.
//

import Factory
import PopupView
import SwiftUI
import SwiftData
import FirebaseCore

@main
struct CombAnalyserApp: App {
    @State private var crossCompatibleSheet: CrossCompatibleWindow?

    @StateObject private var homeViewModel = HomeViewModel()
    
    @StateObject private var liveViewModel = LiveViewModel()

    @State private var popupMessage: PopupMessage?
    
    @Environment(\.openWindow) private var openWindow
    
//    @Injected(\.authService) private var authService: AuthService

    /// Opens:
    /// - a window on MacOS
    /// - a sheet on iOS
    ///
    /// - Parameter window: The type of window to open
    func openCrossCompatibleWindow(_ window: CrossCompatibleWindow) {
        #if os(macOS)
        openWindow(id: window.rawValue)
        #else
        self.crossCompatibleSheet = window
        #endif
    }
    
    init() {
        // We use Firebase to allow users to share their CSV data with us
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            AppView(homeViewModel: homeViewModel)
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
                // Settings sheet
                .sheet(item: $crossCompatibleSheet, content: { type in
                    switch type {
                    case .settings:
                        SettingsView(toolbarContent: SettingsSheetToolbar())
                    }
                })
        }
        .commands {
            CommandGroup(after: .appSettings) {
                Button("Settings...") {
                    openCrossCompatibleWindow(.settings)
                }
                .keyboardShortcut(",")
                
                Button("Sign Out") {
                    // Logout of firebase by grabbing the auth service programmatically
                    let authService = Container.shared.authService()
                    try? authService.logout()
                }
            }
            
            CommandGroup(after: .newItem) {
                Button("Open") {
                    homeViewModel.didTapOpenFilepicker()
                }
                .keyboardShortcut("o")
                
                Button("Save") {
                    Task {
                        await homeViewModel.didTapSave()
                    }
                }
                .disabled(homeViewModel.file == nil)
                .keyboardShortcut("s")
            }
        }
        
        WindowGroup("Settings", id: CrossCompatibleWindow.settings.rawValue) {
            SettingsView()
        }
        #if os(macOS)
        .windowResizability(.contentMinSize)
        #endif
    }
}
