//
//  NotchView.swift
//
//
//  Created by Kai Azim on 2023-08-24.
//

import SwiftUI

struct NotchView: View {
    @ObservedObject var dynamicNotch: DynamicNotch
    @State var notchSize: NSSize = .zero

    @State private var isInfo: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Spacer()

                VStack(spacing: 0) {
                    Spacer()
                        .frame(width: self.notchSize.width + 20, height: self.notchSize.height)
                        // We add an extra 20 here because the corner radius of the top increases when shown.
                        // (the remaining 10 has already been accounted for in refreshNotchSize)

                    self.dynamicNotch.content
                        .blur(radius: self.dynamicNotch.isVisible ? 0 : 10)
                        .scaleEffect(self.dynamicNotch.isVisible ? 1 : 0.8)
                        .padding(.horizontal, 15)    // Small corner radius of the TOP of the notch
                        .frame(minHeight: 20)
                        .padding(.top, self.isInfo ? -20 : 0)
                }
                .fixedSize()
                .frame(minWidth: self.notchSize.width)
                .onHover { hovering in
                    dynamicNotch.isMouseInside = hovering
                }
                .background {
                    Rectangle()
                        .foregroundStyle(.black)
                        .padding(-50)   // The opening/closing animation can overshoot, so this makes sure that it's still black
                }
                .mask {
                    GeometryReader { _ in   // This helps with positioning everything
                        HStack {
                            Spacer(minLength: 0)
                            NotchShape(cornerRadius: self.dynamicNotch.isVisible ? 20 : nil)
                                .frame(
                                    width: self.dynamicNotch.isVisible ? nil : self.notchSize.width,
                                    height: self.dynamicNotch.isVisible ? nil : self.notchSize.height
                                )
                            Spacer(minLength: 0)
                        }
                    }
                }
                .shadow(color: .black.opacity(0.5), radius: self.dynamicNotch.isVisible ? 10 : 0)

                Spacer()
            }
            Spacer()
        }
        .onAppear {
            self.notchSize = .init(
                width: self.dynamicNotch.notchWidth,
                height: self.dynamicNotch.notchHeight
            )

            if self.dynamicNotch as? DynamicNotchInfo != nil {
                self.isInfo = true
            }
        }
    }
}
