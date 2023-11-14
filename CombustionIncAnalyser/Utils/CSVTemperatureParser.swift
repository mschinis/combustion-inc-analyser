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

        var headers = rows[0].split(separator: ",").map { String($0) }
        
        // Inject the necessary properties we need, in order to annotate graphs and save it back into csv
        if !headers.contains(CookTimelineRow.CodingKeys.notes.rawValue) {
            headers.append(CookTimelineRow.CodingKeys.notes.rawValue)
        }

        self.headers = headers
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
