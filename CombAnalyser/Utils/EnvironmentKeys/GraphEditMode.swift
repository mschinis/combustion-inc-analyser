//
//  EditGraphMode.swift
//  CombAnalyser
//
//  Created by Michael Schinis on 09/06/2024.
//

import Foundation
import SwiftUI

struct GraphEditMode: EnvironmentKey {
    static let defaultValue: Binding<Bool> = .constant(false)
}

extension EnvironmentValues {
    var isGraphEditMode: Binding<Bool> {
        get { self[GraphEditMode.self] }
        set { self[GraphEditMode.self] = newValue }
    }
}
