//
//  DynamicNotchInfoWindow.swift
//
//
//  Created by Kai Azim on 2023-08-25.
//

import SwiftUI

// BETA
public class DynamicNotchInfo: DynamicNotch {
    // MARK: Initializers

    /// Construct a new DynamicNotchInfoWindow with a custom icon SwiftUI view.
    /// - Parameters:
    ///   - iconView: A SwiftUI View
    ///   - title: A title for your content
    ///   - description: An optional description for your content
    ///   - style: The popover's style. If unspecified, the style will be automatically set according to the screen.
    public init(iconView: some View, title: String, description: String! = nil, style: DynamicNotch.Style! = nil) {
        super.init(content: EmptyView(), style: style) // It is required to initialize the class first here so that dynamicNotch.notchStyle is not nil.
        setContent(iconView: iconView, title: title, description: description)
    }

    /// Construct a new DynamicNotchInfoWindow with an Image as the icon.
    /// - Parameters:
    ///   - image: An optional Image. If left unspecified, the application icon will be used
    ///   - iconColor: The color of the icon
    ///   - title: A title for your content
    ///   - description: An optional description for your content
    ///   - style: The popover's style. If unspecified, the style will be automatically set according to the screen.
    public convenience init(icon: Image! = nil, iconColor: Color = .white, title: String, description: String? = nil, style: DynamicNotch.Style! = nil) {
        let iconView = DynamicNotchInfo.getIconView(icon: icon, iconColor: iconColor)
        self.init(iconView: iconView, title: title, description: description, style: style)
    }

    /// Construct a new DynamicNotchInfoWindow with an SF Symbol as the icon.
    /// - Parameters:
    ///   - systemImage: The SF Symbol's name
    ///   - iconColor: The color of the icon
    ///   - title: A title for your content
    ///   - description:  An optional description for your content
    ///   - style: The popover's style. If unspecified, the style will be automatically set according to the screen.
    public convenience init(systemImage: String, iconColor: Color = .white, title: String, description: String? = nil, style: DynamicNotch.Style! = nil) {
        self.init(icon: Image(systemName: systemImage), iconColor: iconColor, title: title, description: description, style: style)
    }

    // MARK: Set content

    /// Set new content for the DynamicNotchInfoWindow.
    /// - Parameters:
    ///   - iconView: A SwiftUI View
    ///   - title: A title for your content
    ///   - description: An optional description for your content
    public func setContent(iconView: some View, title: String, description: String! = nil) {
        super.setContent(content: DynamicNotchInfo.getView(iconView: iconView, title: title, description: description, notchStyle: super.notchStyle))
    }

    /// Set new content for the DynamicNotchInfoWindow, with an Image as the icon.
    /// - Parameters:
    ///   - icon: An optional Image. If left unspecified, the application icon will be used
    ///   - iconColor: The color of the icon
    ///   - title: A title for your content
    ///   - description: An optional description for your content
    public func setContent(icon: Image! = nil, iconColor: Color = .white, title: String, description: String? = nil) {
        let iconView = DynamicNotchInfo.getIconView(icon: icon, iconColor: iconColor)
        setContent(iconView: iconView, title: title, description: description)
    }

    /// Set new content for the DynamicNotchInfoWindow, with an SF Symbol as the icon.
    /// - Parameters:
    ///   - systemImage: The SF Symbol's name
    ///   - iconColor: The color of the icon
    ///   - title: A title for your content
    ///   - description: An optional description for your content
    public func setContent(systemImage: String, iconColor: Color = .white, title: String, description: String? = nil) {
        setContent(icon: Image(systemName: systemImage), iconColor: iconColor, title: title, description: description)
    }

    // MARK: Private

    private static func getView(iconView: some View, title: String, description: String! = nil, notchStyle _: DynamicNotch.Style) -> some View {
        var infoView: some View {
            HStack {
                iconView

                Spacer()
                    .frame(width: 10)

                VStack(alignment: .leading) {
                    Text(title)
                        .font(.headline)

                    if let description {
                        Text(description)
                            .foregroundStyle(.secondary)
                            .font(.caption2)
                    }
                }

                Spacer()
            }
            .frame(height: 40)
            .padding(20)
        }

        return infoView
    }

    @ViewBuilder private static func getIconView(icon: Image! = nil, iconColor: Color = .white) -> some View {
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
}
