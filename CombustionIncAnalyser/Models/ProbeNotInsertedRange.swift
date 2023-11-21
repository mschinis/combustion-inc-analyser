//
//  ProbeNotInsertedRange.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 21/11/2023.
//

import Foundation

struct ProbeNotInsertedRange: Identifiable {
    var id: String {
        "\(lower)_\(upper)"
    }
    
    var lower: Double
    var upper: Double
}
