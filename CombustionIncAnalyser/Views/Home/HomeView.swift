//
//  HomeView.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 11/11/2023.
//

import SwiftUI
import Charts


struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    
    /// The note being hovered over, at the right side of the sidebar
    @State private var noteHoverPosition: GraphTimelinePosition? = nil
    /// The note being created/edited
    @State private var graphAnnotationRequest: GraphAnnotationRequest? = nil
    /// Controls the visibility of the notes sidebar
    @State private var isNotesSidebarVisible = true
    /// Controls the visibility of the settings sheet
    @Environment(\.isSettingsVisible) private var isSettingsVisible: Binding<Bool>

    @AppStorage(AppSettingsKeys.enabledCurves.rawValue) private var enabledCurves: AppSettingsEnabledCurves = .defaults
    @AppStorage(AppSettingsKeys.temperatureUnit.rawValue) private var temperatureUnit: TemperatureUnit = .celsius
    
    init() {
        self._viewModel = StateObject(wrappedValue: HomeViewModel())
    }
    
    init(viewModel: HomeViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    /// Changes the state of visibility of the notes
    func didTapToggleNotes() {
        withAnimation {
            isNotesSidebarVisible.toggle()
        }
    }
    
    /// Changes the state of the settings view visibility
    func didTapOpenSettings() {
        isSettingsVisible.wrappedValue = true
    }
    
    @MainActor
    /// Generates an image out of the current chart being displayed
    /// - Returns: The generated image
    private func generateGraphSnapshot() -> CGImage? {
        let renderer = ImageRenderer(
            content: chartView
                .background(.white)
                .frame(
                    width: 1920,
                    height: 1080
                )
        )
            
        return renderer.cgImage
    }
    
    /// The chart view being displayed
    var chartView: some View {
        GraphView(
            enabledCurves: enabledCurves,
            temperatureUnit: temperatureUnit,
            
            data: viewModel.data,
            notes: viewModel.notes,
            noteHoverPosition: $noteHoverPosition,
            graphAnnotationRequest: $graphAnnotationRequest
        )
        .padding()
    }
    
    /// The notes sidebar view
    var notesView: some View {
        NotesView(
            notes: viewModel.notes,
            noteHoverPosition: $noteHoverPosition,
            graphAnnotationRequest: $graphAnnotationRequest,
            didTapRemoveAnnotation: viewModel.didRemoveAnnotation(sequenceNumber:)
        )
        .frame(width: isNotesSidebarVisible ? 300 : 0)
        .opacity(isNotesSidebarVisible ? 1 : 0)
    }

    var body: some View {
        ZStack {
            if viewModel.data.isEmpty {
                SelectFileScreen(
                    didSelectFile: viewModel.didSelect(file:),
                    didTapOpenFilePicker: viewModel.didTapOpenFilepicker
                )
            } else {
                ViewThatFits {
                    HStack(alignment: .top) {
                        chartView

                        notesView
                    }
                    .csvDropDestination(with: viewModel.didSelect(file:))
                    
                    VStack(alignment: .leading) {
                        chartView
                        
                        notesView
                    }
                    .csvDropDestination(with: viewModel.didSelect(file:))
                }
            }
        }
        .fileImporter(
            isPresented: $viewModel.isFileImporterVisible,
            
            allowedContentTypes: [
                .init(filenameExtension: "csv")!
            ]
        ) { result in
                switch result {
                case .success(let url):
                    viewModel.didSelect(file: url)
                case .failure(let error):
                    print("Error:: \(error.localizedDescription)")
                }
            }
        // Annotation Sheet
        .sheet(item: $graphAnnotationRequest, content: { item in
            // Make a copy of the annotation request and edit this, so we avoid rerendering the graph unnecessarily
            var graphAnnotationRequestCopy = item
            
            Form {
                Text("Add new note")

                TextEditor(
                    text: Binding(get: {
                        graphAnnotationRequestCopy.note
                    }, set: { newValue in
                        graphAnnotationRequestCopy.note = newValue
                    })
                )
                .frame(width: 300, height: 200)

                HStack {
                    Button("OK", action: {
                        // Update graph
                        viewModel.didAddAnnotation(
                            sequenceNumber: item.sequenceNumber,
                            text: graphAnnotationRequestCopy.note
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
