//
//  Pasteboard.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 30/11/2023.
//

import Foundation
import SwiftUI

/// A cross-platform Pasteboard abstraction, which works for both MacOS and iOS.
class Pasteboard {
    init() {}

    static let general = Pasteboard()
    
    func set(string: String) {
        #if os(macOS)
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(string, forType: .string)
        #else
        let pasteboard = UIPasteboard.general
        pasteboard.string = string
        #endif
    }
}
