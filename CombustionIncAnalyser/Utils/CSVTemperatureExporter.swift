//
//  CSVTemperatureExporter.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 13/11/2023.
//

import Foundation

class CSVTemperatureExporter {
    private var url: URL

    private var fileInfo: String
    private var headers: [String]
    private var data: [CookTimelineRow]
    
    init(url: URL, fileInfo: String, headers: [String], data: [CookTimelineRow]) {
        self.url = url
        self.fileInfo = fileInfo
        self.headers = headers
        self.data = data
    }

    func output() -> String {
        let strHeaders = headers.joined(separator: ",")
        let strData = data.map { row in
            let rowData = row.serializedDictionary

            return headers.map { header in
                rowData[header] ?? ""
            }
            .joined(separator: ",")
        }
    
        let fileInfoWithHeaders = [fileInfo, strHeaders].joined(separator: "\n\n")

        return ([fileInfoWithHeaders] + strData).joined(separator: "\n")
    }
    
    func save() {
        let outputData = output()

        do {
            try outputData.write(to: url, atomically: false, encoding: .utf8)
        } catch {
            print(error.localizedDescription)
        }
    }
}
