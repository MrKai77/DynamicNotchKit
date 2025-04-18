//
//  NotchView.swift
//  DynamicNotchKit
//
//  Created by Kai Azim on 2023-08-24.
//

import SwiftUI

struct NotchView<Content>: View where Content: View {
    @Environment(\.notchAnimation) private var animation
    @ObservedObject var dynamicNotch: DynamicNotch<Content>

    private var expandedNotchCornerRadii: (top: CGFloat, bottom: CGFloat) {
        if case let .notch(topCornerRadius, bottomCornerRadius) = dynamicNotch.notchStyle {
            (top: topCornerRadius, bottom: bottomCornerRadius)
        } else {
            (top: 15, bottom: 20)
        }
    }

    private var compactNotchCornerRadii: (top: CGFloat, bottom: CGFloat) {
        (top: 6, bottom: 14)
    }

    var body: some View {
        notchContent()
            .onHover { hovering in
                dynamicNotch.isMouseInside = hovering
            }
            .background {
                Rectangle()
                    .foregroundStyle(.black)
                    .padding(-50) // The opening/closing animation can overshoot, so this makes sure that it's still black
            }
            .mask {
                NotchShape(
                    topCornerRadius: topCornerRadius,
                    bottomCornerRadius: bottomCornerRadius
                )
                .padding(.horizontal, 0.5)
                .frame(
                    width: dynamicNotch.isVisible ? nil : notchWidth,
                    height: dynamicNotch.isVisible ? nil : dynamicNotch.notchSize.height
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .shadow(color: .black.opacity(0.5), radius: dynamicNotch.isVisible ? 10 : 0)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .environment(\.notchStyle, dynamicNotch.notchStyle.isNotch ? dynamicNotch.notchStyle : .notch)
            .animation(animation, value: dynamicNotch.contentID)
            .animation(animation, value: dynamicNotch.isVisible)
    }

    private func notchContent() -> some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(
                    width: notchWidth,
                    height: dynamicNotch.notchSize.height
                )

            dynamicNotch.content()
                .id(dynamicNotch.contentID)
                .safeAreaInset(edge: .bottom, spacing: 0) { Color.clear.frame(height: bottomCornerRadius) }
                .safeAreaInset(edge: .leading, spacing: 0) { Color.clear.frame(width: bottomCornerRadius) }
                .safeAreaInset(edge: .trailing, spacing: 0) { Color.clear.frame(width: bottomCornerRadius) }
                .blur(radius: dynamicNotch.isVisible ? 0 : 10)
                .scaleEffect(dynamicNotch.isVisible ? 1 : 0.8)
                .offset(y: dynamicNotch.isVisible ? 0 : 5)
                .padding(.horizontal, topCornerRadius)
                .transition(.blur)
        }
        .fixedSize()
        .frame(minWidth: notchWidth)
    }

    private var notchWidth: CGFloat {
        dynamicNotch.notchSize.width + (topCornerRadius * 2)
    }

    private var topCornerRadius: CGFloat {
        dynamicNotch.isVisible ? expandedNotchCornerRadii.top : compactNotchCornerRadii.top
    }

    private var bottomCornerRadius: CGFloat {
        dynamicNotch.isVisible ? expandedNotchCornerRadii.bottom : compactNotchCornerRadii.bottom
    }
}
