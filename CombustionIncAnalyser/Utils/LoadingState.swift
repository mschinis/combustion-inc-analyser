//
//  LoadingState.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 30/11/2023.
//

import Foundation

/// Loading state enum, allowing us to handle all cases
enum LoadingState<Value> {
    case idle
    case loading
    case success(Value)
    case failed(Error)
    
    /// Convenience variable for accessing value inside the success state of the enum
    /// without having to repeat the following implementation across the codebase
    var value: Value? {
        switch self {
        case let .success(value):
            return value
        default: return nil
        }
    }
    
    /// Convenience variable for checking if the loading state is idle
    var isIdle: Bool {
        switch self {
        case .idle: return true
        default: return false
        }
    }
    
    /// Convenience variable for checking if the loading state is currently loading
    var isLoading: Bool {
        switch self {
        case .loading: return true
        default: return false
        }
    }
}
