//
//  ProgressRing.swift
//
//
//  Created by Kai Azim on 2024-04-06.
//

import SwiftUI

@available(macOS 13.0, *)
/// An animated circular progress ring. Made to be used with DynamicNotchInfo.
public struct ProgressRing: View {
    @State var isLoaded = false

    @Binding var target: CGFloat
    let color: Color
    let thickness: CGFloat

    public init(to target: Binding<CGFloat>, color: Color = .white, thickness: CGFloat = 4) {
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
                Circle()
                    .trim(from: 0, to: isLoaded ? target : 0)
                    .stroke(
                        color.gradient,
                        style: StrokeStyle(
                            lineWidth: thickness,
                            lineCap: .round
                        )
                    )
                    .opacity(isLoaded ? 1 : 0)
            }
            .rotationEffect(.degrees(-90))
            .padding(thickness / 2)
            .onAppear {
                DispatchQueue.main.async {
                    withAnimation(Animation.timingCurve(0.22, 1, 0.36, 1, duration: 1)) {
                        isLoaded = true
                    }
                }
            }
    }
}
