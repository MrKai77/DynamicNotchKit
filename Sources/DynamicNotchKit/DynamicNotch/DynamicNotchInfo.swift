//
//  DynamicNotchInfo.swift
//  DynamicNotchKit
//
//  Created by Kai Azim on 2023-08-25.
//

import SwiftUI

public struct DynamicNotchInfoIcon: View {
    @Environment(\.notchStyle) private var notchStyle
    private var iconStyle: IconStyle
    
    enum IconStyle: Equatable {
        case image(image: Image)
        case systemImage(systemName: String, color: Color?)
        case appIcon
        case customView(contentID: UUID, view: AnyView)
        
        static func == (lhs: DynamicNotchInfoIcon.IconStyle, rhs: DynamicNotchInfoIcon.IconStyle) -> Bool {
            switch (lhs, rhs) {
            case let (.image(image1), .image(image2)):
                return image1 == image2
            case let (.systemImage(systemName1, color1), .systemImage(systemName2, color2)):
                return systemName1 == systemName2 && color1 == color2
            case (.appIcon, .appIcon):
                return true
            case let (.customView(contentID1, _), .customView(contentID2, _)):
                return contentID1 == contentID2
            default:
                return false
            }
        }
    }
    
    
    /// An image to display in the `DynamicNotchInfo`.
    /// - Parameter image: the image to display.
    public init(image: Image) {
        self.iconStyle = .image(image: image)
    }
    
    /// A system image to display in the `DynamicNotchInfo`.
    /// - Parameters:
    ///   - systemName: the name of the system image to display.
    ///   - color: the color of the image. If not specified, the image will be colored according to the notch style.
    public init(systemName: String, color: Color? = nil) {
        self.iconStyle = .systemImage(systemName: systemName, color: color)
    }
    
    /// A view to display in the` DynamicNotchInfo`.
    /// - Parameter content: the view to display.
    public init<Content: View>(@ViewBuilder content: () -> Content) {
        self.iconStyle = .customView(contentID: .init(), view: AnyView(content()))
    }
    
    public var body: some View {
        switch iconStyle {
        case let .image(image):
            image
                .resizable()
                .padding(3)
                .scaledToFit()
        case let .systemImage(systemName, color):
            Image(systemName: systemName)
                .resizable()
                .foregroundStyle(color ?? (notchStyle.isNotch ? .white : .primary))
                .padding(3)
                .scaledToFit()
        case let .customView(_, view):
            view
        case .appIcon:
            Image(nsImage: NSApplication.shared.applicationIconImage)
                .resizable()
                .padding(-5)
                .scaledToFit()
        }
    }
}

extension DynamicNotchInfoIcon: Equatable {
    public static func == (lhs: DynamicNotchInfoIcon, rhs: DynamicNotchInfoIcon) -> Bool {
        rhs.iconStyle == lhs.iconStyle
    }
}

/// A preset `DynamicNotch` suited for seamlessly presenting information.
///
/// This class is a wrapper around `DynamicNotch` that provides a simple way to present information to the user. It is designed to be easy to use and provide a clean and simple way to present information.
public class DynamicNotchInfo: ObservableObject {
    private var internalDynamicNotch: DynamicNotch<InfoView>!

    @Published public var icon: DynamicNotchInfoIcon? {
        didSet { internalDynamicNotch.contentID = .init() }
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
    public init(
        contentID: UUID = .init(),
        icon: DynamicNotchInfoIcon?,
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
}
