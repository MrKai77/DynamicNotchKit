//
//  DynamicNotchInfoIcon.swift
//  DynamicNotchKit
//
//  Created by Kai Azim on 2025-04-18.
//

import SwiftUI

/// The icon to display in a `DynamicNotchInfo`.
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

extension DynamicNotchInfoIcon: @preconcurrency Equatable {
    public static func == (lhs: DynamicNotchInfoIcon, rhs: DynamicNotchInfoIcon) -> Bool {
        rhs.iconStyle == lhs.iconStyle
    }
}
