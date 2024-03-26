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
    
    @Binding var noteHoverPosition: GraphTimelinePosition?
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
                    VStack {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Time: \(row.timeInterval.hourMinuteFormat())")
                                    .font(.headline)
                                Text(row.notes ?? "")
                            }

                            Spacer()

                            Button(action: {
                                graphAnnotationRequest = .init(
                                    sequenceNumber: row.sequenceNumber,
                                    note: row.notes ?? ""
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

                        Divider()
                    }
                    .onHover(perform: { hovering in
                        if hovering {
                            noteHoverPosition = GraphTimelinePosition(
                                x: Float(row.timestamp),
                                data: row
                            )
                        } else {
                            noteHoverPosition = nil
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
        noteHoverPosition: .constant(nil),
        graphAnnotationRequest: .constant(nil),
        didTapRemoveAnnotation: { _ in }
    )
}
