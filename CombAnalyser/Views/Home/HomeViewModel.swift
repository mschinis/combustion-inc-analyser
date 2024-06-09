//
//  HomeViewModel.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 21/11/2023.
//

import Combine
import Factory
import FirebaseStorage
import Foundation
import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    @Published var isFileImporterVisible = false
    
    @Published var file: FileType? = nil
    
    @Injected(\.authService) private var authService: AuthService
    @Injected(\.cloudService) private var cloudService: CloudService
    
    private var autosaveListeners: Set<AnyCancellable> = []
    
    var csvOutput: String {
        file?.output ?? ""
    }
    
    /// Filter out CSV rows which contain notes
    var notes: [CookTimelineRow] {
        (file?.data ?? []).filter {
            $0.notes?.isEmpty == false
        }
    }
    
    func update(file: FileType) {
        // Remove auto save listeners
        autosaveListeners.removeAll()
        
        // Update file
        self.file = file

        // Add new auto save listener
        $file
            .dropFirst() // Don't save trigger autosave on first load
            .compactMap { $0 } // Unwrap optional
            .sink { [weak self] data in
                Task {
                    await self?.didTapSave()
                }
            }
            .store(in: &autosaveListeners)
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
        
        self.update(
            file: LocalFile(fileURL: fileURL)
        )
    }
    
    /// Loads remote cloud record and associated CSV contents
    ///
    /// - Parameter record: The record to load
    func didSelectRemote(record: CloudRecord) async {
        do {
            let response = try await cloudService.download(record: record)
            
            self.update(
                file: CloudFile(cloudRecord: response.record, csv: response.csv)
            )
        } catch {
            print("Error", error)
        }
    }
    
    /// Adds a note annotation to the associated loaded file
    /// - Parameters:
    ///   - sequenceNumber: The position to store the note
    ///   - text: The note to add
    func didAddAnnotation(sequenceNumber: Int, text: String) {
        file?.didAddAnnotation(sequenceNumber: sequenceNumber, text: text)
    }
    
    /// Removes a note annotation from the associated loaded file
    /// - Parameter sequenceNumber: The position of the note
    func didRemoveAnnotation(sequenceNumber: Int) {
        file?.didRemoveAnnotation(sequenceNumber: sequenceNumber)
    }
    
    /// Saves file to the local filesystem
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
    
    func didTapSaveRemote() async {
        guard let file = file as? CloudFile else {
            return
        }
        
        do {
            let _ = try await cloudService.upload(data: file.cloudRecord, contents: file.output)
            print("Upload:: Success")
        } catch {
            print("Upload:: Error")
        }
    }
    
    func didTapSave() async {
        switch file {
        case is LocalFile:
            didTapSaveLocally()
        case is CloudFile:
            await didTapSaveRemote()
        default:
            fatalError("Unsupported file being saved")
        }
    }
}
