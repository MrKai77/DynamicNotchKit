//
//  NotchView.swift
//  DynamicNotchKit
//
//  Created by Kai Azim on 2023-08-24.
//

import SwiftUI

struct NotchView<Content>: View where Content: View {
    @ObservedObject var dynamicNotch: DynamicNotch<Content>

//    private let safeAreaInset: CGFloat = 20

    var expandedNotchCornerRadii: (top: CGFloat, bottom: CGFloat) {
        if case let .notch(topCornerRadius, bottomCornerRadius) = dynamicNotch.notchStyle {
            return (top: topCornerRadius, bottom: bottomCornerRadius)
        } else {
            return (top: 15, bottom: 20)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Spacer()

                VStack(spacing: 0) {
                    Spacer()
                        .frame(
                            width: dynamicNotch.notchSize.width + (expandedNotchCornerRadii.top * 2),
                            height: dynamicNotch.notchSize.height
                        )

                    dynamicNotch.content()
                        .id(dynamicNotch.contentID)
                        .safeAreaInset(edge: .bottom, spacing: 0) { Color.clear.frame(height: expandedNotchCornerRadii.bottom) }
                        .safeAreaInset(edge: .leading, spacing: 0) { Color.clear.frame(width: expandedNotchCornerRadii.bottom) }
                        .safeAreaInset(edge: .trailing, spacing: 0) { Color.clear.frame(width: expandedNotchCornerRadii.bottom) }
                        .blur(radius: dynamicNotch.isVisible ? 0 : 10)
                        .scaleEffect(dynamicNotch.isVisible ? 1 : 0.8)
                        .offset(y: dynamicNotch.isVisible ? 0 : 5)
                        .padding(.horizontal, expandedNotchCornerRadii.top)
                        .transition(.blur.animation(dynamicNotch.animation))
                }
                .fixedSize()
                .frame(minWidth: dynamicNotch.notchSize.width)
                .onHover { hovering in
                    dynamicNotch.isMouseInside = hovering
                }
                .background {
                    Rectangle()
                        .foregroundStyle(.black)
                        .padding(-50) // The opening/closing animation can overshoot, so this makes sure that it's still black
                }
                .mask {
                    GeometryReader { _ in // This helps with positioning everything
                        HStack {
                            Spacer(minLength: 0)

                            NotchShape(
                                topCornerRadius: dynamicNotch.isVisible ? expandedNotchCornerRadii.top : nil,
                                bottomCornerRadius: dynamicNotch.isVisible ? expandedNotchCornerRadii.bottom : nil
                            )
                            .frame(
                                width: dynamicNotch.isVisible ? nil : dynamicNotch.notchSize.width,
                                height: dynamicNotch.isVisible ? nil : dynamicNotch.notchSize.height
                            )

                            Spacer(minLength: 0)
                        }
                    }
                }
                .shadow(color: .black.opacity(0.5), radius: dynamicNotch.isVisible ? 10 : 0)
                .animation(dynamicNotch.animation, value: dynamicNotch.contentID)

                Spacer()
            }
            Spacer()
        }
        .environment(\.notchStyle, dynamicNotch.notchStyle.isNotch ? dynamicNotch.notchStyle : .notch)
    }
}
