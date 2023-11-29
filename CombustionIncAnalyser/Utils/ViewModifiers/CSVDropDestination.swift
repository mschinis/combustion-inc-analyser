//
//  CSVDropDestination.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 17/11/2023.
//

import Foundation
import SwiftUI

struct CSVDropDestination: ViewModifier {
    var didDropCSVFile: (URL) -> Void

    func body(content: Content) -> some View {
        content
        // For some reason iOS/iPadOS returns the actual contents of the file, when working with a droppable area
        // so disabling this functionality on iOS/iPadOS
        .dropDestination(for: URL.self) { items, location in
            if let fileURL = items.first, fileURL.absoluteString.hasSuffix(".csv") {
                didDropCSVFile(fileURL)
                return true
            } else {
                return false
            }
        }
    }
}

extension View {
    func csvDropDestination(with callback: @escaping (URL) -> Void) -> some View {
        modifier(
            CSVDropDestination(didDropCSVFile: callback)
        )
    }
}
