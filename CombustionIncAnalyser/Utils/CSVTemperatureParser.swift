//
//  CSVTemperatureParser.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 12/11/2023.
//

import Foundation

class CSVTemperatureParser {
    private var headers: [String]
    private var data: [String]

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
                        partialResult[current.element] = rowData[current.offset]
                    }

                // Remove items failing decoding
                if let row = try? CookTimelineRow(from: dd) {
                    partialResult.append(row)
                }
            }
    }
}
