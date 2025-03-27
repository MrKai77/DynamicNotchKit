//
//  DynamicNotch.swift
//  DynamicNotchKit
//
//  Created by Kai Azim on 2023-08-24.
//

import Combine
import SwiftUI

// MARK: - DynamicNotchStyle

public enum DynamicNotchStyle: Int {
    case notch
    case floating
    case auto
}

// MARK: - DynamicNotch

public class DynamicNotch<Content>: ObservableObject where Content: View {
    public var windowController: NSWindowController? // Make public in case user wants to modify the NSPanel

    // Content Properties
    @Published var content: () -> Content
    @Published var contentID: UUID
    @Published var isVisible: Bool = false // Used to animate the fading in/out of the user's view

    // Notch Size
    @Published var notchSize: CGSize = .zero

    // Notch Closing Properties
    @Published var isMouseInside: Bool = false // If the mouse is inside, the notch will not auto-hide
    private var timer: Timer?
    private var workItem: DispatchWorkItem?
    private var subscription: AnyCancellable?

    // Notch Style
    private var notchStyle: DynamicNotchStyle = .notch

    private var maxAnimationDuration: Double = 0.8 // This is a timer to de-init the window after closing

    var animation: Animation {
        if #available(macOS 14.0, *), notchStyle == .notch {
            Animation.spring(.bouncy(duration: 0.4))
        } else {
            Animation.timingCurve(0.16, 1, 0.3, 1, duration: 0.7)
        }
    }

    /// Makes a new DynamicNotch with custom content and style.
    /// - Parameters:
    ///   - content: A SwiftUI View
    ///   - style: The popover's style. If unspecified, the style will be automatically set according to the screen.
    public init(
        contentID: UUID = .init(),
        style: DynamicNotchStyle = .auto,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.contentID = contentID
        self.content = content
        self.notchStyle = style
        self.subscription = NotificationCenter.default
            .publisher(for: NSApplication.didChangeScreenParametersNotification)
            .sink { [weak self] _ in
                guard let self, let screen = NSScreen.screens.first else { return }
                initializeWindow(screen: screen)
            }
    }
}

// MARK: - Public

public extension DynamicNotch {
    /// Set this DynamicNotch's content.
    /// - Parameter content: A SwiftUI View
    func setContent(
        contentID _: UUID = .init(),
        content: @escaping () -> Content
    ) {
        self.content = content
        contentID = .init()
    }

    /// Show the DynamicNotch.
    /// - Parameters:
    ///   - screen: Screen to show on. Default is the primary screen.
    ///   - time: Time to show in seconds. If 0, the DynamicNotch will stay visible until `hide()` is called.
    func show(
        on screen: NSScreen = NSScreen.screens[0],
        for time: Double = 0
    ) {
        func scheduleHide(_ time: Double) {
            let workItem = DispatchWorkItem { self.hide() }
            self.workItem = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + time, execute: workItem)
        }

        guard !isVisible else {
            if time > 0 {
                workItem?.cancel()
                scheduleHide(time)
            }
            return
        }
        timer?.invalidate()

        initializeWindow(screen: screen)

        DispatchQueue.main.async {
            withAnimation(self.animation) {
                self.isVisible = true
            }
        }

        if time != 0 {
            workItem?.cancel()
            scheduleHide(time)
        }
    }

    /// Hide the DynamicNotch.
    func hide(ignoreMouse: Bool = false) {
        guard isVisible else { return }

        if !ignoreMouse, isMouseInside {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.hide()
            }
            return
        }

        withAnimation(animation) {
            self.isVisible = false
        }

        timer = Timer.scheduledTimer(withTimeInterval: maxAnimationDuration, repeats: false) { _ in
            self.deinitializeWindow()
        }
    }

    /// Toggle the DynamicNotch's visibility.
    func toggle() {
        if isVisible {
            hide()
        } else {
            show()
        }
    }

    /// Check if the cursor is inside the screen's notch area.
    /// - Returns: If the cursor is inside the notch area.
    static func checkIfMouseIsInNotch() -> Bool {
        guard let screen = NSScreen.screenWithMouse else {
            return false
        }

        return screen.notchFrameWithMenubarAsBackup.contains(NSEvent.mouseLocation)
    }
}

// MARK: - Private

extension DynamicNotch {
    func initializeWindow(screen: NSScreen) {
        // so that we don't have a duplicate window
        deinitializeWindow()

        notchSize = screen.notchFrameWithMenubarAsBackup.size

        let view: NSView = switch notchStyle {
        case .notch: NSHostingView(rootView: NotchView(dynamicNotch: self).foregroundStyle(.white))
        case .floating: NSHostingView(rootView: NotchlessView(dynamicNotch: self))
        case .auto: screen.hasNotch ? NSHostingView(rootView: NotchView(dynamicNotch: self).foregroundStyle(.white)) : NSHostingView(rootView: NotchlessView(dynamicNotch: self))
        }

        let panel = DynamicNotchPanel(
            contentRect: .zero,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: true
        )
        panel.contentView = view
        panel.orderFrontRegardless()
        panel.setFrame(screen.frame, display: false)

        windowController = .init(window: panel)
    }

    func deinitializeWindow() {
        guard let windowController else { return }
        windowController.close()
        self.windowController = nil
    }
}
