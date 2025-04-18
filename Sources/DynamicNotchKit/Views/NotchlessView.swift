//
//  NotchlessView.swift
//  DynamicNotchKit
//
//  Created by Kai Azim on 2024-04-06.
//

import SwiftUI

struct NotchlessView<Content>: View where Content: View {
    @Environment(\.notchAnimation) private var animation
    @ObservedObject var dynamicNotch: DynamicNotch<Content>
    @State var windowHeight: CGFloat = 0

    private let safeAreaInset: CGFloat = 15

    private var cornerRadius: CGFloat {
        if case let .floating(cornerRadius) = dynamicNotch.notchStyle {
            cornerRadius
        } else {
            20
        }
    }

    var body: some View {
        notchContent()
            .onHover { hovering in
                dynamicNotch.isMouseInside = hovering
            }
            .background {
                VisualEffectView(material: .popover, blendingMode: .behindWindow)
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(.quaternary, lineWidth: 1)
                    }
            }
            .clipShape(.rect(cornerRadius: cornerRadius))
            .shadow(color: .black.opacity(0.5), radius: dynamicNotch.isVisible ? 10 : 0)
            .padding(20)
            .onGeometryChange(for: CGFloat.self, of: \.size.height) { newHeight in
                // This makes sure that the floating window FULLY slides off before disappearing
                windowHeight = newHeight
            }
            .offset(y: dynamicNotch.isVisible ? dynamicNotch.notchSize.height : -windowHeight)
            .transition(.blur)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .environment(\.notchStyle, dynamicNotch.notchStyle.isFloating ? dynamicNotch.notchStyle : .floating)
            .animation(animation, value: dynamicNotch.contentID)
            .animation(animation, value: dynamicNotch.isVisible)
    }

    private func notchContent() -> some View {
        dynamicNotch.content()
            .id(dynamicNotch.contentID)
            .safeAreaInset(edge: .top, spacing: 0) { Color.clear.frame(height: safeAreaInset) }
            .safeAreaInset(edge: .bottom, spacing: 0) { Color.clear.frame(height: safeAreaInset) }
            .safeAreaInset(edge: .leading, spacing: 0) { Color.clear.frame(width: safeAreaInset) }
            .safeAreaInset(edge: .trailing, spacing: 0) { Color.clear.frame(width: safeAreaInset) }
            .fixedSize()
    }
}
