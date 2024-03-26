//
//  TemperatureUnit.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 19/11/2023.
//

import Foundation

enum TemperatureUnit: String, Codable, Identifiable, CaseIterable {
    var id: String {
        rawValue
    }

    case celsius, fahrenheit
}

//extension TemperatureUnit: Codable {
//    enum CodingKeys: CodingKey {
//        case core, surface, ambient, t1, t2, t3, t4, t5, t6, t7, t8
//    }
//
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(core, forKey: .core)
//        try container.encode(surface, forKey: .surface)
//        try container.encode(ambient, forKey: .ambient)
//        
//        try container.encode(t1, forKey: .t1)
//        try container.encode(t2, forKey: .t2)
//        try container.encode(t3, forKey: .t3)
//        try container.encode(t4, forKey: .t4)
//        try container.encode(t5, forKey: .t5)
//        try container.encode(t6, forKey: .t6)
//        try container.encode(t7, forKey: .t7)
//        try container.encode(t8, forKey: .t8)
//    }
//    
//    init(from decoder: Decoder) throws {
//        let defaults = AppSettingsEnabledCurves.defaults
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//
//        core = try container.decodeIfPresent(Bool.self, forKey: .core) ?? defaults.core
//        surface = try container.decodeIfPresent(Bool.self, forKey: .surface) ?? defaults.surface
//        ambient = try container.decodeIfPresent(Bool.self, forKey: .ambient) ?? defaults.ambient
//        
//        t1 = try container.decodeIfPresent(Bool.self, forKey: .t1) ?? defaults.t1
//        t2 = try container.decodeIfPresent(Bool.self, forKey: .t2) ?? defaults.t2
//        t3 = try container.decodeIfPresent(Bool.self, forKey: .t3) ?? defaults.t3
//        t4 = try container.decodeIfPresent(Bool.self, forKey: .t4) ?? defaults.t4
//        t5 = try container.decodeIfPresent(Bool.self, forKey: .t5) ?? defaults.t5
//        t6 = try container.decodeIfPresent(Bool.self, forKey: .t6) ?? defaults.t6
//        t7 = try container.decodeIfPresent(Bool.self, forKey: .t7) ?? defaults.t7
//        t8 = try container.decodeIfPresent(Bool.self, forKey: .t8) ?? defaults.t8
//    }
//}
//
//// MARK: - @AppStorage with Codable needs to know how to convert the object from Codable to String and back.
//
//extension AppSettingsEnabledCurves: RawRepresentable {
//    public init?(rawValue: String) {
//        guard let data = rawValue.data(using: .utf8),
//            let result = try? JSONDecoder().decode(AppSettingsEnabledCurves.self, from: data)
//        else {
//            return nil
//        }
//
//        self = result
//    }
//
//    public var rawValue: String {
//        guard let data = try? JSONEncoder().encode(self),
//            let result = String(data: data, encoding: .utf8)
//        else {
//            return "{}"
//        }
//        return result
//    }
//}
