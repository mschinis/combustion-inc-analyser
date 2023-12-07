//
//  OpenCrossCompatibleWindow.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 19/11/2023.
//

import Foundation
import SwiftUI

enum CrossCompatibleWindow: String {
    case settings
}

typealias OpenCrossCompatibleWindowType = (CrossCompatibleWindow) -> Void

struct OpenCrossCompatibleWindowKey: EnvironmentKey {
    static let defaultValue: OpenCrossCompatibleWindowType = { _ in }
}

extension EnvironmentValues {
    var openCrossCompatibleWindow: OpenCrossCompatibleWindowType {
        get { self[OpenCrossCompatibleWindowKey.self] }
        set { self[OpenCrossCompatibleWindowKey.self] = newValue }
    }
}
