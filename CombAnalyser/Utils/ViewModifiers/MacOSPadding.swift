//
//  MacOSPadding.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 29/11/2023.
//

import Foundation
import SwiftUI

struct MacOSPadding: ViewModifier {
    var edges: Edge.Set
    var length: CGFloat?

    func body(content: Content) -> some View {
        content
        #if os(macOS)
        .padding(edges, length)
        #endif
    }
}

extension View {
    func macPadding(_ edges: Edge.Set = .all, _ length: CGFloat? = nil) -> some View {
        modifier(
            MacOSPadding(edges: edges, length: length)
        )
    }
    
    func macPadding(_ length: CGFloat? = nil) -> some View {
        modifier(
            MacOSPadding(edges: .all, length: length)
        )
    }
}
