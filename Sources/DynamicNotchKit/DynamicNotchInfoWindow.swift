//
//  DynamicNotchInfoWindow.swift
//
//
//  Created by Kai Azim on 2023-08-25.
//

import SwiftUI

public class DynamicNotchInfoWindow: DynamicNotch {

    // MARK: Initialzers
    public init<Content: View>(iconView: Content, title: String, description: String! = nil, style: DynamicNotch.Style! = nil) {
        super.init(content: DynamicNotchInfoWindow.getView(iconView: iconView, title: title, description: description, notchStyle: style), style: style)
    }

    public convenience init(image: Image! = nil, iconColor: Color = .white, title: String, description: String? = nil, style: DynamicNotch.Style! = nil) {
        let iconView = DynamicNotchInfoWindow.getIconView(image: image, iconColor: iconColor)
        self.init(iconView: iconView, title: title, description: description, style: style)
    }

    public convenience init(systemImage: String, iconColor: Color = .white, title: String, description: String? = nil, style: DynamicNotch.Style! = nil) {
        self.init(image: Image(systemName: systemImage), iconColor: iconColor, title: title, description: description, style: style)
    }

    // MARK: Set content
    public func setContent<Content: View>(iconView: Content, title: String, description: String! = nil) {
        super.setContent(content: DynamicNotchInfoWindow.getView(iconView: iconView, title: title, description: description, notchStyle: super.notchStyle))
    }

    public func setContent(image: Image! = nil, iconColor: Color = .white, title: String, description: String? = nil) {
        let iconView = DynamicNotchInfoWindow.getIconView(image: image, iconColor: iconColor)
        self.setContent(iconView: iconView, title: title, description: description)
    }

    public func setContent(systemImage: String, iconColor: Color = .white, title: String, description: String? = nil) {
        self.setContent(image: Image(systemName: systemImage), iconColor: iconColor, title: title, description: description)
    }

    // MARK: Private
    private static func getView<Content: View>(iconView: Content, title: String, description: String! = nil, notchStyle: DynamicNotch.Style) -> some View {
        var infoView: some View {
            HStack {
                iconView

                Spacer()
                    .frame(width: 10)

                VStack(alignment: .leading) {
                    Text(title)
                        .font(.headline)

                    if let description = description {
                        Text(description)
                            .foregroundStyle(.secondary)
                            .font(.caption2)
                    }
                }

                Spacer()
            }
            .frame(height: 40)
            .padding([.horizontal, .bottom], 20)
            .padding([.top], notchStyle == .floating ? 20 : 0)
        }

        return infoView
    }

    @ViewBuilder private static func getIconView(image: Image! = nil, iconColor: Color = .white) -> some View {
        if let image = image {
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
