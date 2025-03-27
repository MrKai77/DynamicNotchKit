//
//  DynamicNotchProgress.swift
//  DynamicNotchKit
//
//  Created by Kai Azim on 2024-08-30.
//

import SwiftUI

public class DynamicNotchProgress: ObservableObject {
    private var internalDynamicNotch: DynamicNotch<InfoView>!

    @Published public var progress: Binding<CGFloat>
    @Published private(set) var progressBarOverlay: (() -> AnyView)? // Use setProgressBarOverlay to set the overlay
    @Published public var progressBarColor: Color?
    @Published public var title: String
    @Published public var description: String?
    @Published public var textColor: Color?

    public init(
        contentID: UUID = .init(),
        progress: Binding<CGFloat>,
        title: String,
        description: String? = nil,
        style: DynamicNotchStyle = .auto
    ) {
        self.progress = progress
        self.title = title
        self.description = description
        self.internalDynamicNotch = DynamicNotch(contentID: contentID, style: style) {
            InfoView(dynamicNotch: self)
        }
    }

    public func setProgressBarOverlay(_ overlay: @escaping () -> some View) {
        progressBarOverlay = { AnyView(overlay()) }
    }

    public func show(
        on screen: NSScreen = NSScreen.screens[0],
        for duration: Duration = .zero
    ) {
        internalDynamicNotch.show(on: screen, for: duration)
    }

    public func hide() {
        internalDynamicNotch.hide()
    }

    public func toggle() {
        internalDynamicNotch.toggle()
    }
}

extension DynamicNotchProgress {
    struct InfoView: View {
        @Environment(\.notchStyle) private var notchStyle
        @ObservedObject var dynamicNotch: DynamicNotchProgress

        init(dynamicNotch: DynamicNotchProgress) {
            self.dynamicNotch = dynamicNotch
        }

        public var body: some View {
            HStack(spacing: 10) {
                ProgressRing(
                    to: dynamicNotch.progress,
                    color: dynamicNotch.progressBarColor ?? (notchStyle == .notch ? .white : .primary)
                )
                .overlay {
                    if let iconOverlay = dynamicNotch.progressBarOverlay {
                        iconOverlay()
                    }
                }
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

    struct ProgressRing: View {
        @Binding var target: CGFloat
        let color: Color
        let thickness: CGFloat

        @State private var isLoaded = false

        public init(to target: Binding<CGFloat>, color: Color = .white, thickness: CGFloat = 5) {
            self._target = target
            self.color = color
            self.thickness = thickness
        }

        public var body: some View {
            Circle()
                .stroke(style: StrokeStyle(lineWidth: thickness))
                .foregroundStyle(.tertiary)
                .overlay {
                    // Foreground ring
                    if #available(macOS 13.0, *) {
                        Circle()
                            .trim(from: 0, to: isLoaded ? target : 0)
                            .stroke(
                                color.gradient, // Gradient is only available on macOS 13+
                                style: StrokeStyle(
                                    lineWidth: thickness,
                                    lineCap: .round
                                )
                            )
                            .opacity(isLoaded ? 1 : 0)
                    } else {
                        Circle()
                            .trim(from: 0, to: isLoaded ? target : 0)
                            .stroke(
                                color,
                                style: StrokeStyle(
                                    lineWidth: thickness,
                                    lineCap: .round
                                )
                            )
                            .opacity(isLoaded ? 1 : 0)
                    }
                }
                .rotationEffect(.degrees(-90))
                .padding(thickness / 2)
                .task {
                    withAnimation(Animation.timingCurve(0.22, 1, 0.36, 1, duration: 1)) {
                        isLoaded = true
                    }
                }
        }
    }
}
