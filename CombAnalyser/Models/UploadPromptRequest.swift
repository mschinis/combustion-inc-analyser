//
//  UploadPromptRequest.swift
//  CombAnalyser
//
//  Created by Michael Schinis on 09/06/2024.
//

import Foundation

struct UploadPromptRequest: Identifiable {
    var id: UUID {
        cloudRecord.uuid
    }

    var cloudRecord: CloudRecord
    var csvOutput: String
}
