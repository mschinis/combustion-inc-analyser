////
////  SettingsView.swift
////  CombustionIncAnalyser
////
////  Created by Michael Schinis on 14/11/2023.
////
//

import Factory
import SwiftUI

struct SettingsView: View {
    // Graph Curves
    @AppStorage(AppSettingsKeys.graphsNotes.rawValue) private var isGraphsNotesEnabled: Bool = true
    @AppStorage(AppSettingsKeys.graphsProbeNotInserted.rawValue) private var isGraphsProbeNotInsertedEnabled: Bool = true

    @AppStorage(AppSettingsKeys.enabledCurves.rawValue) private var enabledCurves: AppSettingsEnabledCurves = .defaults

    // Other
    @AppStorage(AppSettingsKeys.performanceMode.rawValue) private var isPerformanceModeEnabled: Bool = true
    @AppStorage(AppSettingsKeys.temperatureUnit.rawValue) private var temperatureUnit: TemperatureUnit = .celsius

    @State private var isDeleteAccountDialogVisible = false
    
    @Environment(\.dismiss) private var dismiss
    @InjectedObject(\.authService) private var authService: AuthService
    
    var toolbarContent: SettingsSheetToolbar? = nil

    func logout() {
        Task {
            do {
                try authService.logout()
            } catch {
                print("Auth:: Failed logging out")
            }
        }
    }
    
    func didConfirmDeleteAccount() {
        authService.reauthenticateAndDeleteAccount()
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Core Temperature", isOn: $enabledCurves.core)
                    Toggle("Surface Temperature", isOn: $enabledCurves.surface)
                    Toggle("Ambient Temperature", isOn: $enabledCurves.ambient)
                } header: {
                    Text("Temperature curves")
                        .bold()
                }

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
                        .macPadding(.top, 16)
                }
                
                
                Section {
                    Toggle("Show note indicators", isOn: $isGraphsNotesEnabled)
                    Toggle("Highlight probe removal", isOn: $isGraphsProbeNotInsertedEnabled)
                } header: {
                    Text("Graph settings")
                        .bold()
                        .macPadding(.top, 16)
                }
                

                Section {
                    Picker(selection: $temperatureUnit) {
                        ForEach(TemperatureUnit.allCases) { unit in
                            Text(unit.rawValue.capitalized).tag(unit)
                        }
                    } label: {
                        Text("Temperature Unit")
                    }

                    VStack(alignment: .leading) {
                        Toggle("Performance Mode", isOn: $isPerformanceModeEnabled)

                        Text("Recommended, especially for long cooks.")
                            .font(.subheadline)
                            .bold()

                        Text("Performance mode reduces graph resolution\nslightly in order to improve performance.")
                            .font(.subheadline)
                            .fixedSize()
                    }
                } header: {
                    Text("Other")
                        .bold()
                        .macPadding(.top, 16)
                }
                
                if authService.user != nil {
                    Button(role: .destructive) {
                        isDeleteAccountDialogVisible.toggle()
                    } label: {
                        Text("Delete account")
                    }
                    .macPadding(.top, 16)
                }
            }
            .macPadding()
            .macWrappedScrollview()
            .navigationTitle("Settings")
            .macPadding(8)
            .toolbar {
                toolbarContent
            }
        }
        .confirmationDialog("Delete account?", isPresented: $isDeleteAccountDialogVisible) {
            Button("Delete", role: .destructive, action: didConfirmDeleteAccount)
        } message: {
            Text("You'll lose all your stored cooks. We can't recover them once you delete.\n\nYou will first be prompted to login, to authenticate you.")
        }
    }
}

#Preview {
    SettingsView()
}
