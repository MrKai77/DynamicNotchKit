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
public final class DynamicNotchInfo: ObservableObject, DynamicNotchControllable {
    private var internalDynamicNotch: DynamicNotch<InfoView, CompactLeadingView, CompactTrailingView>!

    @Published public var icon: DynamicNotchInfo.Label?
    @Published public var title: LocalizedStringKey
    @Published public var description: LocalizedStringKey?
    @Published public var textColor: Color?
    @Published public var compactLeading: DynamicNotchInfo.Label? {
        didSet { internalDynamicNotch.disableCompactLeading = compactLeading == nil }
    }
    @Published public var compactTrailing: DynamicNotchInfo.Label? {
        didSet { internalDynamicNotch.disableCompactTrailing = compactTrailing == nil }
    }

    /// Creates a new DynamicNotchInfo with a predefined content and style based on parameters.
    /// - Parameters:
    ///   - icon: the icon to display in the expanded state of the notch.
    ///   - title: the title to display in the expanded state of the notch.
    ///   - description: the description to display in the expanded state of the notch. If unspecified, no description will be displayed.
    ///   - compactLeading: the icon to display in the compact leading state of the notch. If unspecified, no icon will be displayed.
    ///   - compactTrailing: the icon to display in the compact trailing state of the notch. If unspecified, no icon will be displayed.
    ///   - hoverBehavior: the hover behavior of the notch, which allows for different interactions such as haptic feedback, increased shadow etc.
    ///   - style: the popover's style. If unspecified, the style will be automatically set according to the screen (notch or floating).
    public init(
        icon: DynamicNotchInfo.Label?,
        title: LocalizedStringKey,
        description: LocalizedStringKey? = nil,
        compactLeading: DynamicNotchInfo.Label? = nil,
        compactTrailing: DynamicNotchInfo.Label? = nil,
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

    public func expand(
        on screen: NSScreen = NSScreen.screens[0]
    ) async {
        await internalDynamicNotch.expand(on: screen)
    }

    public func compact(
        on screen: NSScreen = NSScreen.screens[0]
    ) async {
        await internalDynamicNotch.compact(on: screen)
    }

    public func hide() async {
        await internalDynamicNotch.hide()
    }
}
