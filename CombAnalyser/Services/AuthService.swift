//
//  AuthService.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 13/12/2023.
//

import AuthenticationServices
import CryptoKit

import Factory
import FirebaseAuth
import Foundation

class AuthService: ObservableObject {
    private(set) var auth = Auth.auth()

    @Published var user: User? = nil

    var isLoggedIn: Bool {
        user != nil
    }
    
    var delegate: AppleSignInDelegate?
    
    init() {
        auth
            .addStateDidChangeListener { _, user in
                self.user = user
            }
    }
    
    func logout() throws {
        try Auth.auth().signOut()
    }
    
    /// Firebase requires user authentication before deleting the account.
    /// This method prompts the user to authenticate, and if completed successfully, calls the "completeUserDeletion" method
    func reauthenticateAndDeleteAccount() {
        // ReAuthenticate the user before deleting
        let nonce = AuthService.randomNonceString()

        delegate = AppleSignInDelegate(successCallback: { authorization in
            let credential = AuthService.getFirebaseCredential(nonce: nonce, authorization: authorization)
            self.user?.reauthenticate(with: credential) { _, _ in
                // TODO: Handle error scenarios.
                self.completeUserDeletion()
            }
            
        }, errorCallback: { _ in
            print("Error")
        })

        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = AuthService.sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = delegate
        authorizationController.performRequests()
    }
    
    private func completeUserDeletion() {
        Task {
            do {
                try await auth.currentUser?.delete()
            } catch {
                print("Auth:: Failed deleting account")
            }
        }
    }
}

extension AuthService {
    static func getFirebaseCredential(nonce: String, authorization: ASAuthorization) -> AuthCredential {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            fatalError("cdcd")
        }

        guard let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8)
        else {
            fatalError("cdcdc")
        }

        return OAuthProvider.credential(
            withProviderID: "apple.com",
            idToken: idTokenString,
            rawNonce: nonce
        )
    }
    
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    static func randomNonceString(length: Int = 32) -> String {
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
    
    static func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        return String(format: "%02x", $0)
      }.joined()

      return hashString
    }
}

class AppleSignInDelegate: NSObject, ASAuthorizationControllerDelegate {
    var successCallback: (ASAuthorization) -> Void
    var errorCallback: (Error) -> Void
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        successCallback(authorization)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        errorCallback(error)
    }
    
    init(successCallback: @escaping (ASAuthorization) -> Void, errorCallback: @escaping (Error) -> Void) {
        self.successCallback = successCallback
        self.errorCallback = errorCallback
    }
}
