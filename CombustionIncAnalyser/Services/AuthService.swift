//
//  AuthService.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 13/12/2023.
//

import Factory
import FirebaseAuth
import Foundation

class AuthService {
    private(set) var auth = Auth.auth()

    var user: User? = nil

    var isLoggedIn: Bool {
        Auth.auth().currentUser != nil
    }
    
    init() {
        auth
            .addStateDidChangeListener { _, user in
                self.user = user
            }
    }
    
    func logout() throws {
        try Auth.auth().signOut()
    }
}
