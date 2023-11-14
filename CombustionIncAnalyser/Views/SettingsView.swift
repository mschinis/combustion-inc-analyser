////
////  SettingsView.swift
////  CombustionIncAnalyser
////
////  Created by Michael Schinis on 14/11/2023.
////
//
import SwiftUI

enum AppSettings: String {
    case graphsCore = "graphs.core"
    case graphsSurface = "graphs.surface"
    case graphsAmbient = "graphs.ambient"
    case graphsNotes = "graphs.notes"
}

struct SettingsView: View {
    @AppStorage(AppSettings.graphsCore.rawValue) private var graphsCore: Bool = true
    @AppStorage(AppSettings.graphsSurface.rawValue) private var graphsSurface: Bool = true
    @AppStorage(AppSettings.graphsAmbient.rawValue) private var graphsAmbient: Bool = true
    @AppStorage(AppSettings.graphsNotes.rawValue) private var graphsNotes: Bool = true

    var body: some View {
        Form {
            Section("Graph options") {
                Toggle("Core Temperature", isOn: $graphsCore)
                Toggle("Surface Temperature", isOn: $graphsSurface)
                Toggle("Ambient Temperature", isOn: $graphsAmbient)

                Toggle("Show note indicators", isOn: $graphsNotes)
            }
        }
    }
}

#Preview {
    SettingsView()
}
