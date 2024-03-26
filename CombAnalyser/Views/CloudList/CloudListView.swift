//
//  CloudListView.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 14/12/2023.
//

import Combine
import Factory
import SwiftUI

struct CloudListView: View {
    @StateObject private var viewModel: CloudListViewModel
    var didTapDownload: (CloudRecord) async -> Void

    init(viewModel: CloudListViewModel = .init(), didTapDownload: @escaping (CloudRecord) async -> Void) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.didTapDownload = didTapDownload
    }
    
    var body: some View {
        NavigationStack {
            switch viewModel.loadingState {
            case .idle:
                Color.clear
            case .loading:
                ProgressView()
            case .success(let records) where records.isEmpty:
                Text("You have no saved cooks")
                    .font(.title)
            case .success(let records):
                CloudListViewLoaded(
                    records: records,
                    didTapDownload: didTapDownload
                )
                .navigationTitle("Cloud")
                .toolbar {
                    ToolbarItem {
                        Button("Logout", systemImage: "person.slash") {
                            viewModel.logout()
                        }
                    }
                }
            case .failed(let error as AuthError) where error == .notLoggedIn:
                AuthView(
                    viewModel: .init(authorizationSuccess: { _ in
                        Task {
                            await viewModel.load()
                        }
                    }),
                    isDismissVisible: false
                )
            case .failed:
                VStack {
                    Text("Something went wrong.")
                    
                    AsyncButton("Try again") {
                        await viewModel.load()
                    }
                }
            }
        }
        .task {
            await viewModel.load()
        }
    }
}

#Preview {
    CloudListView(
        didTapDownload: { _ in }
    )
    .previewDisplayName("Logged out")
}
