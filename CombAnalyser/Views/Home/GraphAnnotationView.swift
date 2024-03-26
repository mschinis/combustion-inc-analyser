//
//  GraphAnnotationView.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 01/12/2023.
//

import SwiftUI

struct GraphAnnotationView: View {
    var annotationRequest: GraphAnnotationRequest

    var didSubmit: (Int, String) -> Void
    var didDismiss: () -> Void

    // Copy of the annotation request and edit this, so we avoid rerendering the graph unnecessarily
    @State private var annotationRequestCopy: GraphAnnotationRequest
    
    init(annotationRequest: GraphAnnotationRequest, didSubmit: @escaping (Int, String) -> Void, didDismiss: @escaping () -> Void) {
        self.annotationRequest = annotationRequest
        self.didSubmit = didSubmit
        self.didDismiss = didDismiss

        self._annotationRequestCopy = State(initialValue: annotationRequest)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                TextEditor(
                    text: Binding(get: {
                        annotationRequestCopy.note
                    }, set: { newValue in
                        annotationRequestCopy.note = newValue
                    })
                )
                .frame(width: 300, height: 200)

                HStack {
                    Button("OK", action: {
                        // Update graph
                        didSubmit(
                            annotationRequest.sequenceNumber,
                            annotationRequestCopy.note
                        )

                        // Close the sheet
                        didDismiss()
                    })

                    Button("Cancel", role: .cancel) {
                        didDismiss()
                    }
                }
            }
            .navigationTitle("Add new note")
            .macPadding()
        }

    }
}

//#Preview {
//    GraphAnnotationView()
//}
