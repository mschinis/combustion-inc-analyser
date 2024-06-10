//
//  HomeView.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 11/11/2023.
//

import Factory
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
    /// Controls the visibility of the authentication page
    @State private var isAuthVisible: Bool = false
    /// Controls the visibility of the upload prompt
    @State private var uploadPromptData: UploadPromptRequest? = nil
    
    /// Controls whether a popup should be shown or not
    @Environment(\.popupMessage) private var popupMessage: Binding<PopupMessage?>
    
    @Environment(\.openCrossCompatibleWindow) private var openCrossCompatibleWindow
    
    @State private var isGraphEditModeEnabled: Bool = false
    
    @AppStorage(AppSettingsKeys.enabledCurves.rawValue) private var enabledCurves: AppSettingsEnabledCurves = .defaults
    @AppStorage(AppSettingsKeys.temperatureUnit.rawValue) private var temperatureUnit: TemperatureUnit = .celsius
    
    @Injected(\.authService) private var authService: AuthService
    @Injected(\.cloudService) private var cloudService: CloudService
    
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
        openCrossCompatibleWindow(.settings)
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
    /// Callback when the user taps on upload CSV button on the navigation bar
    /// Shows success/error message depending on the result of the operation
    func didTapUploadCSV() async {
        guard
            let user = authService.user,
            let localFile = viewModel.file as? LocalFile
        else {
            isAuthVisible = true
            return
        }
        
        self.uploadPromptData = UploadPromptRequest(
            cloudRecord: CloudRecord(
                userId: user.uid,
                fileName: localFile.fileURL.lastPathComponent
            ),
            csvOutput: viewModel.csvOutput
        )
    }
    
    /// Result callback from file importer.
    ///
    /// - Parameter result: The result of the file importer
    func onFilePickerCompletion(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            viewModel.didSelect(fileURL: url)
        case .failure(let error):
            self.popupMessage.wrappedValue = .init(
                state: .error,
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
            
            data: viewModel.file?.data ?? [],
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
            if viewModel.file == nil {
                // MARK: File picker view
                SelectFileScreen(
                    didSelectFile: viewModel.didSelect(fileURL:),
                    didTapOpenFilePicker: viewModel.didTapOpenFilepicker
                )
            } else {
                // MARK: File selected view
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
                    .csvDropDestination(with: viewModel.didSelect(fileURL:))
                    
                    // Vertical view, when the sidebar doesn't fit side by side.
                    VStack(alignment: .leading) {
                        chartView
                        notesView
                    }
                    .csvDropDestination(with: viewModel.didSelect(fileURL:))
                }
                // MARK: - Selected file toolbar
                .toolbar {
                    #if os(macOS)
                    // Show currently open filename at the top on MacOS.
                    // On iOS, it looks ugly, so removing it.
                    if let windowTitle = viewModel.file?.windowTitle {
                        ToolbarItem(placement: .automatic) {
                            Text(windowTitle)
                        }
                    }
                    #endif

                    // Show Upload CSV file only when it's a local file
                    if viewModel.file is LocalFile {
                        ToolbarItem(id: "upload_csv", placement: .primaryAction) {
                            AsyncButton(
                                systemImageName: "icloud.and.arrow.up",
                                action: didTapUploadCSV
                            )
                            .help("Upload file to cloud")
                        }
                    }
                    
//                    #if os(iOS) || os(visionOS)
//                    if isGraphEditModeEnabled {
//                        ToolbarItem(placement: .bottomBar) {
//                            Button(action: {
//                                isGraphEditModeEnabled = false
//                            }) {
//                                Text("Finished adding notes")
//                            }
//                            .help("Finished adding notes")
//                        }
//                    }
//                    #endif

                    ToolbarItem(placement: .primaryAction) {
                        Menu {
                            // Edit graph / Add notes
                            #if os(iOS) || os(visionOS)
                            Button(action: {
                                isGraphEditModeEnabled.toggle()
                            }) {
                                Label(isGraphEditModeEnabled ? "Finished adding notes" : "Add notes", systemImage: "pencil")
                            }
                            .help(isGraphEditModeEnabled ? "Finished adding notes" : "Add notes")
                            #endif

                            // Open file picker
                            Button(action: {
                                viewModel.didTapOpenFilepicker()
                            }) {
                                Label("Open CSV", systemImage: "folder")
                            }
                            .help("Open CSV file")

                            // Share graph button
                            ShareLink(
                                item: Image(decorative: generateGraphSnapshot()!, scale: 1),
                                preview: SharePreview(
                                    "Combustion Inc Analyser Export",
                                    image: Image(decorative: generateGraphSnapshot()!, scale: 1)
                                )
                            ) {
                                Label("Share graph", systemImage: "square.and.arrow.up")
                            }
                            .help("Share graph")
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
        }
        .environment(\.isGraphEditMode, $isGraphEditModeEnabled)
        // Select file popup
        .fileImporter(
            isPresented: $viewModel.isFileImporterVisible,
            allowedContentTypes: [
                .init(filenameExtension: "csv")!
            ],
            onCompletion: onFilePickerCompletion(_:)
        )
        .sheet(item: $uploadPromptData, content: { item in
            UploadPrompt(
                cloudRecord: item.cloudRecord,
                csvOutput: item.csvOutput
            )
        })
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
        .sheet(isPresented: $isAuthVisible, content: {
            AuthView(
                viewModel: AuthViewModel(
                    authorizationSuccess: { user in
                        isAuthVisible = false
                        popupMessage.wrappedValue = .init(
                            state: .success,
                            title: "Logged in",
                            description: "Try uploading your file again"
                        )
                    },
                    authorizationError: { error in
                        print("Error:: \(error.localizedDescription)")
                    }
                )
            )
        })
    }
}

#Preview {
    HomeView()
}
