//
//  AuthView.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 01/12/2023.
//

import AuthenticationServices
import Factory
import FirebaseAuth
import SwiftUI

struct AuthView: View {
    enum CurrentFeature: String, CaseIterable {
        case sync
        case share

        var icon: String {
            switch self {
            case .sync: return "icloud.and.arrow.up"
            case .share: return "square.and.arrow.up"
            }
        }
        
        var title: String {
            switch self {
            case .sync: return "Sync cook data across devices"
            case .share: return "Share cook data and notes with friends"
            }
        }
    }

    @StateObject private var viewModel = AuthViewModel()

    var isDismissVisible: Bool = true
    
    @State private var currentFeature: CurrentFeature = .sync
    @State private var timer = Timer.publish(every: 3, on: .main, in: .default).autoconnect()
    
    @Environment(\.dismiss) private var dismiss

    init(viewModel: AuthViewModel = AuthViewModel(), isDismissVisible: Bool = true) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.isDismissVisible = isDismissVisible
    }
    
    var body: some View {
        VStack {
            Color("AuthHeaderColor")
                .clipShape(
                    .rect(bottomLeadingRadius: 24, bottomTrailingRadius: 24)
                )
                .frame(maxWidth: .infinity, maxHeight: 75)
                .overlay {
                    Text("Create free account")
                        .font(.title)
                        .foregroundStyle(.black)
                        .bold()
                }

            Spacer()
            
            // Internal content
            VStack(spacing: 0) {
                ZStack {
                    ForEach(CurrentFeature.allCases, id: \.rawValue) { feature in
                        VStack {
                            Image(systemName: feature.icon)
                                .font(.largeTitle)
                            
                            Text(feature.title)
                                .padding(.top)
                        }
                        .opacity(feature == currentFeature ? 1 : 0)
                    }
                }
                
                Spacer()
                
                SignInWithAppleButton(
                    .signIn,
                    onRequest: viewModel.signInRequest(request:),
                    onCompletion: viewModel.signInCallback(result:)
                )
                #if os(macOS)
                // SignInWithAppleButton has a bug on MacOS, where the button occupies the entire
                // area. This following workaround, fixes this issue:
                // https://stackoverflow.com/questions/77205710/signinwithapplebutton-occupies-entire-view-space-and-ignores-the-frame-sizing
                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                #endif
                .frame(height: 44)
                
                if isDismissVisible {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                    .buttonStyle(.borderless)
                    .padding(.top)
                }
            }
            .padding()

        }
        #if os(macOS)
        .frame(minWidth: 100, minHeight: 300)
        #endif
        .onReceive(timer, perform: { _ in
            withAnimation {
                guard let currentFeatureIndex = CurrentFeature.allCases.firstIndex(of: currentFeature) else {
                    currentFeature = CurrentFeature.allCases[0]
                    return
                }
                
                if currentFeatureIndex == CurrentFeature.allCases.count - 1 {
                    currentFeature = CurrentFeature.allCases[0]
                } else {
                    currentFeature = CurrentFeature.allCases[currentFeatureIndex + 1]
                }
            }
        })
    }
}

#Preview {
    AuthView()
}
