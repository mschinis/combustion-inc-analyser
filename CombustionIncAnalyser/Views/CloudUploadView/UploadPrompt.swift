//
//  UploadPrompt.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 06/12/2023.
//

import Factory
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
    
    
    var csvOutput: String
    @State private var cloudRecord: CloudRecord

    @State private var loadingState: LoadingStateWithoutValue = .idle
    
    /// Controls whether a popup should be shown or not
    @Environment(\.popupMessage) private var popupMessage: Binding<PopupMessage?>
    /// Dismisses this view, when displayed as a sheet
    @Environment(\.dismiss) private var dismiss
    
    @Injected(\.cloudService) private var cloudService: CloudService
    
    private var isFormInvalid: Bool {
        cloudRecord
            .title
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty
    }
    
    private func didTapSubmit() async {
        do {
            let url = try await cloudService.upload(data: cloudRecord, contents: csvOutput)

            Pasteboard.general.set(string: url.absoluteString)

            popupMessage.wrappedValue = .init(
                state: .success,
                title: "File uploaded",
                description: "Link copied to clipboard"
            )

            dismiss()
        } catch {
            popupMessage.wrappedValue = .init(
                state: .error,
                title: "File upload failed",
                description: "\(error.localizedDescription)"
            )
        }
    
    }
    
    private func didTapDismiss() {
        dismiss()
    }
    
    init(cloudRecord: CloudRecord, csvOutput: String) {
        self._cloudRecord = State(initialValue: cloudRecord)
        self.csvOutput = csvOutput
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("", text: $cloudRecord.title, prompt: Text("Name your cook *"))
                }
            }
            .navigationTitle("Session details")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Cancel", action: didTapDismiss)
                }
                
                ToolbarItem(placement: .automatic) {
                    AsyncButton("Upload") {
                        await didTapSubmit()
                    }
                    .disabled(isFormInvalid)
                }
            }
            .macPadding()
        }
    }
}

#Preview {
    UploadPrompt(cloudRecord: .init(), csvOutput: "")
}
