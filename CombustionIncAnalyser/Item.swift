//
//  Item.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 11/11/2023.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
