//
//  ActivityStatus.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 30/11/2023.
//

import SwiftUI

struct ActivityStatusMessage: Equatable {
    enum State: String, Equatable {
        case success, failed
        
        var icon: String {
            switch self {
            case .success: return "checkmark"
            case .failed: return "xmark"
            }
        }
        
        var backgroundColor: String {
            switch self {
            case .success: return "SuccessBackgroundColor"
            case .failed: return "ErrorBackgroundColor"
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

struct ActivityStatus: View {
    var status: ActivityStatusMessage
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: status.state.icon)
                .font(.system(size: 32))
            
            VStack(alignment: .leading) {
                Text(status.title)
                    .bold()

                Text(status.description)
            }
        }
        .baselineOffset(4)
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .foregroundStyle(
            Color(status.state.textColor)
        )
        .background(
            Color(status.state.backgroundColor)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color(status.state.backgroundColor), radius: 8)
    }
}

#Preview {
    ActivityStatus(
        status: .init(
            state: .success,
            title: "File uploaded",
            description: "Link copied to clipboard"
        )
    )
    .padding(32)
}

#Preview {
    ActivityStatus(
        status: .init(
            state: .failed,
            title: "Failed",
            description: "Failed uploading"
        )
    )
    .padding(32)
}
