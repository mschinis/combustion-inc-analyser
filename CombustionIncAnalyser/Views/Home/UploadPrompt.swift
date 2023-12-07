//
//  UploadPrompt.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 06/12/2023.
//

import SwiftUI

struct UploadPrompt: View {
//    enum CookType: Identifiable, CaseIterable, Codable {
//        static var allCases: [UploadPrompt.CookType]
//        
//        case beef
//        case pork
//        case poultry
//        case lamb
//        case fish
//        case other
//
//        var id: String {
//            self.rawValue
//        }
//        
//        var rawValue: String {
//            switch self {
//            case .beef: return "beef"
//            case .pork: return "pork"
//            case .poultry: return "poultry"
//            case .lamb: return "lamb"
//            case .fish: return "fish"
//            
//            case .other(let string): return string
//            }
//        }
//    }
    
    @Environment(\.dismiss) private var dismiss

    @State private var typeOfCook: String = ""
    @State private var cookingMethod: String = ""
    @State private var cookDetails: String = ""
    
    private var isFormInvalid: Bool {
        typeOfCook
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty
    }
    
    private func didTapSubmit() {
        
    }
    
    private func didTapDismiss() {
        dismiss()
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("", text: $typeOfCook, prompt: Text("What did you cook? *"))
                    
                    TextField("", text: $cookingMethod, prompt: Text("Cooking method"))
                }

                Section {
                    TextEditor(text: $cookDetails)
                } header: {
                    Text("Overall cook notes")
                }

                Button("Submit", action: {})
                    .disabled(isFormInvalid)
                
            }
            .navigationTitle("Session details")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Cancel", action: didTapDismiss)
                }
            }
            .macPadding()
        }
    }
}

#Preview {
    UploadPrompt()
}
