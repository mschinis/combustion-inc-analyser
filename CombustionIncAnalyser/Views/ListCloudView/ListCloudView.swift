//
//  ListCloudView.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 14/12/2023.
//

import Combine
import Factory
import SwiftUI

class ListCloudViewModel: ObservableObject {
    @Published private(set) var loadingState: LoadingState<[CloudRecord]> = .idle
    
    @Injected(\.authService) private var authService: AuthService
    @Injected(\.cloudService) private var cloudService: CloudService
    
    private var subscribers: Set<AnyCancellable> = []

    init() {
        cloudService
            .publisher
            .receive(on: DispatchQueue.main)
            .sink { completion in
                print("completion", completion)
            } receiveValue: { records in
                if let records {
                    print("records", records)
                    self.loadingState = .success(records)
                }
            }
            .store(in: &subscribers)
    }
    
    @MainActor
    func load() async {
        guard authService.isLoggedIn else {
            self.loadingState = .failed(AuthError.notLoggedIn)
            return
        }
        
        if loadingState.isIdle {
            self.loadingState = .loading
        }

        do {
            let records = try await cloudService.findUserRecords()
            self.loadingState = .success(records)
        } catch {
            self.loadingState = .failed(error)
        }
    }
    
    @MainActor
    func logout() {
        do {
            try authService.logout()
            loadingState = .failed(AuthError.notLoggedIn)
        } catch {
            print("CloudList:: Failed logging")
        }
    }
}

struct ListCloudView: View {
    @StateObject private var viewModel: ListCloudViewModel
    
    init(viewModel: ListCloudViewModel = .init()) {
        self._viewModel = StateObject(wrappedValue: viewModel)
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
                ListCloudViewLoaded(records: records)
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
    ListCloudView()
        .previewDisplayName("Logged out")
}
