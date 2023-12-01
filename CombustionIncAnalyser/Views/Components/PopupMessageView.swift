//
//  PopupMessageView.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 30/11/2023.
//

import SwiftUI

struct PopupMessage: Equatable {
    enum State: String, Equatable {
        case success, error
        
        var icon: String {
            switch self {
            case .success: return "checkmark"
            case .error: return "xmark"
            }
        }
        
        var backgroundColor: String {
            switch self {
            case .success: return "SuccessBackgroundColor"
            case .error: return "ErrorBackgroundColor"
            }
        }
        
        var textColor: String {
            return "PopupTextColor"
        }
    }

    var state: State
    var title: String
    var description: String
}

struct PopupMessageView: View {
    var message: PopupMessage
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: message.state.icon)
                .font(.system(size: 32))
            
            VStack(alignment: .leading) {
                Text(message.title)
                    .bold()

                Text(message.description)
            }
        }
        .baselineOffset(4)
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .foregroundStyle(
            Color(message.state.textColor)
        )
        .background(
            Color(message.state.backgroundColor)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color(message.state.backgroundColor), radius: 8)
    }
}

#Preview {
    PopupMessageView(
        message: .init(
            state: .success,
            title: "File uploaded",
            description: "Link copied to clipboard"
        )
    )
    .padding(32)
}

#Preview {
    PopupMessageView(
        message: .init(
            state: .error,
            title: "Failed",
            description: "Failed uploading"
        )
    )
    .padding(32)
}
