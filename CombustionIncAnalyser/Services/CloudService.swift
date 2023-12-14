//
//  CloudService.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 13/12/2023.
//

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

    var typeOfCook: String = ""
    var cookingMethod: String = ""
    var cookDetails: String = ""
    
    var shareWithCombustion: Bool = true
    
    var userId: String = ""
    var fileName: String = ""

    var filePath: String {
        "uploads/\(userId)/\(uuid)/data.csv"
    }

    var updatedAt = Date()
}

extension CloudRecord: Codable {
    enum CodingKeys: CodingKey {
        case uuid, typeOfCook, cookingMethod, cookDetails, shareWithCombustion, userId, fileName, filePath, updatedAt
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(uuid, forKey: .uuid)
        try container.encode(typeOfCook, forKey: .typeOfCook)
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
        
        self.typeOfCook = try container.decode(String.self, forKey: .typeOfCook)
        self.cookingMethod = try container.decode(String.self, forKey: .cookingMethod)
        self.cookDetails = try container.decode(String.self, forKey: .cookDetails)
        
        self.shareWithCombustion = try container.decode(Bool.self, forKey: .shareWithCombustion)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.fileName = try container.decode(String.self, forKey: .fileName)
        
        self.updatedAt = try container.decode(Date.self, forKey: .updatedAt)
    }
}

class CloudService: ObservableObject {
    
//    @Published private(set) var uploadFileLoadingState: LoadingState<URL> = .idle
    
    func find(by userId: String) async throws -> [CloudRecord] {
        let db = Firestore.firestore()
        
        let result = try await db.collection("cooks").whereField("userId", isEqualTo: userId).order(by: "updatedAt", descending: true).getDocuments()
        let documents = result.documents.compactMap { snapshot in
            try? snapshot.data(as: CloudRecord.self)
        }
        
        return documents
    }
    
    /// Creates/Updates the cook cloud record, and uploads the related CSV document
    ///
    /// - Parameters:
    ///   - data: <#data description#>
    ///   - contents: <#contents description#>
    func upload(data: CloudRecord, contents: String) async throws {
        try await upload(record: data)
        let _ = try await uploadCSV(filePath: data.filePath, contents: contents)
    }
    
    private func upload(record: CloudRecord) async throws {
        let db = Firestore.firestore()
        let batch = db.batch()
        
        let dbRecord = db.collection("cooks").document(record.uuid.uuidString)
        try batch.setData(from: record, forDocument: dbRecord)

        try await batch.commit()
        
    }
    
    private func uploadCSV(filePath: String, contents: String) async throws -> URL {
//        self.uploadFileLoadingState = .idle
        
//        guard let selectedFileURL else {
//            throw CSVUploadError.noFileSelected
//        }

        // Build the path to the CSV file
        let storage = Storage.storage()
        let root = storage.reference(withPath: "cooks")
        let fileRef = root.child(filePath)
        
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
