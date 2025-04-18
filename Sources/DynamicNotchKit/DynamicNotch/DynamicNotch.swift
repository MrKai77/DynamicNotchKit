//
//  DynamicNotch.swift
//  DynamicNotchKit
//
//  Created by Kai Azim on 2023-08-24.
//

import SwiftUI

// MARK: - DynamicNotch

/// A flexible custom notch-styled window that can be shown on the screen.
@MainActor
public class DynamicNotch<Content>: ObservableObject where Content: View {
    public var windowController: NSWindowController? // Public in case user wants to modify the underlying NSPanel

    /// Content Properties
    @Published var content: () -> Content
    @Published var contentID: UUID
    @Published var isVisible: Bool = false // Used to animate the fading in/out of the user's view

    /// Notch Size
    @Published var notchSize: CGSize = .zero

    /// Notch Closing Properties
    @Published var isMouseInside: Bool = false // If the mouse is inside, the notch will not auto-hide

    private var hideTask: Task<Void, Never>? // Used to cancel the hide task if the mouse is inside
    private var closePanelTask: Task<Void, Never>? // Used to close the panel after hiding completes
    
    /// Notch Style
    private(set) var notchStyle: DynamicNotchStyle = .auto

    /// This is a timer to de-init the window after closing.
    /// Note that it's slightly longer than the animation duration, which should allow for some extra leeway.
    private var maxAnimationDuration: Double = 0.8

    /// Makes a new DynamicNotch with custom content and style.
    /// - Parameters:
    ///   - contentID: the ID of the content. If unspecified, a new ID will be generated. This helps to differentiate between different contents.
    ///   - style: the popover's style. If unspecified, the style will be automatically set according to the screen (notch or floating).
    ///   - content: a SwiftUI View to be shown in the popup.
    public init(
        contentID: UUID = .init(),
        style: DynamicNotchStyle = .auto,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.contentID = contentID
        self.content = content
        self.notchStyle = style
        
        observeScreenParameters()
    }
    
    private func observeScreenParameters() {
        Task {
            let sequence = NotificationCenter.default.notifications(named: NSApplication.didChangeScreenParametersNotification)
            for await notification in sequence.map(\.name) {
                if let screen = NSScreen.screens.first {
                    await initializeWindow(screen: screen)
                }
            }
        }
    }
}

// MARK: - Public

public extension DynamicNotch {
    /// Set this DynamicNotch's content.
    /// - Parameters:
    ///   - contentID: the ID of the content. If unspecified, a new ID will be generated. This helps to differentiate between different contents.
    ///   - content: a SwiftUI View to be shown in the popup.
    func setContent(
        contentID _: UUID = .init(),
        content: @escaping () -> Content
    ) {
        self.content = content
        contentID = .init()
    }

    /// Show the DynamicNotch.
    /// - Parameters:
    ///   - screen: screen to show on. Default is the primary screen, which generally contains the notch on MacBooks.
    ///   - duration: duration for which the notch will be shown. If 0, the DynamicNotch will stay visible until `hide()` is called.
    func show(
        on screen: NSScreen = NSScreen.screens[0],
        for duration: Duration = .zero
    ) {
        let seconds = Double(duration.components.seconds)

        func scheduleHide(_ time: Double) {
            hideTask?.cancel()
            hideTask = Task {
                try? await Task.sleep(for: .seconds(time))
                guard Task.isCancelled != true else { return }
                await hide()
            }
        }

        guard !isVisible else {
            if seconds > 0 {
                scheduleHide(seconds)
            }
            return
        }

        closePanelTask?.cancel()
        initializeWindow(screen: screen)

        Task {
            self.isVisible = true
        }

        if seconds != 0 {
            scheduleHide(seconds)
        }
    }

    /// Hide the popup.
    /// - Parameter ignoreMouse: if true, the popup will hide even if the mouse is inside the notch area.
    func hide(ignoreMouse: Bool = false) {
        guard isVisible else { return }

        if !ignoreMouse, isMouseInside {
            Task {
                try? await Task.sleep(for: .seconds(0.1))
                hide()
            }
            return
        }

        isVisible = false

        closePanelTask?.cancel()
        closePanelTask = Task {
            try? await Task.sleep(for: .seconds(maxAnimationDuration))
            guard Task.isCancelled != true else { return }
            await deinitializeWindow()
        }
    }

    /// Toggles the popup's visibility.
    func toggle() {
        if isVisible {
            hide()
        } else {
            show()
        }
    }

    /// Check if the cursor is inside the screen's notch area.
    ///
    /// This function may be useful to evaluate whether the `DynamicNotch` should be shown or hidden.
    /// - Returns: If the cursor is inside the notch area.
    static func checkIfMouseIsInNotch() -> Bool {
        guard let screen = NSScreen.screenWithMouse else {
            return false
        }

        return screen.notchFrameWithMenubarAsBackup.contains(NSEvent.mouseLocation)
    }
}

// MARK: - Window Management

private extension DynamicNotch {
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

        let size = NSSize(
            width: screen.frame.width / 2,
            height: screen.frame.height / 2
        )
        let origin = NSPoint(
            x: screen.frame.midX - (size.width / 2),
            y: screen.frame.maxY - size.height
        )

        panel.setFrame(
            NSRect(
                origin: origin,
                size: size
            ),
            display: false
        )

        windowController = .init(window: panel)
    }

    func deinitializeWindow() {
        guard let windowController else { return }
        windowController.close()
        self.windowController = nil
    }
}
