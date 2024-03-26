//
//  AuthViewModel.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 12/12/2023.
//

import AuthenticationServices
import CryptoKit
import FirebaseAuth
import Foundation

class AuthViewModel: ObservableObject {
    var authorizationSuccess: (User) -> Void
    var authorizationError: (Error) -> Void

    init(authorizationSuccess: @escaping (User) -> Void = { _ in }, authorizationError: @escaping (Error) -> Void = { _ in }) {
        self.authorizationSuccess = authorizationSuccess
        self.authorizationError = authorizationError
    }
    
    private(set) var nonce: String? = nil

    /// Generates a sign in request for Apple's sign in method
    ///
    /// - Parameter request: The request payload, passed in by apple
    func signInRequest(request: ASAuthorizationAppleIDRequest) {
        nonce = AuthService.randomNonceString()
        
        request.requestedScopes = [.email]
        request.nonce = AuthService.sha256(nonce!)
    }
    
    /// Handles the callback method, when the sign in action was completed/cancelled/errored.
    ///
    /// - Parameter result: The result of the callback
    func signInCallback(result: Result<ASAuthorization, Error>) {
        switch result {
        case let .success(authResults):
            authenticateWithFirebaseAndCreateSession(using: authResults)
        case let .failure(error):
            let authError = ASAuthorizationError(_nsError: error as NSError)
            switch authError.code {
            case .canceled:
                print("Auth:: User canceled flow")
                // User canceled flow
            default:
                print("Auth:: Error \(error.localizedDescription)")
                // Error occured
            }
        }
        
        ///
        /// Given a successful Apple sign-in authorization (`ASAuthorization`), this method:
        ///     - attempts to authenticate with a Firebase authentication backend...
        ///
        ///  If you are using SwiftUI's `SignInWithAppleButton` button, call this method
        ///  from it's `onCompletion` callback handler.
        ///
        func authenticateWithFirebaseAndCreateSession(using authorization: ASAuthorization) {
            guard let nonce else {
                // Invalid state: A login callback was received, but no login request was sent
                return
            }

            let credential = AuthService.getFirebaseCredential(nonce: nonce, authorization: authorization)
            
            // Authenticate with Firebase using the credential object
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error {
                    // Note: If error.code == .MissingOrInvalidNonce, make sure
                    // you're sending the SHA256-hashed nonce as a hex string with
                    // your request to Apple.
                    print("Error occured when authenticating with Firebase: \(error.localizedDescription)")
                    
                    self.authorizationError(error)
                    
                    return
                }
                
                guard let authResult else {
                    return
                }
                
                print("Auth:: User logged in with user id \"\(authResult.user.uid)\"")

                self.authorizationSuccess(authResult.user)
            }
        }
    }
}
