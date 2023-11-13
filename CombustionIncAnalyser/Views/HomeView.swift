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

struct GraphAnnotationRequest: Identifiable {
    var id: Int {
        sequenceNumber
    }

    var sequenceNumber: Int
    var text: String = ""
}

class HomeViewModel: ObservableObject {
    private(set) var fileInfo: String = ""
    private(set) var csvParser: CSVTemperatureParser!

    @Published private(set) var selectedFileURL: URL? = nil
    @Published private(set) var data: [CookTimelineRow] = []
    
    var notes: [CookTimelineRow] {
        data.filter {
            $0.notes?.isEmpty == false
        }
    }

    func didTapOpenFilepicker() {
        let panel = NSOpenPanel()

        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [
            .init(filenameExtension: "csv")!
        ]

        if panel.runModal() == .OK, let url = panel.url {
            self.selectedFileURL = url
            self.didSelect(file: url)
        }
    }

    func didSelect(file: URL) {
        do {
            
            let contents = try String(contentsOf: file)
            
            // Separate cook information from the remaining temperature data
            let fileSegments = contents.split(separator: "\r\n\r\n").map { String($0) }
            let fileInfo = fileSegments[0]
            let temperatureInfo = fileSegments[1]

            self.fileInfo = fileInfo
            self.csvParser = CSVTemperatureParser(temperatureInfo)
            self.data = csvParser.parse()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func didAddAnnotation(sequenceNumber: Int, text: String) {
        guard let index = data.firstIndex(where: { $0.sequenceNumber == sequenceNumber }) else {
            return
        }

        var row = data[index]
        row.notes = text

        data[index] = row
    }
    
    func didRemoveAnnotation(sequenceNumber: Int) {
        guard let index = data.firstIndex(where: { $0.sequenceNumber == sequenceNumber }) else {
            return
        }

        var row = data[index]
        row.notes = nil

        data[index] = row
    }
    
    func didTapSave() {
        guard let selectedFileURL else {
            return
        }

        CSVTemperatureExporter(
            url: selectedFileURL,
            fileInfo: fileInfo,
            headers: csvParser.headers,
            data: data
        )
        .save()
    }
}

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel

    @State private var graphHoverPosition: GraphHoverPosition? = nil

    @State private var graphAnnotationRequest: GraphAnnotationRequest? = nil
    @State private var areNotesVisible = true

    init() {
        self._viewModel = StateObject(wrappedValue: HomeViewModel())
    }
    
    init(viewModel: HomeViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    func didTapToggleNotes() {
        withAnimation {
            areNotesVisible.toggle()
        }
    }
    
    @MainActor
    private func generateGraphSnapshot() -> CGImage? {
        let renderer = ImageRenderer(
            content: chartView
                .background(.white)
                .frame(
                    width: NSScreen.main?.frame.size.width,
                    height: NSScreen.main?.frame.size.height
                )
        )
            
        return renderer.cgImage
    }

    var chartView: some View {
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
            .foregroundStyle(.yellow)
            
            // Ambient temperature graph
            LineMark(
                x: .value("Timestamp", $0.timestamp),
                y: .value("Ambient Temperature", $0.virtualAmbientTemperature),
                series: .value("Ambient Temperature", "C")
            )
            .foregroundStyle(.red)
            
            if let _ = $0.notes {
                PointMark(
                    x: .value("X", $0.timestamp),
                    y: .value("Y", 0)
                )
                .symbol {
                    Image(systemName: "note")
                        .offset(y: -16)
                        .foregroundStyle(.blue)
                }
            }

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
                .foregroundStyle(.yellow)

                PointMark(
                    x: .value("X", graphHoverPosition.x),
                    y: .value("Y", graphHoverPosition.ambient)
                )
                .foregroundStyle(.red)
            }
        }
        .chartForegroundStyleScale([
            "Core Temperature": Color.blue,
            "Suface Temperature": Color.yellow,
            "Ambient Temperature": Color.red
        ])
        // Get mouse position over the graph
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
                .onTapGesture {
                    if let graphHoverPosition {
                        self.graphAnnotationRequest = GraphAnnotationRequest(sequenceNumber: graphHoverPosition.sequenceNumber)
                    }
                }
        }
        .padding()
    }
    
    var notesView: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading) {
                Text("Cook notes")
                    .font(.headline)
                    .padding(.bottom)

                ForEach(viewModel.notes) { row in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(row.timestamp)")
                                .font(.headline)
                            Text(row.notes ?? "")
                            
                            Divider()
                        }

                        Spacer()

                        Button(action: {
                            viewModel.didRemoveAnnotation(sequenceNumber: row.sequenceNumber)
                        }) {
                            Image(systemName: "xmark.bin")
                        }
                    }
                }

                if viewModel.notes.isEmpty {
                    Spacer()

                    Text("No cooking notes added.")
                        .font(.headline)
                    Text("Select a point on the graph to enter a new note!")

                    Spacer()
                }
            }
            .padding()
        }
        .frame(width: areNotesVisible ? 300 : 0)
        .opacity(areNotesVisible ? 1 : 0)
    }
    
    var body: some View {
        ZStack {
            if viewModel.data.isEmpty {
                VStack {
                    Text("Select a file to get started!")
                    
                    Button(action: viewModel.didTapOpenFilepicker, label: {
                        Text("Open Combustion Inc csv")
                    })
                    .padding(.top)
                }
                .padding()
            } else {
                HStack(alignment: .top) {
                    chartView

                    notesView
                }
            }
        }
        // Annotation Sheet
        .sheet(item: $graphAnnotationRequest, content: { item in
            Form {
                Text("Add annotation notes")

                TextEditor(
                    text: Binding(get: {
                        item.text
                    }, set: { newValue in
                        graphAnnotationRequest?.text = newValue
                    })
                )
                .frame(width: 300, height: 200)

                HStack {
                    Button("OK", action: {
                        // Update graph
                        viewModel.didAddAnnotation(
                            sequenceNumber: item.sequenceNumber,
                            text: item.text
                        )
                    
                        // Close the sheet
                        self.graphAnnotationRequest = nil
                    })
                    Button("Cancel", role: .cancel) {
                        self.graphAnnotationRequest = nil
                    }
                }
            }
            .padding()
        })
        .toolbar {
            // Show currently open filename at the top
            if let selectedFileURL = viewModel.selectedFileURL {
                ToolbarItem(placement: .automatic) {
                    Text(selectedFileURL.lastPathComponent)
                }
            }

            ToolbarItem(id: "save_file", placement: .primaryAction) {
                Button(action: viewModel.didTapSave, label: {
                    Image(systemName: "scribble")
                })
                .disabled(viewModel.selectedFileURL == nil)
                .help("Save file")
            }
            
//            Spacer()
//                .padding(.trailing)
            
            // Share graph button
            ToolbarItem(id: "share", placement: .primaryAction) {
                ShareLink(
                    item: Image(decorative: generateGraphSnapshot()!, scale: 1),
                    preview: SharePreview(
                        "Combustion Inc Analyser Export",
                        image: Image(decorative: generateGraphSnapshot()!, scale: 1)
                    )
                ) {
                    Image(systemName: "square.and.arrow.up")
                }
                .disabled(viewModel.selectedFileURL == nil)
                .help("Share graph")
            }

            // Toggle notes button
            ToolbarItem(id: "notes_sidebar", placement: .primaryAction) {
                Button(action: didTapToggleNotes, label: {
                    Image(systemName: "note.text")
                })
                .disabled(viewModel.selectedFileURL == nil)
                .help("Toggle notes sidebar")
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
