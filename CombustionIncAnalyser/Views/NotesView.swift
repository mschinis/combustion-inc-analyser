//
//  NotesView.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 14/11/2023.
//

import SwiftUI

struct NotesView: View {
    /// List of notes to be displayed
    var notes: [CookTimelineRow]
    
    @Binding var noteHoveredTimestamp: Double?
    /// Set when the user tapped on edit button
    @Binding var graphAnnotationRequest: GraphAnnotationRequest?
    /// Called when the user tapped on delete button
    var didTapRemoveAnnotation: (Int) -> Void

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading) {
                Text("Cook notes")
                    .font(.title2)
                    .padding(.bottom)

                ForEach(notes) { row in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Time: \(row.timeInterval.hourMinuteFormat())")
                                .font(.headline)
                            Text(row.notes ?? "")
                            
                            Divider()
                        }

                        Spacer()

                        Button(action: {
                            graphAnnotationRequest = .init(
                                sequenceNumber: row.sequenceNumber,
                                text: row.notes ?? ""
                            )
                        }) {
                            Image(systemName: "pencil")
                        }
                        
                        Button(action: {
                            didTapRemoveAnnotation(row.sequenceNumber)
                        }) {
                            Image(systemName: "xmark.bin")
                        }
                    }
                    .onHover(perform: { hovering in
                        if hovering {
                            noteHoveredTimestamp = row.timestamp
                        } else {
                            noteHoveredTimestamp = nil
                        }
                    })
                }

                if notes.isEmpty {
                    Spacer()

                    Text("No cooking notes added.")
                        .font(.headline)
                    Text("Select a point on the graph to enter a new note!")

                    Spacer()
                }
            }
            .padding()
        }
    }
}

#Preview {
    NotesView(
        notes: [],
        noteHoveredTimestamp: .constant(nil),
        graphAnnotationRequest: .constant(nil),
        didTapRemoveAnnotation: { _ in }
    )
}
