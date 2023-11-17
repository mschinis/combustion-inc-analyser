////
////  SettingsView.swift
////  CombustionIncAnalyser
////
////  Created by Michael Schinis on 14/11/2023.
////
//
import SwiftUI



struct SettingsView: View {
    // Graph Curves
    @AppStorage(AppSettingsKeys.graphsCore.rawValue) private var isGraphsCoreEnabled: Bool = true
    @AppStorage(AppSettingsKeys.graphsSurface.rawValue) private var isGraphsSurfaceEnabled: Bool = true
    @AppStorage(AppSettingsKeys.graphsAmbient.rawValue) private var isGraphsAmbientEnabled: Bool = true
    @AppStorage(AppSettingsKeys.graphsNotes.rawValue) private var isGraphsNotesEnabled: Bool = true
    @AppStorage(AppSettingsKeys.graphsProbeNotInserted.rawValue) private var isGraphsProbeNotInsertedEnabled: Bool = true

    @AppStorage(AppSettingsKeys.enabledCurves.rawValue) private var enabledCurves: AppSettingsEnabledCurves = .defaults

    // Other
    @AppStorage(AppSettingsKeys.performanceMode.rawValue) private var isPerformanceModeEnabled: Bool = true

    var body: some View {
        VStack {
            Text("Settings")
                .font(.title2)

            Form {
                Section {
                    Toggle("Core Temperature", isOn: $enabledCurves.core)
                    Toggle("Surface Temperature", isOn: $enabledCurves.surface)
                    Toggle("Ambient Temperature", isOn: $enabledCurves.ambient)
                } header: {
                    Text("Temperature curves")
                        .bold()
                }

                Spacer().frame(height: 16)

                Section {
                    Toggle("T1 (Tip)", isOn: $enabledCurves.t1)
                    Toggle("T2", isOn: $enabledCurves.t2)
                    Toggle("T3", isOn: $enabledCurves.t3)
                    Toggle("T4", isOn: $enabledCurves.t4)
                    Toggle("T5", isOn: $enabledCurves.t5)
                    Toggle("T6", isOn: $enabledCurves.t6)
                    Toggle("T7", isOn: $enabledCurves.t7)
                    Toggle("T8 (Handle)", isOn: $enabledCurves.t8)
                } header: {
                    Text("Advanced temperature curves")
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
