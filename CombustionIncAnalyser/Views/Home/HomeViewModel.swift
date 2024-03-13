//
//  HomeViewModel.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 21/11/2023.
//

import Factory
import FirebaseStorage
import Foundation
import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var isFileImporterVisible = false
    
    @Published var file: FileType? = nil
    
    @Injected(\.authService) private var authService: AuthService
    @Injected(\.cloudService) private var cloudService: CloudService
    
    var csvOutput: String {
        file?.output ?? ""
    }
    
    /// Filter out CSV rows which contain notes
    var notes: [CookTimelineRow] {
        (file?.data ?? []).filter {
            $0.notes?.isEmpty == false
        }
    }
    
    /// Opens the file picker
    func didTapOpenFilepicker() {
        isFileImporterVisible = true
    }
    
    /// Called when a file was selected using the file picker
    /// - Parameter fileURL: The selected filesystem file URL
    func didSelect(fileURL: URL) {
        // Stop accessing the file URL, if opening another file
        if let file = file as? LocalFile {
            file.unload()
        }
        
        self.file = LocalFile(fileURL: fileURL)
    }
    
    func didAddAnnotation(sequenceNumber: Int, text: String) {
        file?.didAddAnnotation(sequenceNumber: sequenceNumber, text: text)
    }
    
    func didRemoveAnnotation(sequenceNumber: Int) {
        file?.didRemoveAnnotation(sequenceNumber: sequenceNumber)
    }
    
    func didTapSaveLocally() {
        guard let file = file as? LocalFile else {
            return
        }

        do {
            try csvOutput.write(to: file.fileURL, atomically: false, encoding: .utf8)
        } catch {
            print(error.localizedDescription)
        }
    }
}
