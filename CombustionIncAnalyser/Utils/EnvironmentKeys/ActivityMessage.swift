//
//  SettingsVisible.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 19/11/2023.
//

import Foundation
import SwiftUI

struct ActivityMessageKey: EnvironmentKey {
    static let defaultValue: Binding<ActivityStatusMessage?> = .constant(nil)
}

extension EnvironmentValues {
    var activityStatusMessage: Binding<ActivityStatusMessage?> {
        get { self[ActivityMessageKey.self] }
        set { self[ActivityMessageKey.self] = newValue }
    }
}
