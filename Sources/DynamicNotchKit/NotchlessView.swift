//
//  NotchlessView.swift
//
//
//  Created by Kai Azim on 2024-04-06.
//

import SwiftUI

struct NotchlessView: View {
    @ObservedObject var dynamicNotch: DynamicNotch
    @State var height: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Spacer()

                self.dynamicNotch.content
                    .padding(20)
                    .fixedSize()
                    .onHover { hovering in
                        dynamicNotch.isMouseInside = hovering
                    }
                    .background {
                        VisualEffectView(material: .popover, blendingMode: .behindWindow)
                            .overlay {
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .strokeBorder(.quaternary, lineWidth: 1)
                            }
                    }
                    .clipShape(.rect(cornerRadius: 20))
                    .shadow(color: .black.opacity(0.5), radius: self.dynamicNotch.isVisible ? 10 : 0)
                    .padding(10)
                    .background {
                        GeometryReader { geo in
                            Color.clear
                                .onAppear {
                                    height = -geo.size.height
                                }
                        }
                    }

                    .offset(y: self.dynamicNotch.isVisible ? 0 : height)

                Spacer()
            }
            Spacer()
        }
    }
}
