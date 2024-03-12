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
    
    func delete(record: CloudRecord) {
        Task {
            do {
                try await cloudService.delete(record: record)
            } catch {
                print("Error", error)
            }
        }
    }
    
    var body: some View {
        List {
            ForEach(records) { record in
                ListCloudViewRow(record: record)
                    .contextMenu {
                        Button(action: {
                            self.recordToDelete = record
                        }) {
                            Text("Delete")
                        }
                    }
            }
            .onDelete { indexSet in
                for index in indexSet {
                    self.recordToDelete = records[index]
                }
            }
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
                    delete(record: recordToDelete!)
                }
            },
            message: {
                Text("This action is irreversible and the cook and related notes will be permanently removed.")
            }
        )
    }
}

#Preview {
    ListCloudViewLoaded(records: [])
}
