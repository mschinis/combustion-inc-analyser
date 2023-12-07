//
//  AuthPromptView.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 01/12/2023.
//

import SwiftUI

struct AuthPromptView: View {
    var body: some View {
        VStack {
            Color("AuthHeaderColor")
                .clipShape(
                    .rect(bottomLeadingRadius: 24, bottomTrailingRadius: 24)
                )
                .frame(maxHeight: 75)
                .overlay {
                    Text("Create free account")
                        .font(.title)
                        .foregroundStyle(.black)
                        .bold()
                }

            VStack {
                Text("This feature requires a free account.")
                
                Text("We will never share your personal information.")
            }
            .padding()
            
            Spacer()
        }
        .frame(width: 500)
    }
}

#Preview {
    AuthPromptView()
}
