//
//  NotchContentView.swift
//  DynamicNotchKit
//
//  Created by Kai Azim on 2025-04-19.
//

import SwiftUI

struct NotchContentView<Content>: View where Content: View {
    @Environment(\.notchAnimation) private var animation
    @ObservedObject private var dynamicNotch: DynamicNotch<Content>
    private let style: DynamicNotchStyle

    init(dynamicNotch: DynamicNotch<Content>, style: DynamicNotchStyle) {
        self.dynamicNotch = dynamicNotch
        self.style = style
    }

    private var shadowOpacity: CGFloat {
        if dynamicNotch.hoverBehavior.contains(.increaseShadow), dynamicNotch.isHovering {
            0.8
        } else {
            0.5
        }
    }

    private var shadowRadius: CGFloat {
        if !dynamicNotch.isVisible {
            0
        } else if dynamicNotch.isHovering, dynamicNotch.hoverBehavior.contains(.increaseShadow) {
            20
        } else {
            10
        }
    }

    var body: some View {
        ZStack {
            if style.isNotch {
                NotchView(dynamicNotch: dynamicNotch)
                    .foregroundStyle(.white)
            } else {
                NotchlessView(dynamicNotch: dynamicNotch)
            }
        }
        .onHover(perform: dynamicNotch.updateHoverState)
        .shadow(
            color: .black.opacity(shadowOpacity),
            radius: shadowRadius
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .environment(\.notchStyle, style)
        .animation(animation, value: dynamicNotch.contentID)
        .animation(animation, value: dynamicNotch.isHovering)
        .animation(animation, value: dynamicNotch.isVisible)
    }
}
