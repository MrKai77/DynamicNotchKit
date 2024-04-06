//
//  DynamicNotch.swift
//
//
//  Created by Kai Azim on 2023-08-24.
//

import SwiftUI

public class DynamicNotch: ObservableObject {
    public var content: AnyView
    public var windowController: NSWindowController? // In case user wants to modify the NSPanel

    @Published public var isVisible: Bool = false
    @Published public var notchWidth: CGFloat = 0
    @Published public var notchHeight: CGFloat = 0

    private var timer: Timer?
    private let animationDuration: Double = 0.4

    public init<Content: View>(content: Content) {
        self.content = AnyView(content)
    }

    public func setContent<Content: View>(content: Content) {
        self.content = AnyView(content)
        if let windowController = self.windowController {
            windowController.window?.contentView = NSHostingView(rootView: NotchView(dynamicNotch: self))
        }
    }

    @discardableResult
    public func show() -> Bool {
        if self.isVisible {
            return false    // Window already exists
        }
        timer?.invalidate()

        self.initializeWindow()

        DispatchQueue.main.async {
            if #available(macOS 14.0, *) {
                withAnimation(.spring(.bouncy(duration: self.animationDuration))) {
                    self.isVisible = true
                }
            } else {
                // TODO: Support MacOS Ventura & below
                self.isVisible = true
            }
        }

        return true
    }

    public func show(for time: Double) {
        self.show()
        DispatchQueue.main.asyncAfter(deadline: .now() + time) {
            self.hide()
        }
    }

    @discardableResult
    public func hide() -> Bool {
        if !self.isVisible {
            return false
        }
        if #available(macOS 14.0, *) {
            withAnimation(.spring(.smooth(duration: self.animationDuration))) {
                self.isVisible = false
            }
        } else {
            // TODO: Support MacOS Ventura & below
            self.isVisible = false
        }

        self.timer = Timer.scheduledTimer(
            withTimeInterval: self.animationDuration * 2,
            repeats: false
        ) { _ in
            self.deinitializeWindow()
        }

        return true
    }

    public func toggleVisibility() {
        if self.isVisible {
            self.hide()
        } else {
            self.show()
        }
    }

    private func initializeWindow() {
        if let windowController = windowController {
            windowController.window?.orderInFrontOfSpaces()
            return
        }
        guard let screen = NSScreen.main else { return }
        self.refreshNotchSize(screen)

        let panel = NSPanel(
            contentRect: .zero,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: true,
            screen: NSApp.keyWindow?.screen
        )
        panel.hasShadow = false
        panel.backgroundColor = NSColor.white.withAlphaComponent(0.00001)
        panel.level = .screenSaver
        panel.collectionBehavior = .canJoinAllSpaces
        panel.contentView = NSHostingView(rootView: NotchView(dynamicNotch: self))
        panel.orderInFrontOfSpaces()

        panel.setFrame(
            NSRect(
                x: screen.frame.origin.x,
                y: screen.frame.origin.y,
                width: screen.frame.width,
                height: screen.frame.height
            ),
            display: false
        )

        self.windowController = .init(window: panel)
    }

    private func deinitializeWindow() {
        guard let windowController = windowController else { return }
        windowController.close()
        self.windowController = nil
    }

    private func refreshNotchSize(_ screen: NSScreen) {
        let topLeftNotchpadding: CGFloat = screen.auxiliaryTopLeftArea?.width ?? 0
        let topRightNotchpadding: CGFloat = screen.auxiliaryTopRightArea?.width ?? 0

        self.notchHeight = screen.safeAreaInsets.top
        self.notchWidth = screen.frame.width - topLeftNotchpadding - topRightNotchpadding + 10 // 10 is for the top rounded part of the notch
    }
}
