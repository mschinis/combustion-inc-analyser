//
//  SettingsVisible.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 19/11/2023.
//

import Foundation
import SwiftUI

struct SettingsVisibleKey: EnvironmentKey {
    static let defaultValue: Binding<Bool> = .constant(false)
}

extension EnvironmentValues {
    var isSettingsVisible: Binding<Bool> {
        get { self[SettingsVisibleKey.self] }
        set { self[SettingsVisibleKey.self] = newValue }
    }
}
