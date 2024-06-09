//
//  CloudListViewModel.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 14/03/2024.
//

import Combine
import Factory
import Foundation

class CloudListViewModel: ObservableObject {
    @Published private(set) var loadingState: LoadingState<[CloudRecord]> = .idle
    
    @Injected(\.authService) private var authService: AuthService
    @Injected(\.cloudService) private var cloudService: CloudService
    
    private var subscribers: Set<AnyCancellable> = []

    init() {
        // User logged out
        authService.auth.addStateDidChangeListener { _, user in
            if user == nil {
                self.loadingState = .failed(AuthError.notLoggedIn)
            }
        }
        
        cloudService
            .publisher
            .receive(on: DispatchQueue.main)
            .sink { completion in
                print("completion", completion)
            } receiveValue: { records in
                if let records {
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
        } catch {
            print("CloudList:: Failed logging out")
        }
    }
}
