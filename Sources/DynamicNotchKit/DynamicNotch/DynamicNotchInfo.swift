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
public final class DynamicNotchInfo: ObservableObject {
    private var internalDynamicNotch: DynamicNotch<InfoView>!

    @Published public var icon: DynamicNotchInfoIcon? {
        didSet { internalDynamicNotch.refreshContent() }
    }

    @Published public var title: String
    @Published public var description: String?
    @Published public var textColor: Color?

    /// Initializes a `DynamicNotchInfo`.
    /// - Parameters:
    ///   - contentID: the ID of the content. If unspecified, a new ID will be generated. This helps to differentiate between different contents.
    ///   - icon: the icon to display in the notch.
    ///   - title: the title to display in the notch.
    ///   - description: the description to display in the notch. If unspecified, no description will be displayed.
    ///   - style: the popover's style. If unspecified, the style will be automatically set according to the screen (notch or floating).
    @MainActor
    public init(
        contentID: UUID = .init(),
        icon: DynamicNotchInfoIcon?,
        title: String,
        description: String? = nil,
        hoverBehavior: DynamicNotchHoverBehavior = [.keepVisible],
        style: DynamicNotchStyle = .auto,
    ) {
        self.icon = icon
        self.title = title
        self.description = description
        self.internalDynamicNotch = DynamicNotch(
            contentID: contentID,
            hoverBehavior: hoverBehavior,
            style: style
        ) {
            InfoView(dynamicNotch: self)
        }
    }

    /// Show the DynamicNotchInfo.
    /// - Parameters:
    ///   - screen: screen to show on. Default is the primary screen, which generally contains the notch on MacBooks.
    ///   - duration: duration for which the notch will be shown. If 0, the DynamicNotch will stay visible until `hide()` is called.
    public func show(
        on screen: NSScreen = NSScreen.screens[0],
        for duration: Duration = .zero
    ) {
        internalDynamicNotch.show(on: screen, for: duration)
    }

    /// Hide the popup.
    public func hide() {
        internalDynamicNotch.hide()
    }

    /// Toggles the popup's visibility.
    public func toggle() {
        internalDynamicNotch.toggle()
    }
}

// MARK: InfoView

struct InfoView: View {
    @Environment(\.notchStyle) private var notchStyle
    @Environment(\.notchAnimation) private var animation
    @ObservedObject var dynamicNotch: DynamicNotchInfo

    init(dynamicNotch: DynamicNotchInfo) {
        self.dynamicNotch = dynamicNotch
    }

    public var body: some View {
        HStack(spacing: 10) {
            if let icon = dynamicNotch.icon {
                icon
                    .transition(.blur)
            }

            textView()

            Spacer(minLength: 0)
        }
        .frame(height: 40)
        .animation(animation, value: dynamicNotch.icon)
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
