//
//  DNInfoWindow.swift
//
//
//  Created by Kai Azim on 2023-08-25.
//

import SwiftUI

public class DNInfoWindow: DNWindow {
    public init(icon: Image! = nil, iconColor: Color = .white, title: String, description: String! = nil) {
        let appIcon = Image(nsImage: NSApplication.shared.applicationIconImage)

        var infoView: some View {
            HStack {
                if let icon = icon {
                    icon
                        .resizable()
                        .foregroundStyle(iconColor)
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
                    }
                }

                Spacer()
            }
            .frame(height: 40)
            .padding(15)
        }
        super.init(type: .expanded, content:  AnyView(infoView))
    }
}
