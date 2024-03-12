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

    @Injected(\.cloudService) private var cloudService: CloudService

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
        }
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
