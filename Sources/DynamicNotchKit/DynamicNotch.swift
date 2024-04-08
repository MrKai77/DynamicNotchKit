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
    @Published var isMouseInside: Bool = false
    @Published var notchWidth: CGFloat = 0
    @Published var notchHeight: CGFloat = 0
    @Published var notchStyle: Style = .notch

    private var timer: Timer?
    private let animationDuration: Double = 0.4

    private let animation = Animation.timingCurve(0.16, 1, 0.3, 1, duration: 0.7)

    // If true, DynamicNotchKit will use the .notch/.floating style according to the screen.
    private let autoManageNotchStyle: Bool
    public enum Style {
        case notch
        case floating
    }

    public init<Content: View>(content: Content, style: DynamicNotch.Style! = nil) {
        self.content = AnyView(content)

        if style == nil {
            self.autoManageNotchStyle = true
        } else {
            self.autoManageNotchStyle = false
            self.notchStyle = style
        }
    }

    // MARK: Public methods
    public func setContent<Content: View>(content: Content) {
        self.content = AnyView(content)
        if let windowController = self.windowController {
            windowController.window?.contentView = NSHostingView(rootView: NotchView(dynamicNotch: self))
        }
    }

    @discardableResult
    public func show(on screen: NSScreen = NSScreen.screens[0], for time: Double = 0) -> Bool {
        if self.isVisible {
            return false    // Window already exists
        }
        timer?.invalidate()

        self.initializeWindow(screen: screen)

        DispatchQueue.main.async {
            withAnimation(self.animation) {
                self.isVisible = true
            }
        }

        if time != 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + time) {
                self.hide()
            }
        }

        return true
    }

    @discardableResult
    public func hide() -> Bool {
        guard self.isVisible else {
            return false
        }

        guard !self.isMouseInside else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.hide()
            }
            return false
        }

        withAnimation(self.animation) {
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

    public func toggle() {
        if self.isVisible {
            self.hide()
        } else {
            self.show()
        }
    }

    public static func checkIfMouseIsInNotch() -> Bool {
        guard let screen = NSScreen.screenWithMouse else {
            return false
        }
        let notchSize = DynamicNotch.getNotchSize(screen: screen)

        let notchRect: NSRect = .init(
            x: screen.frame.midX - (notchSize.width / 2),
            y: screen.frame.maxY - notchSize.height,
            width: notchSize.width,
            height: notchSize.height
        )

        return NSMouseInRect(NSEvent.mouseLocation, notchRect, true)
    }

    // MARK: Private methods
    private static func getNotchSize(screen: NSScreen) -> CGSize {
        if let topLeftNotchpadding: CGFloat = screen.auxiliaryTopLeftArea?.width,
           let topRightNotchpadding: CGFloat = screen.auxiliaryTopRightArea?.width {

            let notchHeight = screen.safeAreaInsets.top
            let notchWidth = screen.frame.width - topLeftNotchpadding - topRightNotchpadding + 10 // 10 is for the top rounded part of the notch
            return .init(width: notchWidth, height: notchHeight)
        } else {
            // here we assign the menubar height, so that the method checkIfMouseIsInNotch still works
            let notchHeight = screen.frame.height - screen.visibleFrame.height
            let notchWidth: CGFloat = 500
            return .init(width: notchWidth, height: notchHeight)
        }
    }

    private func refreshNotchSize(_ screen: NSScreen) {
        if self.autoManageNotchStyle {
            if let topLeftNotchpadding: CGFloat = screen.auxiliaryTopLeftArea?.width,
               let topRightNotchpadding: CGFloat = screen.auxiliaryTopRightArea?.width {
                self.notchStyle = .notch
            } else {
                self.notchStyle = .floating
            }
        }

        let notchSize = DynamicNotch.getNotchSize(screen: screen)
        self.notchWidth = notchSize.width
        self.notchHeight = notchSize.height
    }

    private func initializeWindow(screen: NSScreen) {
        if let windowController = windowController {
            windowController.window?.orderFrontRegardless()
            return
        }
        self.refreshNotchSize(screen)

        var view: NSView = NSHostingView(rootView: NotchView(dynamicNotch: self))

        if self.notchStyle == .floating {
            view = NSHostingView(rootView: NotchlessView(dynamicNotch: self))
        }

        let panel = NSPanel(
            contentRect: .zero,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: true
        )
        panel.hasShadow = false
        panel.backgroundColor = NSColor.white.withAlphaComponent(0.00001)
        panel.level = .screenSaver
        panel.collectionBehavior = .canJoinAllSpaces
        panel.contentView = view
        panel.orderFrontRegardless()

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
}
