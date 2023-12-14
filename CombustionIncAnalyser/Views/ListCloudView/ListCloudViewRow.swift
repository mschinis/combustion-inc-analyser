//
//  ListCloudViewRow.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 14/12/2023.
//

import SwiftUI

struct ListCloudViewRow: View {
    var record: CloudRecord

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(record.typeOfCook)
                    .font(.headline)

                Text(record.cookingMethod)
            }
            
            Spacer()

            Button(action: {}, label: {
                Image(systemName: "info.circle")
            })
        }
    }
}

#Preview {
    ListCloudViewRow(
        record: CloudRecord(
            typeOfCook: "Lemon Chicken Breast",
            cookingMethod: "Pan cooked",
            cookDetails: "Cooked chicken in the pan, flipping every 1 minute. Added lemon zest midway of the cook",
            shareWithCombustion: true,
            userId: "myself",
            fileName: "..."
        )
    )
    .previewLayout(.sizeThatFits)
}
