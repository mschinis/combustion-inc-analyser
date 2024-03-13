//
//  CloudFile.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 13/03/2024.
//

import Foundation

struct CloudFile: FileType {
    var windowTitle: String {
        cloudRecord.title
    }
    
    var fileInfo: String = ""
    var headers: [String] = []
    var data: [CookTimelineRow] = []
    
    var cloudRecord: CloudRecord
    
    init(cloudRecord: CloudRecord, csv: String) {
        self.cloudRecord = cloudRecord
        parseAndUpdate(csv: csv)
    }
}
