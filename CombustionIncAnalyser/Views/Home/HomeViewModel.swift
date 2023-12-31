//
//  HomeViewModel.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 21/11/2023.
//


import Foundation
import SwiftUI

class HomeViewModel: ObservableObject {
    private(set) var fileInfo: String = ""
    private(set) var csvParser: CSVTemperatureParser!

    @Published private(set) var selectedFileURL: URL? = nil
    @Published private(set) var data: [CookTimelineRow] = []
    @Published var isFileImporterVisible = false

    var notes: [CookTimelineRow] {
        data.filter {
            $0.notes?.isEmpty == false
        }
    }

    func didTapOpenFilepicker() {
        isFileImporterVisible = true
    }
    
    /// Ensure the file we're trying to open is already security scoped on macOS.
    /// If it's not security scoped, we request from the filesystem to give us access.
    ///
    /// On iPadOS / iOS, the files are never security scoped, so we request from the fileystem to give us access
    /// - Parameter file: The file being loaded
    /// - Returns: Boolean indicating if the file can be accessed
    func securelyAccess(file: URL) -> Bool {
        #if os(macOS)
        let isSecurityScoped = (try? file.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)) != nil

        return isSecurityScoped ? true : file.startAccessingSecurityScopedResource()
        #else
        return file.startAccessingSecurityScopedResource()
        #endif
    }
    
    func didSelect(file: URL) {
        // Stop accessing the file with security scope, if opening another file
        if let selectedFileURL {
            selectedFileURL.stopAccessingSecurityScopedResource()
        }

        // Load the selected file
        do {
            guard securelyAccess(file: file) else {
                return
            }

            self.selectedFileURL = file

            let contents = (try String(contentsOf: file))
                // Some CSV exports contain "\r\n" for each new CSV line, while others contain just "\n".
                // Replace all the \r\n occurences with a "\n" which is a more widely accepted format.
                .replacingOccurrences(of: "\r\n", with: "\n")

            // Separate cook information from the remaining temperature data
            let fileSegments = contents.split(separator: "\n\n").map { String($0) }
            let fileInfo = fileSegments[0]
            let temperatureInfo = fileSegments[1]

            self.fileInfo = fileInfo
            self.csvParser = CSVTemperatureParser(temperatureInfo)
            self.data = csvParser.parse()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func didAddAnnotation(sequenceNumber: Int, text: String) {
        guard let index = data.firstIndex(where: { $0.sequenceNumber == sequenceNumber }) else {
            return
        }

        var row = data[index]
        row.notes = text

        data[index] = row
    }
    
    func didRemoveAnnotation(sequenceNumber: Int) {
        guard let index = data.firstIndex(where: { $0.sequenceNumber == sequenceNumber }) else {
            return
        }

        var row = data[index]
        row.notes = nil

        data[index] = row
    }
    
    func didTapSave() {
        guard let selectedFileURL else {
            return
        }

        CSVTemperatureExporter(
            url: selectedFileURL,
            fileInfo: fileInfo,
            headers: csvParser.headers,
            data: data
        )
        .save()
    }
}
