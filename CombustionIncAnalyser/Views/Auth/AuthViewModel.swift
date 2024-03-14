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
    
    private var nonce: String? = nil

    /// Generates a sign in request for Apple's sign in method
    ///
    /// - Parameter request: The request payload, passed in by apple
    func signInRequest(request: ASAuthorizationAppleIDRequest) {
        nonce = randomNonceString()
        
        request.requestedScopes = [.email]
        request.nonce = sha256(nonce!)
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
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                return
            }
            
            guard let nonce else {
                // Invalid state: A login callback was received, but no login request was sent
                return
            }
            
            guard let appleIDToken = appleIDCredential.identityToken,
                  let idTokenString = String(data: appleIDToken, encoding: .utf8)
            else {
                return
            }
            
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(
                withProviderID: "apple.com",
                idToken: idTokenString,
                rawNonce: nonce
            )
            
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

extension AuthViewModel {
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      let charset: Array<Character> =
          Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
      var result = ""
      var remainingLength = length

      while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
          var random: UInt8 = 0
          let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
          if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
          }
          return random
        }

        randoms.forEach { random in
          if remainingLength == 0 {
            return
          }

          if random < charset.count {
            result.append(charset[Int(random)])
            remainingLength -= 1
          }
        }
      }

      return result
    }
    
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        return String(format: "%02x", $0)
      }.joined()

      return hashString
    }
}
