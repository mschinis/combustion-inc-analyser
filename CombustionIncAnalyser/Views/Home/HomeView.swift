//
//  HomeView.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 11/11/2023.
//

import FirebaseAuth
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
    
    @Environment(\.activityStatusMessage) private var activityStatusMessage: Binding<ActivityStatusMessage?>

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
    
    @MainActor
    /// Callback when the user taps on upload CSV button.
    /// Shows success/error message depending on the result of the operation
    func didTapUploadCSV() async {
        do {
            let _ = try await viewModel.uploadCSVFile()

            activityStatusMessage.wrappedValue = .init(
                state: .success,
                title: "File uploaded",
                description: "Link copied to clipboard"
            )
        } catch {
            activityStatusMessage.wrappedValue = .init(
                state: .success,
                title: "File uploaded",
                description: "Link copied to clipboard"
            )
        }
    }
    
    /// Result callback from file importer.
    ///
    /// - Parameter result: The result of the file importer
    func onFilePickerCompletion(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            viewModel.didSelect(file: url)
        case .failure(let error):
            self.activityStatusMessage.wrappedValue = .init(
                state: .failed,
                title: "Error loading file",
                description: error.localizedDescription
            )
        }
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
        .opacity(isNotesSidebarVisible ? 1 : 0)
    }

    var body: some View {
        NavigationStack {
            if viewModel.data.isEmpty {
                SelectFileScreen(
                    didSelectFile: viewModel.didSelect(file:),
                    didTapOpenFilePicker: viewModel.didTapOpenFilepicker
                )
            } else {
                ViewThatFits {
                    // Horizontal View
                    HStack(alignment: .top) {
                        chartView
                        // The minimum width, forces the notes to wrap underneath the chart,
                        // when the window is small on MacOS, or on iPad portrait mode
                        // On iPhone, remove the minimum width.
                        #if os(macOS)
                        .frame(minWidth: 700)
                        #else
                        .frame(minWidth: UIDevice.current.userInterfaceIdiom == .phone ? nil : 700)
                        #endif

                        notesView
                            .frame(width: 350)
                    }
                    .csvDropDestination(with: viewModel.didSelect(file:))

                    // Vertical view, when the sidebar doesn't fit side by side.
                    VStack(alignment: .leading) {
                        chartView
                        notesView
                    }
                    .csvDropDestination(with: viewModel.didSelect(file:))
                }
                .toolbar {
                    HomeToolbarContent(
                        fileURL: viewModel.selectedFileURL,
                        shareGraphImage: generateGraphSnapshot()!,
                        didTapUploadFile: didTapUploadCSV,
                        didTapSaveFile: viewModel.didTapSave,
                        didTapSettings: didTapOpenSettings
                    )
                }
            }
        }
        // Select file popup
        .fileImporter(
            isPresented: $viewModel.isFileImporterVisible,
            allowedContentTypes: [
                .init(filenameExtension: "csv")!
            ],
            onCompletion: onFilePickerCompletion(_:)
        )
        // Create/Edit Annotation sheet
        .sheet(item: $graphAnnotationRequest, content: { item in
            GraphAnnotationView(
                annotationRequest: item,
                didSubmit: viewModel.didAddAnnotation(sequenceNumber:text:),
                didDismiss: {
                    self.graphAnnotationRequest = nil
                }
            )
        })
        // Settings sheet
        .sheet(isPresented: isSettingsVisible, content: {
            SettingsView()
        })
    }
}

#Preview {
    HomeView()
}
