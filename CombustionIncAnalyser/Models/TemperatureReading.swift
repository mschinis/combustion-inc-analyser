//
//  TemperatureReading.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 19/11/2023.
//

import Foundation

struct TemperatureReading {
    var celsius: Float
    var fahrenheit: Float

    init(celsius: Float) {
        self.celsius = celsius
        self.fahrenheit = Self.convert(celsius: celsius)
    }
    
    init(fahrenheit: Float) {
        self.fahrenheit = fahrenheit
        self.celsius = Self.convert(fahrenheit: fahrenheit)
    }
    
    func value(for unit: TemperatureUnit) -> Float {
        switch unit {
        case .celsius: return celsius
        case .fahrenheit: return fahrenheit
        }
    }
    
    static func convert(celsius: Float) -> Float {
        celsius * 9/5 + 32
    }
    
    static func convert(fahrenheit: Float) -> Float {
        (fahrenheit - 32) * 5/9
    }
}

extension TemperatureReading: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        let celsius = try container.decode(Float.self)
        
        self.celsius = celsius
        self.fahrenheit = Self.convert(celsius: celsius)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        try container.encode(self.celsius)
    }
}
