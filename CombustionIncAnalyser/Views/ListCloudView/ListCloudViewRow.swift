//
//  ListCloudViewRow.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 14/12/2023.
//

import Factory
import SwiftUI

struct ListCloudViewRow: View {
    var record: CloudRecord

    @State private var areDetailsVisible = false
    @State private var isDeleteDialogVisible = false

    @Injected(\.cloudService) private var cloudService: CloudService
    
    func delete(record: CloudRecord) {
        Task {
            do {
                try await cloudService.delete(record: record)
            } catch {
                print("Error", error)
            }
        }
    }
    
    func download(record: CloudRecord) {
        Task {
            do {
                try await cloudService.download(record: record)
            } catch {
                print("Error", error)
            }
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(record.title)
                    .font(.headline)

                Text(record.cookingMethod)
            }
            
            Spacer()

            Button(action: {
                download(record: record)
            }, label: {
                Label("Load", systemImage: "envelope.open")
            })
            
            Button(action: {
                areDetailsVisible = true
            }, label: {
                Image(systemName: "info.circle")
            })
            
            Button(role: .destructive) {
                isDeleteDialogVisible = true
            } label: {
                Image(systemName: "trash")
            }
        }
        .confirmationDialog(
            "Confirm deletion",
            isPresented: $isDeleteDialogVisible,
            actions: {
                Button("Confirm", role: .destructive) {
                    delete(record: record)
                }
            },
            message: {
                Text("This action is irreversible and the cook and related notes will be permanently removed.")
            }
        )
        .alert("Cook details", isPresented: $areDetailsVisible) {
            Button {
                // TODO: Load csv file
            } label: {
                Text("Analyse")
            }

            Button(role: .cancel) {
                areDetailsVisible = false
            } label: {
                Text("Close")
            }
        } message: {
            Text(
                """
                Last updated: \(record.updatedAt.formatted())
                
                \(record.title)
                \(record.cookingMethod)
                \n\(record.cookDetails)
                """
            )
        }

    }
}

#Preview {
    ListCloudViewRow(
        record: CloudRecord(
            title: "Lemon Chicken Breast",
            cookingMethod: "Pan cooked",
            cookDetails: "Cooked chicken in the pan, flipping every 1 minute. Added lemon zest midway of the cook",
            shareWithCombustion: true,
            userId: "myself",
            fileName: "..."
        )
    )
    .previewLayout(.sizeThatFits)
}
