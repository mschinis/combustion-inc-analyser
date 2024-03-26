//
//  AnnotationBackgroundViewModifier.swift
//  CombustionIncAnalyser
//
//  Created by Michael Schinis on 23/11/2023.
//

import SwiftUI

struct AnnotationBackgroundViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
        #if os(macOS)
            .background(
                .thinMaterial,
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
        #else
            // Thin Material on iPad/iOS for some reason shows black,
            // so replacing with an opaque background
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        Color(uiColor: UIColor.systemBackground)
                            .opacity(0.8)
                    )
        )
        #endif
    }
}

extension View {
    func annotationBackground() -> some View {
        modifier(
            AnnotationBackgroundViewModifier()
        )
    }
}

#Preview {
    Color.yellow
        .padding()
        .background(.red)
        .padding()
        .annotationBackground()
}
