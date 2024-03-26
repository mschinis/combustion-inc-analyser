//
//  CloudListViewRow.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 14/12/2023.
//

import Factory
import SwiftUI

struct CloudListViewRow: View {
    var record: CloudRecord

    @State private var areDetailsVisible = false

    var body: some View {
        HStack {
            Text(record.title)
            
            Spacer()
        }
    }
}

#Preview {
    CloudListViewRow(
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
