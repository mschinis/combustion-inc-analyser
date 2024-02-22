//
//  LiveView.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 20/02/2024.
//

import Combine
import CombustionBLE
import SwiftUI

class LiveViewModel: ObservableObject {
    @Published var deviceManager = DeviceManager.shared
    
    @Published var otherDevices: [Device] = []
    @Published var probes: [Probe] = []

    private var subscribers: Set<AnyCancellable> = []
    
    func start() {
        deviceManager.initBluetooth()
        
        deviceManager
            .$devices
            .receive(on: DispatchQueue.main)
            .sink { devices in
                let probes = devices.values
                    .filter { $0 is Probe }
                    .map { $0 as! Probe }
                let otherDevices = devices.values.filter { device in
                    !(device is Probe)
                }

                self.probes = Array(probes)
                self.otherDevices = Array(otherDevices)
            }
            .store(in: &subscribers)
    }
}

struct LiveView: View {
    @StateObject private var viewModel: LiveViewModel

    init() {
        self._viewModel = StateObject(wrappedValue: LiveViewModel())
    }

    init(viewModel: LiveViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            List {
                if !viewModel.probes.isEmpty {
                    Section("Probes") {
                        ForEach(viewModel.probes, id: \.self) { device in
                            NavigationLink(
                            destination: {
                                LiveProbeView(probe: device)
                            }) {
                                Text(device.name)
                            }
                        }
                    }
                }

                if !viewModel.otherDevices.isEmpty {
                    Section("Other devices") {
                        ForEach(viewModel.otherDevices, id: \.self) { device in
                            Text(device.uniqueIdentifier)
                        }
                    }
                }
            }
            .navigationTitle("Devices")
        }
        .onAppear(perform: {
            viewModel.start()
        })
    }
}

#Preview {
    LiveView()
}
