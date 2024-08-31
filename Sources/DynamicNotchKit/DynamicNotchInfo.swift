//
//  DynamicNotchInfoWindow.swift
//  DynamicNotchKit
//
//  Created by Kai Azim on 2023-08-25.
//

import SwiftUI

public class DynamicNotchInfo {
    private var internalDynamicNotch: DynamicNotch<InfoView>

    public init(icon: Image! = nil, title: String, description: String? = nil, iconColor: Color = .white, style: DynamicNotch<InfoView>.Style = .auto) {
        internalDynamicNotch = DynamicNotch(style: style) {
            InfoView(icon: icon, iconColor: iconColor, title: title, description: description)
        }
    }

    public func setContent(icon: Image! = nil, title: String, description: String? = nil, iconColor: Color = .white) {
        internalDynamicNotch.setContent {
            InfoView(icon: icon, iconColor: iconColor, title: title, description: description)
        }
    }

    public func show(on screen: NSScreen = NSScreen.screens[0], for time: Double = 0) {
        internalDynamicNotch.show(on: screen, for: time)
    }

    public func hide() {
        internalDynamicNotch.hide()
    }

    public func toggle() {
        internalDynamicNotch.toggle()
    }
}

public extension DynamicNotchInfo {
    struct InfoView: View {
        @State var icon: Image! = nil
        @State var iconColor: Color
        @State var title: String
        @State var description: String?

        public var body: some View {
            HStack(spacing: 10) {
                iconView()
                textView()
                Spacer(minLength: 0)
            }
            .frame(height: 40)
        }

        @ViewBuilder
        func iconView() -> some View {
            if let image = icon {
                image
                    .resizable()
                    .foregroundStyle(iconColor)
                    .padding(3)
                    .scaledToFit()
            } else {
                Image(nsImage: NSApplication.shared.applicationIconImage)
                    .resizable()
                    .padding(-5)
                    .scaledToFit()
            }
        }

        func textView() -> some View {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)

                if let description {
                    Text(description)
                        .foregroundStyle(.secondary)
                        .font(.caption2)
                }
            }
        }
    }
}
