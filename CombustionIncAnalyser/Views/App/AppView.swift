//
//  AppView.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 14/03/2024.
//

import SwiftUI

struct AppView: View {
    @ObservedObject var homeViewModel: HomeViewModel
    
    var body: some View {
        TabView {
            HomeView(viewModel: homeViewModel)
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
            
            ListCloudView()
                .tabItem {
                    Label(
                        title: { Text("Cloud") },
                        icon: { Image(systemName: "cloud") }
                    )
                }
        }
    }
}

#Preview {
    AppView(homeViewModel: HomeViewModel())
}
