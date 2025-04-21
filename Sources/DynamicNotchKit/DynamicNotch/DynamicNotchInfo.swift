//
//  DynamicNotchInfo.swift
//  DynamicNotchKit
//
//  Created by Kai Azim on 2023-08-25.
//

import SwiftUI

// MARK: DynamicNotchInfo

/// A preset `DynamicNotch` suited for seamlessly presenting information.
///
/// This class is a wrapper around `DynamicNotch` that provides a simple way to present information to the user. It is designed to be easy to use and provide a clean and simple way to present information.
@MainActor
public final class DynamicNotchInfo: ObservableObject, DynamicNotchControllable {
    private var internalDynamicNotch: DynamicNotch<InfoView, CompactLeadingView, CompactTrailingView>!

    @Published public var icon: DynamicNotchInfoIcon?
    @Published public var title: String
    @Published public var description: String?
    @Published public var textColor: Color?
    @Published public var compactLeading: DynamicNotchInfoIcon? {
        didSet { internalDynamicNotch.disableCompactLeading = compactLeading == nil }
    }

    @Published public var compactTrailing: DynamicNotchInfoIcon? {
        didSet { internalDynamicNotch.disableCompactTrailing = compactTrailing == nil }
    }

    /// Initializes a `DynamicNotchInfo`.
    /// - Parameters:
    ///   - icon: the icon to display in the notch.
    ///   - title: the title to display in the notch.
    ///   - description: the description to display in the notch. If unspecified, no description will be displayed.
    ///   - style: the popover's style. If unspecified, the style will be automatically set according to the screen (notch or floating).
    public init(
        icon: DynamicNotchInfoIcon?,
        title: String,
        description: String? = nil,
        compactLeading: DynamicNotchInfoIcon? = nil,
        compactTrailing: DynamicNotchInfoIcon? = nil,
        hoverBehavior: DynamicNotchHoverBehavior = .all,
        style: DynamicNotchStyle = .auto,
    ) {
        self.icon = icon
        self.title = title
        self.description = description
        self.internalDynamicNotch = DynamicNotch(
            hoverBehavior: hoverBehavior,
            style: style
        ) {
            InfoView(dynamicNotch: self)
        } compactLeading: {
            CompactLeadingView(dynamicNotch: self)
        } compactTrailing: {
            CompactTrailingView(dynamicNotch: self)
        }
        self.compactLeading = compactLeading
        self.compactTrailing = compactTrailing
    }

    /// Show the DynamicNotchInfo.
    /// - Parameters:
    ///   - screen: screen to show on. Default is the primary screen, which generally contains the notch on MacBooks.
    public func expand(
        on screen: NSScreen = NSScreen.screens[0]
    ) {
        internalDynamicNotch.expand(on: screen)
    }

    /// Show the popup in a compact state.
    /// - Parameters:
    ///  - screen: screen to show on. Default is the primary screen, which generally contains the notch on MacBooks.
    public func compact(
        on screen: NSScreen = NSScreen.screens[0]
    ) {
        internalDynamicNotch.compact(on: screen)
    }

    /// Hide the popup.
    public func hide() {
        internalDynamicNotch.hide()
    }
}

// MARK: Helper Views

extension DynamicNotchInfo {
    struct CompactInfoView: View {
        var body: some View {
            Circle()
        }
    }

    struct CompactLeadingView: View {
        @ObservedObject var dynamicNotch: DynamicNotchInfo

        init(dynamicNotch: DynamicNotchInfo) {
            self.dynamicNotch = dynamicNotch
        }

        public var body: some View {
            dynamicNotch.compactLeading
        }
    }

    struct CompactTrailingView: View {
        @ObservedObject var dynamicNotch: DynamicNotchInfo

        init(dynamicNotch: DynamicNotchInfo) {
            self.dynamicNotch = dynamicNotch
        }

        public var body: some View {
            dynamicNotch.compactTrailing
        }
    }

    struct InfoView: View {
        @Environment(\.notchStyle) private var notchStyle
        @ObservedObject var dynamicNotch: DynamicNotchInfo

        init(dynamicNotch: DynamicNotchInfo) {
            self.dynamicNotch = dynamicNotch
        }

        public var body: some View {
            HStack(spacing: 10) {
                if let icon = dynamicNotch.icon {
                    icon
                }

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
                    .foregroundStyle(dynamicNotch.textColor ?? (notchStyle.isNotch ? .white : .primary))

                if let description = dynamicNotch.description {
                    Text(description)
                        .font(.caption2)
                        .foregroundStyle(dynamicNotch.textColor?.opacity(0.5) ?? (notchStyle.isNotch ? .white.opacity(0.5) : .secondary))
                }
            }
        }
    }
}
