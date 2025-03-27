//
//  DynamicNotchInfo.swift
//  DynamicNotchKit
//
//  Created by Kai Azim on 2023-08-25.
//

import SwiftUI

public enum DynamicNotchInfoIcon {
    case image(image: Image, color: Color? = nil)
    case systemImage(systemName: String, color: Color? = nil)
    case view(view: AnyView)
    case appIcon
    case none

    @ViewBuilder
    func view(notchStyle: DynamicNotchStyle) -> some View {
        switch self {
        case let .image(image, color):
            image
                .resizable()
                .padding(3)
                .scaledToFit()
        case let .systemImage(systemName, color):
            Image(systemName: systemName)
                .resizable()
                .foregroundStyle(color ?? (notchStyle == .notch ? .white : .primary))
                .padding(3)
                .scaledToFit()
        case let .view(view):
            view
        case .appIcon:
            Image(nsImage: NSApplication.shared.applicationIconImage)
                .resizable()
                .padding(-5)
                .scaledToFit()
        case .none:
            EmptyView()
                .frame(width: 0, height: 0)
        }
    }
}

public class DynamicNotchInfo: ObservableObject {
    private var internalDynamicNotch: DynamicNotch<InfoView>!

    @Published public var icon: DynamicNotchInfoIcon
    @Published public var title: String
    @Published public var description: String?
    @Published public var textColor: Color?

    public init(
        contentID: UUID = .init(),
        icon: DynamicNotchInfoIcon,
        title: String,
        description: String? = nil,
        style: DynamicNotchStyle = .auto
    ) {
        self.icon = icon
        self.title = title
        self.description = description
        self.internalDynamicNotch = DynamicNotch(contentID: contentID, style: style) {
            InfoView(dynamicNotch: self)
        }
    }

    public func show(
        on screen: NSScreen = NSScreen.screens[0],
        for time: Double = 0
    ) {
        internalDynamicNotch.show(on: screen, for: time)
    }

    public func hide() {
        internalDynamicNotch.hide()
    }

    public func toggle() {
        internalDynamicNotch.toggle()
    }
}

extension DynamicNotchInfo {
    struct InfoView: View {
        @Environment(\.notchStyle) private var notchStyle
        @ObservedObject var dynamicNotch: DynamicNotchInfo

        init(dynamicNotch: DynamicNotchInfo) {
            self.dynamicNotch = dynamicNotch
        }

        public var body: some View {
            HStack(spacing: 10) {
                dynamicNotch.icon.view(notchStyle: notchStyle)
                textView()
                Spacer(minLength: 0)
            }
            .frame(height: 40)
        }

        @ViewBuilder
        func textView() -> some View {
            VStack(alignment: .leading, spacing: dynamicNotch.description != nil ? nil : 0) {
                Text(dynamicNotch.title)
                    .font(.headline)
                    .foregroundStyle(dynamicNotch.textColor ?? (notchStyle == .notch ? .white : .primary))

                if let description = dynamicNotch.description {
                    Text(description)
                        .font(.caption2)
                        .foregroundStyle(dynamicNotch.textColor?.opacity(0.5) ?? (notchStyle == .notch ? .white.opacity(0.5) : .secondary))
                }
            }
        }
    }
}
