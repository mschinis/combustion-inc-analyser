//
//  CloudListViewLoaded.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 14/12/2023.
//

import Factory
import SwiftUI

struct CloudListViewLoaded: View {
    var records: [CloudRecord]
    var didTapDownload: (CloudRecord) async -> Void

    @Injected(\.cloudService) private var cloudService: CloudService

    @State private var recordToDelete: CloudRecord? = nil
    
    /// Handles deletion when the customer confirms deletion
    /// - Parameter record: The record to delete
    func didConfirmDeletion(record: CloudRecord) {
        Task {
            do {
                try await cloudService.delete(record: record)
            } catch {
                print("Error", error)
            }
        }
    }
    
    /// Displays the delete confirmation dialog
    /// - Parameter record: The record to delete
    func didTapDelete(record: CloudRecord) {
        self.recordToDelete = record
    }
    
    /// Handles swipe to delete action
    /// - Parameter indexSet: The index set of records to delete
    func didTapDeleteSwipeAction(indexSet: IndexSet) {
        for index in indexSet {
            self.didTapDelete(record: records[index])
        }
    }

    var body: some View {
        List {
            ForEach(records) { record in
                AsyncButton {
                    await didTapDownload(record)
                } label: {
                    CloudListViewRow(record: record)
                }
                .buttonStyle(.plain)
                .contextMenu {
                    AsyncButton {
                        await didTapDownload(record)
                    } label: {
                        Text("Download")
                    }

                    Button{
                        didTapDelete(record: record)
                    } label: {
                        Text("Delete")
                    }
                }
            }
            .onDelete(perform: didTapDeleteSwipeAction(indexSet:))
        }
        .confirmationDialog(
            "Confirm deletion",
            isPresented: Binding(get: {
                self.recordToDelete != nil
            }, set: { newValue in
                if !newValue {
                    self.recordToDelete = nil
                }
            }),
            actions: {
                Button("Confirm", role: .destructive) {
                    didConfirmDeletion(record: recordToDelete!)
                }
            },
            message: {
                Text("This action is irreversible and the cook and related notes will be permanently removed.")
            }
        )
    }
}

#Preview {
    CloudListViewLoaded(
        records: [
            .init(title: "Chicken"),
            .init(title: "Beef"),
            .init(title: "Phoenix")
        ],
        didTapDownload: { _ in }
    )
}
