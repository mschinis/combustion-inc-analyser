//
//  HomeToolbarContent.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 01/12/2023.
//

import SwiftUI

struct HomeToolbarContent: ToolbarContent {
    var fileURL: URL?
    var shareGraphImage: CGImage
    var didTapUploadFile: () async -> Void
    var didTapSaveFile: () -> Void
    var didTapSettings: () -> Void

    var body: some ToolbarContent {
        #if os(macOS)
        // Show currently open filename at the top on MacOS.
        // On iOS, it looks ugly, so removing it.
        if let fileURL {
            ToolbarItem(placement: .automatic) {
                Text(fileURL.lastPathComponent)
            }
        }
        #endif
        
        ToolbarItem(id: "upload_csv", placement: .primaryAction) {
            AsyncButton(
                systemImageName: "icloud.and.arrow.up",
                action: didTapUploadFile
            )
            .help("Upload file")
        }

        ToolbarItem(id: "save_file", placement: .primaryAction) {
            Button(action: didTapSaveFile, label: {
                Image(systemName: "scribble")
            })
            .help("Save file")
        }

        // Share graph button
        ToolbarItem(id: "share", placement: .primaryAction) {
            ShareLink(
                item: Image(decorative: shareGraphImage, scale: 1),
                preview: SharePreview(
                    "Combustion Inc Analyser Export",
                    image: Image(decorative: shareGraphImage, scale: 1)
                )
            ) {
                Image(systemName: "square.and.arrow.up")
            }
            .help("Share graph")
        }

        // Toggle notes button
        ToolbarItem(id: "settings", placement: .primaryAction) {
            Button(action: didTapSettings, label: {
                Image(systemName: "gear")
            })
            .help("Open settings")
        }

    }
}

#Preview {
    NavigationStack {
        Text("Dummy View")
            .toolbar {
//                HomeToolbarContent()
            }
    }
}
