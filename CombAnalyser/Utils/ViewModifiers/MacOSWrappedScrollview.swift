//
//  MacOSWrappedScrollview.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 29/11/2023.
//

import Foundation
import SwiftUI

struct MacOSWrappedScrollview: ViewModifier {
    func body(content: Content) -> some View {
        #if os(macOS)
        ScrollView {
            content
        }
        #else
        content
        #endif
    }
}

extension View {
    func macWrappedScrollview() -> some View {
        modifier(
            MacOSWrappedScrollview()
        )
    }
}
