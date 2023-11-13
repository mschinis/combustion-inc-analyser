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
//    var sharedModelContainer: ModelContainer = {
//        let schema = Schema([
//            Item.self,

//        ])
//        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
//
//        do {
//            return try ModelContainer(for: schema, configurations: [modelConfiguration])
//        } catch {
//            fatalError("Could not create ModelContainer: \(error)")
//        }
//    }()

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
//        .modelContainer(sharedModelContainer)
    }
}
