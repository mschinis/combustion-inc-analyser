//
//  LocalFile.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 13/03/2024.
//

import Foundation

struct LocalFile: FileType {
    var windowTitle: String {
        fileURL.lastPathComponent
    }
    
    /// Filesystem file URL
    var fileURL: URL
    
    var fileInfo: String = ""
    var headers: [String] = []
    var data: [CookTimelineRow] = []
    
    init(fileURL: URL) {
        // Initialise instance variables
        self.fileURL = fileURL

        // Load the selected file
        do {
            guard securelyAccess(file: fileURL) else {
                return
            }

            let contents = (try String(contentsOf: fileURL))
                // Some CSV exports contain "\r\n" for each new CSV line, while others contain just "\n".
                // Replace all the \r\n occurences with a "\n" which is a more widely accepted format.
                .replacingOccurrences(of: "\r\n", with: "\n")

            // Separate cook information from the remaining temperature data
            let fileSegments = contents.split(separator: "\n\n").map { String($0) }
            let fileInfo = fileSegments[0]
            let temperatureInfo = fileSegments[1]
            
            let parser = CSVTemperatureParser(temperatureInfo)
            
            self.fileInfo = fileInfo
            self.headers = parser.headers
            self.data = parser.parse()
        } catch {
            print(error.localizedDescription)
        }
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
    
    /// Stops accessing the security scope of this file, when we are done with this resource
    func unload() {
        fileURL.stopAccessingSecurityScopedResource()
    }
}
