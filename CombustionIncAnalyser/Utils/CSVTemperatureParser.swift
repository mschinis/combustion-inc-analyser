//
//  CSVTemperatureParser.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 12/11/2023.
//

import Foundation

//extension Array where Element == String {
//    subscript(index: Int, default default: String = "") -> String {
//
//    }
//}

class CSVTemperatureParser {
    private(set) var headers: [String]
    private(set) var data: [String]

    init(_ csvString: String) {
        let rows = csvString.split(separator: "\r\n").map { String($0) }

        self.headers = rows[0].split(separator: ",").map { String($0) }
        self.data = Array(rows[1..<rows.count])
    }

    func parse() -> [CookTimelineRow] {
        return data
            .reduce(into: [CookTimelineRow]()) { partialResult, row in
                let rowData = row.split(separator: ",").map { String($0) }

                let dd = headers
                    .enumerated()
                    .reduce(into: [String: String]()) { partialResult, current in
                        partialResult[current.element] = current.offset < rowData.count ? rowData[current.offset] : nil
                    }

                // Remove items failing decoding
                if let row = try? CookTimelineRow(from: dd) {
                    partialResult.append(row)
                }
            }
    }
}

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

    func save() {
        let strHeaders = headers.joined(separator: ",")
        let strData = data.map { row in
            let rowData = row.serializedDictionary

            return headers.map { header in
                rowData[header] ?? ""
            }
            .joined(separator: ",")
        }
    
        let fileInfoWithHeaders = [fileInfo, strHeaders].joined(separator: "\r\n\r\n")
        let outputData = ([fileInfoWithHeaders] + strData).joined(separator: "\r\n")
        
        do {
            try outputData.write(to: url, atomically: false, encoding: .utf8)
        } catch {
            print(error.localizedDescription)
        }
    }
}
