//
//  DynamicNotchInfoWindow.swift
//  DynamicNotchKit
//
//  Created by Kai Azim on 2023-08-25.
//

import SwiftUI

internal final class DynamicNotchInfoPublisher<IconView>: ObservableObject where IconView: View {
    @Published var iconView: IconView?
    @Published var iconColor: Color
    @Published var title: String
    @Published var description: String?
    @Published var textColor: Color

    init(icon: Image?, iconColor: Color, title: String, description: String? = nil, textColor: Color) where IconView == Image {
        self.iconView = icon
        self.iconColor = iconColor
        self.title = title
        self.description = description
        self.textColor = textColor
    }

    init(title: String, description: String? = nil, textColor: Color, iconView: (() -> IconView)?) {
        self.title = title
        self.description = description
        self.textColor = textColor
        self.iconColor = .clear
        self.iconView = iconView?()
    }

    @MainActor
    func publish(icon: Image?, iconColor: Color, title: String, description: String?, textColor: Color) where IconView == Image {
        self.iconView = icon
        self.iconColor = iconColor
        self.title = title
        self.description = description
        self.textColor = textColor
    }

    @MainActor
    func publish(icon: IconView?, title: String, description: String?) {
        self.title = title
        self.description = description
        self.iconView = iconView
    }
}

public class DynamicNotchInfo<IconView> where IconView: View {
    private var internalDynamicNotch: DynamicNotch<InfoView>
    private let publisher: DynamicNotchInfoPublisher<IconView>

    public init(contentID: UUID = .init(), icon: Image! = nil, title: String, description: String? = nil, iconColor: Color = .white, textColor: Color = .white, style: DynamicNotch<InfoView>.Style = .auto) where IconView == Image {
        let publisher = DynamicNotchInfoPublisher(icon: icon, iconColor: iconColor, title: title, description: description, textColor: textColor)
        self.publisher = publisher
        internalDynamicNotch = DynamicNotch(contentID: contentID, style: style) {
            InfoView(publisher: publisher)
        }
    }

    public init(contentID: UUID = .init(), title: String, description: String? = nil, textColor: Color = .white, style: DynamicNotch<InfoView>.Style = .auto, iconView: (() -> IconView)? = nil) {
        let publisher = DynamicNotchInfoPublisher<IconView>(title: title, description: description, textColor: textColor, iconView: iconView)
        self.publisher = publisher
        internalDynamicNotch = DynamicNotch(contentID: contentID, style: style) {
            InfoView(publisher: publisher)
        }
    }

    @MainActor
    public func setContent(contentID: UUID = .init(), icon: Image? = nil, title: String, description: String? = nil, iconColor: Color = .white, textColor: Color = .white) where IconView == Image {
        withAnimation {
            publisher.publish(icon: icon, iconColor: iconColor, title: title, description: description, textColor: textColor)
        }
    }

    @MainActor
    public func setContent(contentID: UUID = .init(), title: String, description: String? = nil, iconView: IconView? = nil) {
        withAnimation {
            publisher.publish(icon: iconView, title: title, description: description)
        }
    }

    public func show(on screen: NSScreen = NSScreen.screens[0], for time: Double = 0) {
        internalDynamicNotch.show(on: screen, for: time)
    }

    public func hide() {
        internalDynamicNotch.hide()
    }

    public func toggle() {
        internalDynamicNotch.toggle()
    }
}

public extension DynamicNotchInfo {
    struct InfoView: View {
        private var publisher: DynamicNotchInfoPublisher<IconView>

        init(publisher: DynamicNotchInfoPublisher<IconView>) {
            self.publisher = publisher
        }

        public var body: some View {
            HStack(spacing: 10) {
                InfoImageView(publisher: publisher)
                InfoTextView(publisher: publisher)
                Spacer(minLength: 0)
            }
            .frame(height: 40)
        }
    }

    struct InfoImageView: View {
        @ObservedObject private var publisher: DynamicNotchInfoPublisher<IconView>

        init(publisher: DynamicNotchInfoPublisher<IconView>) {
            self.publisher = publisher
        }

        public var body: some View {
            if let image = publisher.iconView as? Image {
                image
                    .resizable()
                    .foregroundStyle(publisher.iconColor)
                    .padding(3)
                    .scaledToFit()
            } else if let iconView = publisher.iconView {
                iconView
            } else {
                Image(nsImage: NSApplication.shared.applicationIconImage)
                    .resizable()
                    .padding(-5)
                    .scaledToFit()
            }
        }
    }

    struct InfoTextView: View {
        @ObservedObject private var publisher: DynamicNotchInfoPublisher<IconView>

        init(publisher: DynamicNotchInfoPublisher<IconView>) {
            self.publisher = publisher
        }

        public var body: some View {
            VStack(alignment: .leading, spacing: publisher.description != nil ? nil : 0) {
                Text(publisher.title)
                    .font(.headline)
                    .foregroundStyle(publisher.textColor)
                Text(publisher.description ?? "")
                    .font(.caption2)
                    .foregroundStyle(publisher.textColor.opacity(0.8))
                    .opacity(publisher.description != nil ? 1 : 0)
                    .frame(maxHeight: publisher.description != nil ? nil : 0)
            }
        }
    }
}

struct DynamicNotchInfo_Previews: PreviewProvider {
    static let publisher = DynamicNotchInfoPublisher(icon: nil, iconColor: .blue, title: "testing", textColor: .black)
    static var previews: some View {
        VStack {
            DynamicNotchInfo.InfoView(publisher: publisher)
        }
    }
}
