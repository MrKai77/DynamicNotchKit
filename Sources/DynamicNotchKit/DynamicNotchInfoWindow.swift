//
//  DynamicNotchInfoWindow.swift
//
//
//  Created by Kai Azim on 2023-08-25.
//

import SwiftUI

public class DynamicNotchInfoWindow: DynamicNotch {
    public init(systemImage: String, iconColor: Color = .white, title: String, description: String! = nil) {
        super.init(content: EmptyView())
        self.setContent(
            image: Image(systemName: systemImage),
            iconColor: iconColor,
            title: title,
            description: description
        )
    }

    public init(image: Image! = nil, iconColor: Color = .white, title: String, description: String! = nil) {
        super.init(content: EmptyView())
        self.setContent(
            image: image,
            iconColor: iconColor,
            title: title,
            description: description
        )
    }

    public init<Content: View>(iconView: Content, title: String, description: String! = nil) {
        super.init(content: EmptyView())
        self.setContent(
            iconView: iconView,
            title: title,
            description: description
        )
    }

    public func setContent(image: Image! = nil, iconColor: Color = .white, title: String, description: String! = nil) {
        let appIcon = Image(nsImage: NSApplication.shared.applicationIconImage)

        var infoView: some View {
            HStack {
                if let image = image {
                    image
                        .resizable()
                        .foregroundStyle(iconColor)
                        .padding(3)
                        .scaledToFit()
                } else {
                    appIcon
                        .resizable()
                        .padding(-5)
                        .scaledToFit()
                }

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
            .padding(15)
        }
        super.setContent(content: infoView)
    }

    public func setContent<Content: View>(iconView: Content, title: String, description: String! = nil) {
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
            .padding(15)
        }
        super.setContent(content: infoView)
    }
}
