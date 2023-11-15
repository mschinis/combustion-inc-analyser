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
    case graphsProbeNotInserted = "graphs.probeNotInserted"

    case performanceMode = "performance.mode"
}

struct SettingsView: View {
    // Graph Curves
    @AppStorage(AppSettings.graphsCore.rawValue) private var isGraphsCoreEnabled: Bool = true
    @AppStorage(AppSettings.graphsSurface.rawValue) private var isGraphsSurfaceEnabled: Bool = true
    @AppStorage(AppSettings.graphsAmbient.rawValue) private var isGraphsAmbientEnabled: Bool = true
    @AppStorage(AppSettings.graphsNotes.rawValue) private var isGraphsNotesEnabled: Bool = true
    @AppStorage(AppSettings.graphsProbeNotInserted.rawValue) private var isGraphsProbeNotInsertedEnabled: Bool = true
    
    // Other
    @AppStorage(AppSettings.performanceMode.rawValue) private var isPerformanceModeEnabled: Bool = true

    var body: some View {
        VStack {
            Text("Settings")
                .font(.title2)

            Form {
                Section {
                    Toggle("Core Temperature", isOn: $isGraphsCoreEnabled)
                    Toggle("Surface Temperature", isOn: $isGraphsSurfaceEnabled)
                    Toggle("Ambient Temperature", isOn: $isGraphsAmbientEnabled)
                } header: {
                    Text("Temperature curves")
                        .bold()
                }

                Spacer().frame(height: 16)
                
                Section {
                    Toggle("Show note indicators", isOn: $isGraphsNotesEnabled)
                    Toggle("Highlight probe removal", isOn: $isGraphsProbeNotInsertedEnabled)
                } header: {
                    Text("Graph settings")
                        .bold()
                }

                Spacer().frame(height: 16)

                Section {
                    Toggle("Performance Mode", isOn: $isPerformanceModeEnabled)

                    Text("Recommended, especially for long cooks.")
                        .font(.subheadline)
                        .bold()

                    Text("Performance mode reduces graph resolution\nslightly in order to improve performance.")
                        .font(.subheadline)
                } header: {
                    Text("Other")
                        .bold()
                }
            }
            .padding(8)
        }
        .padding()
    }
}

#Preview {
    SettingsView()
}
