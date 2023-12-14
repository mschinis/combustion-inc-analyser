//
//  ListCloudView.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 14/12/2023.
//

import SwiftUI

struct ListCloudViewLoaded: View {
    var records: [CloudRecord]

    var body: some View {
        List {
            ForEach(records) { record in
                ListCloudViewRow(record: record)
            }
        }
    }
}

#Preview {
    ListCloudViewLoaded(records: [])
}
