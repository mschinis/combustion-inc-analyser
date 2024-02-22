//
//  LiveProbeView.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 20/02/2024.
//

import Combine
import CombustionBLE
import SwiftUI

class LiveProbeViewModel: ObservableObject {
    @Published var probe: Probe

    private var subscribers: Set<AnyCancellable> = []

    init(probe: Probe) {
        self.probe = probe
    }

    func monitor() {
        probe
            .$currentTemperatures
            .receive(on: DispatchQueue.main)
            .sink { temperatures in
                print("temperatures", temperatures)
            }
            .store(in: &subscribers)
    }
}

struct LiveProbeView: View {
    @StateObject private var viewModel: LiveProbeViewModel

    init(probe: Probe) {
        self._viewModel = StateObject(
            wrappedValue: LiveProbeViewModel(probe: probe)
        )
    }
    
    init(viewModel: LiveProbeViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        List {
            if let virtualSensors = viewModel.probe.virtualSensors,
               let currentTemperatures = viewModel.probe.currentTemperatures {
                Section("lala") {
                    Text("Core: \(virtualSensors.virtualCore.temperatureFrom(currentTemperatures))")
                    Text("Surface: \(virtualSensors.virtualSurface.temperatureFrom(currentTemperatures))")
                    Text("Ambient: \(virtualSensors.virtualAmbient.temperatureFrom(currentTemperatures))")
                }
            }
        }
        .onAppear(perform: {
            viewModel.monitor()
        })
//        Text("\(probe.)")
    }
}

#Preview {
    LiveProbeView(
        viewModel: LiveProbeViewModel(probe: SimulatedProbe())
    )
}
