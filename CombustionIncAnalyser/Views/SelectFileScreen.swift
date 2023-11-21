//
//  SelectFileScreen.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 15/11/2023.
//

import SwiftUI

struct SelectFileScreen: View {
    /// Callback indicating that a file was selected or drag/dropped
    var didSelectFile: (URL) -> Void
    /// Callback indicating that the user tapped on the UI, to open a file
    var didTapOpenFilePicker: () -> Void

    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(.gray, style: StrokeStyle(lineWidth: 3, dash: [20] ))
            .overlay {
                VStack {
                    Image(systemName: "tray.and.arrow.down")
                        .font(
                            .system(size: 50)
                        )
                        .padding(.bottom)
                    
                    Text("**Choose a file** or drag it here.")
                        .font(.title)
                        .padding(.top)
                }
                
            }
            // Change cursor to pointing hand when the user hovers over the window
            .onHover(perform: { isHovering in
                DispatchQueue.main.async { //<-- Here
                    if (isHovering) {
                        NSCursor.pointingHand.push()
                    } else {
                        NSCursor.pop()
                    }
                }
            })
            // Open file picker on tap
            .onTapGesture(perform: didTapOpenFilePicker)
            // Indent the dashed border slightly
            .padding(24)
            // Handle dropped file
            .csvDropDestination(with: didSelectFile)
    }
}

#Preview {
    SelectFileScreen(didSelectFile: {_ in}, didTapOpenFilePicker: {})
}
