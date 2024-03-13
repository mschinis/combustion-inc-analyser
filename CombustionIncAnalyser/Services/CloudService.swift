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
}

struct CloudRecord: Identifiable {
    var id: UUID {
        uuid
    }
    
    var uuid: UUID = UUID()

    var title: String = ""
    var cookingMethod: String = ""
    var cookDetails: String = ""
    
    var shareWithCombustion: Bool = true
    
    var userId: String = ""
    var fileName: String = ""

    var filePath: String {
        "cooks/uploads/\(userId)/\(uuid)/data.csv"
    }

    var updatedAt = Date()
}

extension CloudRecord: Codable {
    enum CodingKeys: CodingKey {
        case uuid, title, cookingMethod, cookDetails, shareWithCombustion, userId, fileName, filePath, updatedAt
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(uuid, forKey: .uuid)
        try container.encode(title, forKey: .title)
        try container.encode(cookingMethod, forKey: .cookingMethod)
        try container.encode(cookDetails, forKey: .cookDetails)
        try container.encode(shareWithCombustion, forKey: .shareWithCombustion)
        try container.encode(userId, forKey: .userId)
        try container.encode(fileName, forKey: .fileName)
        try container.encode(filePath, forKey: .filePath)
        try container.encode(updatedAt, forKey: .updatedAt)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.uuid = try container.decode(UUID.self, forKey: .uuid)
        
        self.title = try container.decode(String.self, forKey: .title)
        self.cookingMethod = try container.decode(String.self, forKey: .cookingMethod)
        self.cookDetails = try container.decode(String.self, forKey: .cookDetails)
        
        self.shareWithCombustion = try container.decode(Bool.self, forKey: .shareWithCombustion)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.fileName = try container.decode(String.self, forKey: .fileName)
        
        self.updatedAt = try container.decode(Date.self, forKey: .updatedAt)
    }
}

class CloudService: ObservableObject {
    enum ListError: Error {
        case notLoggedIn
    }

    // Combine subject storing the available records right now
    private var cloudRecordsSubject: CurrentValueSubject<[CloudRecord]?, Error> = .init(nil)
    private(set) lazy var publisher = cloudRecordsSubject.eraseToAnyPublisher()
    
    @Injected(\.authService) private var authService: AuthService
    
    func findUserRecords() async throws -> [CloudRecord] {
        guard let user = authService.user else {
            throw ListError.notLoggedIn
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
    
    func download(record: CloudRecord) async throws {
        let storage = Storage.storage()
        let fileRef = storage.reference(withPath: record.filePath)
        
        
        // 2mb maximum file size
        let data = try await withCheckedThrowingContinuation { continuation in
            fileRef.getData(maxSize: 2 * 1024 * 1024) { result in
                continuation.resume(with: result)
            }
        }
        
        let str = String(data: data, encoding: .utf8)
        print("URL: \(record.filePath)")
        print("str", str)
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
//        self.uploadFileLoadingState = .idle
        
//        guard let selectedFileURL else {
//            throw CSVUploadError.noFileSelected
//        }

        // Build the path to the CSV file
        let storage = Storage.storage()
        let fileRef = storage.reference(withPath: filePath)
        
        // Build the file metadata
        let fileMetadata = StorageMetadata()
        fileMetadata.contentType = "text/csv"

        guard let csvData = contents.data(using: .utf8) else {
            throw CloudServiceError.dataCannotBeCreated
        }

//        self.uploadFileLoadingState = .loading

        do {
            let _ = try await fileRef.putDataAsync(csvData, metadata: fileMetadata)
            return try await fileRef.downloadURL()

//            Pasteboard.general.set(string: url.absoluteString)
            // Update loading state
//            self.uploadFileLoadingState = .success(url)
        } catch {
//            self.uploadFileLoadingState = .failed(error)
            throw error
        }
    }
}
