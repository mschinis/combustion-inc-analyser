//
//  HomeView.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 11/11/2023.
//

import SwiftUI
import Charts

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
    
    @State private var xAxisHoverPosition: Float? = nil

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
                Chart(viewModel.data) {
                    LineMark(
                        x: .value("Timestamp", $0.timestamp),
                        y: .value("Core Temperature", $0.virtualCoreTemperature),
                        series: .value("Core Temperature", "A")
                    )
                    .foregroundStyle(.blue)
                    
                    LineMark(
                        x: .value("Timestamp", $0.timestamp),
                        y: .value("Suface Temperature", $0.virtualSurfaceTemperature),
                        series: .value("Surface Temperature", "B")
                    )
                    .foregroundStyle(.red)
                    
                    LineMark(
                        x: .value("Timestamp", $0.timestamp),
                        y: .value("Ambient Temperature", $0.virtualAmbientTemperature),
                        series: .value("Ambient Temperature", "C")
                    )
                    .foregroundStyle(.yellow)
                    
                    if let xAxisHoverPosition {
                        let hoverPositions = value(x: xAxisHoverPosition)

                        PointMark(
                            x: .value("X", xAxisHoverPosition),
                            y: .value("Y", hoverPositions.core)
                        )
                        .foregroundStyle(.blue)

                        PointMark(
                            x: .value("X", xAxisHoverPosition),
                            y: .value("Y", hoverPositions.surface)
                        )
                        .foregroundStyle(.red)

                        PointMark(
                            x: .value("X", xAxisHoverPosition),
                            y: .value("Y", hoverPositions.ambient)
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
//                                print(
//                                    proxy.value(atX: cGPoint.x, as: Float.self)!
//                                )
//                                let x = proxy.value(atX: cGPoint.x, as: Float.self)!
//                                self.hoverPoint = Point(
//                                    x: x,
//                                    y: value(x: x).core
//                                )
                                self.xAxisHoverPosition = proxy.value(atX: cGPoint.x, as: Float.self)
                            case .ended:
                                self.xAxisHoverPosition = nil
                            }
                        }
                }
            }
        }
        .padding()
        .toolbar {
            if let selectedFileURL {
                ToolbarItem(placement: .automatic) {
                    Text(selectedFileURL.lastPathComponent)
                }
            }
            
            ToolbarItem(id: "load", placement: .primaryAction) {
                Button(action: didTapOpenFilepicker, label: {
                    Image(systemName: "filemenu.and.cursorarrow")
                })
            }
        }
    }
    
    func value(x: Float) -> (core: Float, surface: Float, ambient: Float) {
        let closestValue = Double(round(x / 5) * 5)
        
        let row = viewModel.data.first { row in
            row.timestamp == closestValue
        }

        return (
            core: row?.estimatedCoreTemperature ?? 0,
            surface: row?.virtualSurfaceTemperature ?? 0,
            ambient: row?.virtualAmbientTemperature ?? 0
        )
    }
}

#Preview {
    HomeView()
}
