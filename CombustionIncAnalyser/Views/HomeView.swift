//
//  HomeView.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 11/11/2023.
//

import SwiftUI
import Charts

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
            self.didSelect(file: url)
        }
    }

    func didSelect(file: URL) {
        do {
            self.selectedFileURL = file

            let contents = (try String(contentsOf: file))
                // Some CSV exports contain "\r\n" for each new CSV line, while others contain just "\n".
                // Replace all the \r\n occurences with a "\n" which is a more widely accepted format.
                .replacingOccurrences(of: "\r\n", with: "\n")

            // Separate cook information from the remaining temperature data
            let fileSegments = contents.split(separator: "\n\n").map { String($0) }
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

    @State private var noteHoveredTimestamp: Double? = nil
    @State private var graphAnnotationRequest: GraphAnnotationRequest? = nil
    @State private var areNotesVisible = true
    
    @Environment(\.isSettingsVisible) private var isSettingsVisible: Binding<Bool>
    
    @AppStorage(AppSettingsKeys.enabledCurves.rawValue) private var enabledCurves: AppSettingsEnabledCurves = .defaults

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
    
    func didTapOpenSettings() {
        isSettingsVisible.wrappedValue = false
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
        GraphView(
            enabledCurves: enabledCurves,
            data: viewModel.data,
            notes: viewModel.notes,
            noteHoveredTimestamp: $noteHoveredTimestamp,
            graphAnnotationRequest: $graphAnnotationRequest
        )
        .padding()
    }

    var notesView: some View {
        NotesView(
            notes: viewModel.notes,
            noteHoveredTimestamp: $noteHoveredTimestamp,
            graphAnnotationRequest: $graphAnnotationRequest,
            didTapRemoveAnnotation: viewModel.didRemoveAnnotation(sequenceNumber:)
        )
        .frame(width: areNotesVisible ? 300 : 0)
        .opacity(areNotesVisible ? 1 : 0)
    }

    var body: some View {
        ZStack {
            if viewModel.data.isEmpty {
                SelectFileScreen(
                    didSelectFile: viewModel.didSelect(file:),
                    didTapOpenFilePicker: viewModel.didTapOpenFilepicker
                )
            } else {
                HStack(alignment: .top) {
                    chartView

                    notesView
                }
                .csvDropDestination(with: viewModel.didSelect(file:))
            }
        }
        // Annotation Sheet
        .sheet(item: $graphAnnotationRequest, content: { item in
            Form {
                Text("Add new note")

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
        .sheet(isPresented: isSettingsVisible, content: {
            SettingsView()
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
            ToolbarItem(id: "settings", placement: .primaryAction) {
                Button(action: didTapOpenSettings, label: {
                    Image(systemName: "gear")
                })
                .disabled(viewModel.selectedFileURL == nil)
                .help("Open settings")
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
}

#Preview {
    HomeView()
}
