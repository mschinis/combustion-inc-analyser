//
//  ListCloudView.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 14/12/2023.
//

import Factory
import SwiftUI

struct ListCloudViewLoaded: View {
    var records: [CloudRecord]
    
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
    
    func didTapDownload(record: CloudRecord) {
        Task {
            do {
                try await cloudService.download(record: record)
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
                Button {
                    didTapDownload(record: record)
                } label: {
                    ListCloudViewRow(record: record)
                }
                .buttonStyle(.plain)
                .contextMenu {
                    Button {
                        didTapDownload(record: record)
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
    ListCloudViewLoaded(
        records: [
            .init(title: "Chicken"),
            .init(title: "Beef"),
            .init(title: "Phoenix")
        ]
    )
}
