//
//  DynamicNotchInfo.swift
//  DynamicNotchKit
//
//  Created by Kai Azim on 2023-08-25.
//

import SwiftUI

/// The icon to display in the DynamicNotchInfo.
public enum DynamicNotchInfoIcon {
    /// An image to display in the DynamicNotchInfo.
    case image(image: Image)

    /// A system image to display in the DynamicNotchInfo.
    case systemImage(systemName: String, color: Color? = nil)

    /// A view to display in the DynamicNotchInfo.
    ///
    /// Please note that we currently use `AnyView` (a type-erased view) to allow for any view to be passed in. This means that you will need to wrap your view in `AnyView` when using this case.
    case view(view: AnyView)

    /// The app icon to display in the DynamicNotchInfo.
    case appIcon

    /// No icon to display in the DynamicNotchInfo.
    case none

    @ViewBuilder
    func view(notchStyle: DynamicNotchStyle) -> some View {
        switch self {
        case let .image(image):
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

/// A preset `DynamicNotch` suited for seamlessly presenting information.
///
/// This class is a wrapper around `DynamicNotch` that provides a simple way to present information to the user. It is designed to be easy to use and provide a clean and simple way to present information.
public class DynamicNotchInfo: ObservableObject {
    private var internalDynamicNotch: DynamicNotch<InfoView>!

    @Published public var icon: DynamicNotchInfoIcon
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
    /// - Parameter ignoreMouse: if true, the popup will hide even if the mouse is inside the notch area.
    public func hide(ignoreMouse: Bool = false) {
        internalDynamicNotch.hide(ignoreMouse: ignoreMouse)
    }

    /// Toggles the popup's visibility.
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
