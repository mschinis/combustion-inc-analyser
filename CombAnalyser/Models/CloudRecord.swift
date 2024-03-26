//
//  CloudRecord.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 14/03/2024.
//

import Foundation

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
