//
//  HomeView.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 11/11/2023.
//

import SwiftUI
import Charts

struct GraphHoverPosition {
    var x: Float
    
    var sequenceNumber: Int
    
    var core: Float
    var surface: Float
    var ambient: Float
}

class HomeViewModel: ObservableObject {
    @Published var data: [CookTimelineRow] = []

    func didSelect(file: URL) {
        do {
            
            let contents = try String(contentsOf: file)
            
            // Separate cook information from the remaining temperature data
            let fileSegments = contents.split(separator: "\r\n\r\n").map { String($0) }
            let fileInfo = fileSegments[0]
            let temperatureInfo = fileSegments[1]

            data = CSVTemperatureParser(temperatureInfo).parse()
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel

    @State private var selectedFileURL: URL? = nil {
        didSet {
            if let selectedFileURL {
                viewModel.didSelect(file: selectedFileURL)
            }
            
        }
    }
    
    @State private var graphHoverPosition: GraphHoverPosition? = nil

    init() {
        self._viewModel = StateObject(wrappedValue: HomeViewModel())
    }
    
    init(viewModel: HomeViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    

    func didTapOpenFilepicker() {
        let panel = NSOpenPanel()

        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [
            .init(filenameExtension: "csv")!
        ]

        if panel.runModal() == .OK {
            self.selectedFileURL = panel.url
        }
    }

    var body: some View {
        ZStack {
            if viewModel.data.isEmpty {
                Text("Select a file to get started!")
            } else {
                HStack {
                    Chart(viewModel.data) {
                        // Core temperature graph
                        LineMark(
                            x: .value("Timestamp", $0.timestamp),
                            y: .value("Core Temperature", $0.virtualCoreTemperature),
                            series: .value("Core Temperature", "A")
                        )
                        .foregroundStyle(.blue)
                        
                        // Surface temperature graph
                        LineMark(
                            x: .value("Timestamp", $0.timestamp),
                            y: .value("Suface Temperature", $0.virtualSurfaceTemperature),
                            series: .value("Surface Temperature", "B")
                        )
                        .foregroundStyle(.red)
                        
                        // Ambient temperature graph
                        LineMark(
                            x: .value("Timestamp", $0.timestamp),
                            y: .value("Ambient Temperature", $0.virtualAmbientTemperature),
                            series: .value("Ambient Temperature", "C")
                        )
                        .foregroundStyle(.yellow)
                        
                        // Show the points on the graph being hovered over.
                        if let graphHoverPosition {
                            PointMark(
                                x: .value("X", graphHoverPosition.x),
                                y: .value("Y", graphHoverPosition.core)
                            )
                            .foregroundStyle(.blue)

                            PointMark(
                                x: .value("X", graphHoverPosition.x),
                                y: .value("Y", graphHoverPosition.surface)
                            )
                            .foregroundStyle(.red)

                            PointMark(
                                x: .value("X", graphHoverPosition.x),
                                y: .value("Y", graphHoverPosition.ambient)
                            )
                            .foregroundStyle(.yellow)
                        }
                    }
                    .chartForegroundStyleScale([
                        "Core Temperature": Color.blue,
                        "Suface Temperature": Color.red,
                        "Ambient Temperature": Color.yellow
                    ])
                    // Get chart hover
                    .chartOverlay { proxy in
                        Color.clear
                            .onContinuousHover { hoverPhase in
                                switch hoverPhase {
                                case .active(let cGPoint):
                                    let xPosition = proxy.value(atX: cGPoint.x, as: Float.self)!
                                    self.graphHoverPosition = value(x: xPosition)
                                case .ended:
                                    self.graphHoverPosition = nil
                                }
                            }
                    }

                    Form {
                        Toggle(isOn: .constant(true)) {
                            Text("Core temperature")
                        }
                    }
                    .padding(.leading)
                }
            }
        }
        .padding()
        .toolbar {
            // Show currently open filename at the top
            if let selectedFileURL {
                ToolbarItem(placement: .automatic) {
                    Text(selectedFileURL.lastPathComponent)
                }
            }
            
            // Load button
            ToolbarItem(id: "load", placement: .primaryAction) {
                Button(action: didTapOpenFilepicker, label: {
                    Image(systemName: "filemenu.and.cursorarrow")
                })
            }
        }
    }
    
    func value(x: Float) -> GraphHoverPosition? {
        // Round to the closest 5th second, since the data is structured as such
        let closestValue = Double(round(x / 5) * 5)
        
        // Find the temperature data which corresponds to the hovered position on the graph
        let row = viewModel.data.first { row in
            row.timestamp == closestValue
        }

        guard let row else {
            return nil
        }

        return GraphHoverPosition(
            x: x,
            
            sequenceNumber: row.sequenceNumber,

            core: row.estimatedCoreTemperature,
            surface: row.virtualSurfaceTemperature,
            ambient: row.virtualAmbientTemperature
        )
    }
}

#Preview {
    HomeView()
}
