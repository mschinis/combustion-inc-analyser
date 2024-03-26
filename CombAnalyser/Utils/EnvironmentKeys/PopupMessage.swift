//
//  PopupMessage.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 19/11/2023.
//

import Foundation
import SwiftUI

struct PopupMessageKey: EnvironmentKey {
    static let defaultValue: Binding<PopupMessage?> = .constant(nil)
}

extension EnvironmentValues {
    var popupMessage: Binding<PopupMessage?> {
        get { self[PopupMessageKey.self] }
        set { self[PopupMessageKey.self] = newValue }
    }
}
