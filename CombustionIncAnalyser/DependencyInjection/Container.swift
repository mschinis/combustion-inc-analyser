//
//  Container.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 13/12/2023.
//

import Factory
import FirebaseCore
import Foundation

extension Container {
    var authService: Factory<AuthService> {
        self {
            AuthService()
        }
        .singleton
    }
    
    var cloudService: Factory<CloudService> {
        self {
            CloudService()
        }
        .singleton
    }
}
