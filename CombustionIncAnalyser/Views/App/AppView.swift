//
//  AppView.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 14/03/2024.
//

import SwiftUI

struct AppView: View {
    enum Tab {
        case home
        case cloudList
        case settings
    }

    @State private var currentTab: Tab = .home
    @ObservedObject var homeViewModel: HomeViewModel
    
    /// Loads a remote file and switches the current active tab
    /// - Parameter record: The record to load its csv contents
    func didSelectRemote(record: CloudRecord) async {
        await homeViewModel.didSelectRemote(record: record)
        
        currentTab = .home
    }
    
    var body: some View {
        TabView(selection: $currentTab) {
            HomeView(
                viewModel: homeViewModel
            )
            .tag(Tab.home)
            .tabItem {
                Label(
                    title: { Text("Analyse") },
                    icon: { Image(systemName: "chart.xyaxis.line") }
                )
            }
            
//                LiveView(viewModel: liveViewModel)
//                    .tabItem {
//                        Label(
//                            title: { Text("Live") },
//                            icon: { Image(systemName: "chart.xyaxis.line") }
//                        )
//                    }
            
            ListCloudView(
                didTapDownload: didSelectRemote(record:)
            )
            .tag(Tab.cloudList)
            .tabItem {
                Label(
                    title: { Text("Cloud") },
                    icon: { Image(systemName: "cloud") }
                )
            }
            
            SettingsView()
                .tag(Tab.settings)
                .tabItem {
                    Label(
                        title: { Text("Settings") },
                        icon: { Image(systemName: "gear") }
                    )
                }
        }
    }
}

#Preview {
    AppView(homeViewModel: HomeViewModel())
}
