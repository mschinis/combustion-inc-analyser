//
//  FileType.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 13/03/2024.
//

import Foundation

protocol FileType {
    /// The title of the window, to show on MacOS
    var windowTitle: String { get }
    /// The non-csv header information, containing info about the cook, etc
    var fileInfo: String { get set }
    /// The CSV file headers
    var headers: [String] { get set }
    /// The underlying parsed data
    var data: [CookTimelineRow] { get set }
    /// The serialised CSV output
    var output: String { get }
    
    /// Adds a new note annotation to the data
    ///
    /// - Parameters:
    ///   - sequenceNumber: Position to place the info
    ///   - text: The note text info
    mutating func didAddAnnotation(sequenceNumber: Int, text: String)
    /// Removes a note annotation from data
    /// - Parameter sequenceNumber: Position of the note to remove
    mutating func didRemoveAnnotation(sequenceNumber: Int)
    
    mutating func parseAndUpdate(csv: String)
}

extension FileType {
    /// The serialised CSV output
    var output: String {
        CSVTemperatureSerializer(fileInfo: fileInfo, headers: headers, data: data).output()
    }
    
    /// Adds a new note annotation to the data
    ///
    /// - Parameters:
    ///   - sequenceNumber: Position to place the info
    ///   - text: The note text info
    mutating func didAddAnnotation(sequenceNumber: Int, text: String) {
        guard
            let index = data.firstIndex(where: { $0.sequenceNumber == sequenceNumber })
        else {
            return
        }

        var row = data[index]
        row.notes = text

        data[index] = row
    }
    
    /// Removes a note annotation from data
    /// - Parameter sequenceNumber: Position of the note to remove
    mutating func didRemoveAnnotation(sequenceNumber: Int) {
        guard
            let index = data.firstIndex(where: { $0.sequenceNumber == sequenceNumber })
        else {
            return
        }

        var row = data[index]
        row.notes = nil

        data[index] = row
    }
    
    mutating func parseAndUpdate(csv: String) {
        // Some CSV exports contain "\r\n" for each new CSV line, while others contain just "\n".
        // Replace all the \r\n occurences with a "\n" which is a more widely accepted format.
        let sanitizedCSV = csv.replacingOccurrences(of: "\r\n", with: "\n")

        // Separate cook information from the remaining temperature data
        let fileSegments = sanitizedCSV.split(separator: "\n\n").map { String($0) }
        let fileInfo = fileSegments[0]
        let temperatureInfo = fileSegments[1]
        
        let parser = CSVTemperatureParser(temperatureInfo)
        
        self.fileInfo = fileInfo
        self.headers = parser.headers
        self.data = parser.parse()
    }
}
