//
//  CloudService.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 13/12/2023.
//

import Combine
import Factory
import FirebaseFirestore
import FirebaseStorage
import Foundation

enum CloudServiceError: Error {
    case noFileSelected
    case dataCannotBeCreated
    case failedDeserializingCSV
}

class CloudService: ObservableObject {
    struct DownloadResponse {
        let record: CloudRecord
        let csv: String
    }

    // Combine subject storing the available records right now
    private var cloudRecordsSubject: CurrentValueSubject<[CloudRecord]?, Error> = .init(nil)
    private(set) lazy var publisher = cloudRecordsSubject.eraseToAnyPublisher()
    
    @Injected(\.authService) private var authService: AuthService
    
    func findUserRecords() async throws -> [CloudRecord] {
        guard let user = authService.user else {
            throw AuthError.notLoggedIn
        }

        return try await find(by: user.uid)
    }

    /// Finds all cloud records for this user
    /// - Parameter userId: The user id to retrieve the records for
    /// - Returns: The list of cloud records
    func find(by userId: String) async throws -> [CloudRecord] {
        let db = Firestore.firestore()
        
        let result = try await db.collection("cooks").whereField("userId", isEqualTo: userId).order(by: "updatedAt", descending: true).getDocuments()
        let documents = result.documents.compactMap { snapshot in
            try? snapshot.data(as: CloudRecord.self)
        }

        // Update publisher
        cloudRecordsSubject.send(documents)

        return documents
    }
    
    func download(record: CloudRecord) async throws -> DownloadResponse {
        let storage = Storage.storage()
        let fileRef = storage.reference(withPath: record.filePath)
        
        
        // 2mb maximum file size
        let data = try await withCheckedThrowingContinuation { continuation in
            fileRef.getData(maxSize: 2 * 1024 * 1024) { result in
                continuation.resume(with: result)
            }
        }
        
        guard let str = String(data: data, encoding: .utf8) else {
            throw CloudServiceError.failedDeserializingCSV
        }
        
        return DownloadResponse(record: record, csv: str)
    }
    
    /// Creates/Updates the cook cloud record, and uploads the related CSV document
    ///
    /// - Parameters:
    ///   - data: The record to upload
    ///   - contents: Contents of CSV file
    func upload(data: CloudRecord, contents: String) async throws -> URL {
        try await upload(record: data)
        return try await uploadCSV(filePath: data.filePath, contents: contents)
    }
    
    /// Deletes the cloud record and associated csv data
    /// - Parameter record: The record we wish to delete
    func delete(record: CloudRecord) async throws {
        // Delete record
        let db = Firestore.firestore()
        
        let dbRecord = db.collection("cooks").document(record.uuid.uuidString)
        try await dbRecord.delete()
        
        // Delete associated data
        let storage = Storage.storage()
        let fileRef = storage.reference(withPath: record.filePath)
        
        try await fileRef.delete()
        
        // Update records
        let _ = try await findUserRecords()
    }
    
    /// Handles the uploading of the cloud record
    /// - Parameter record: The cloud record to upload
    private func upload(record: CloudRecord) async throws {
        let db = Firestore.firestore()
        let batch = db.batch()
        
        let dbRecord = db.collection("cooks").document(record.uuid.uuidString)
        try batch.setData(from: record, forDocument: dbRecord)

        try await batch.commit()
    }
    
    /// Handles the uploading of the CSV file
    /// - Parameters:
    ///   - filePath: CSV file path
    ///   - contents: The contents of the CSV
    /// - Returns: The full URL of the uploaded record
    private func uploadCSV(filePath: String, contents: String) async throws -> URL {
        // Build the path to the CSV file
        let storage = Storage.storage()
        let fileRef = storage.reference(withPath: filePath)
        
        // Build the file metadata
        let fileMetadata = StorageMetadata()
        fileMetadata.contentType = "text/csv"

        guard let csvData = contents.data(using: .utf8) else {
            throw CloudServiceError.dataCannotBeCreated
        }

        do {
            let _ = try await fileRef.putDataAsync(csvData, metadata: fileMetadata)
            return try await fileRef.downloadURL()
        } catch {
            throw error
        }
    }
}
