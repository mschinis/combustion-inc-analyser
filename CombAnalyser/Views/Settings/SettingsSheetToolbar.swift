//
//  SettingsSheetToolbar.swift
//  CombAnalyser
//
//  Created by Michael Schinis on 05/06/2024.
//

import SwiftUI

struct SettingsSheetToolbar: ToolbarContent {
    @Environment(\.dismiss) private var dismiss
    
    var body: some ToolbarContent {
        ToolbarItem {
            Button(action: {
                dismiss()
            }, label: {
                Image(systemName: "xmark")
            })
        }
    }
}

#Preview {
    NavigationView {
        Text("This view has a toolbar")
    }
    .toolbar {
        SettingsSheetToolbar()
    }
}
