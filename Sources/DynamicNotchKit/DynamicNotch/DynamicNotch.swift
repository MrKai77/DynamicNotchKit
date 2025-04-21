//
//  DynamicNotch.swift
//  DynamicNotchKit
//
//  Created by Kai Azim on 2023-08-24.
//

import SwiftUI

// MARK: - DynamicNotch

/// A flexible custom notch-styled window that can be shown on the screen.
public final class DynamicNotch<Expanded, CompactLeading, CompactTrailing>: ObservableObject, DynamicNotchControllable where Expanded: View, CompactLeading: View, CompactTrailing: View {
    /// Public in case user wants to modify the underlying NSPanel
    public var windowController: NSWindowController?

    /// Notch Options
    public let style: DynamicNotchStyle
    public let hoverBehavior: DynamicNotchHoverBehavior
    @Published public var state: DynamicNotchState = .hidden

    /// Content
    let expandedContent: Expanded
    let compactLeadingContent: CompactLeading
    let compactTrailingContent: CompactTrailing
    @Published var disableCompactLeading: Bool = false
    @Published var disableCompactTrailing: Bool = false

    /// Notch Properties
    @Published private(set) var notchSize: CGSize = .zero
    @Published private(set) var menubarHeight: CGFloat = 0
    @Published private(set) var isHovering: Bool = false

    private var closePanelTask: Task<(), Never>? // Used to close the panel after hiding completes

    /// Creates a new DynamicNotch with custom content and style.
    /// - Parameters:
    ///   - hoverBehavior: defines the hover behavior of the notch, which allows for different interactions such as haptic feedback, increased shadow etc.
    ///   - style: the popover's style. If unspecified, the style will be automatically set according to the screen (notch or floating).
    ///   - expanded: a SwiftUI View to be shown in the expanded state of the notch.
    ///   - compactLeading: a SwiftUI View to be shown in the compact leading state of the notch.
    ///   - compactTrailing: a SwiftUI View to be shown in the compact trailing state of the notch.
    public init(
        hoverBehavior: DynamicNotchHoverBehavior = .all,
        style: DynamicNotchStyle = .auto,
        @ViewBuilder expanded: @escaping () -> Expanded,
        @ViewBuilder compactLeading: @escaping () -> CompactLeading,
        @ViewBuilder compactTrailing: @escaping () -> CompactTrailing
    ) {
        self.hoverBehavior = hoverBehavior
        self.style = style

        self.expandedContent = expanded()
        self.compactLeadingContent = compactLeading()
        self.compactTrailingContent = compactTrailing()

        observeScreenParameters()
    }

    /// Creates a new DynamicNotch with custom content and style. Does not support the compact appearance.
    /// - Parameters:
    ///   - hoverBehavior: defines the hover behavior of the notch, which allows for different interactions such as haptic feedback, increased shadow etc.
    ///   - style: the popover's style. If unspecified, the style will be automatically set according to the screen (notch or floating).
    ///   - expanded: a SwiftUI View to be shown in the expanded state of the notch.
    public convenience init(
        hoverBehavior: DynamicNotchHoverBehavior = [.keepVisible],
        style: DynamicNotchStyle = .auto,
        @ViewBuilder expanded: @escaping () -> Expanded
    ) where CompactLeading == EmptyView, CompactTrailing == EmptyView {
        self.init(
            hoverBehavior: hoverBehavior,
            style: style,
            expanded: expanded,
            compactLeading: { EmptyView() },
            compactTrailing: { EmptyView() }
        )
        self.disableCompactLeading = true
        self.disableCompactTrailing = true
    }

    /// Observes screen parameters changes and re-initializes the window if necessary.
    private func observeScreenParameters() {
        Task {
            let sequence = NotificationCenter.default.notifications(named: NSApplication.didChangeScreenParametersNotification)
            for await _ in sequence.map(\.name) {
                if let screen = NSScreen.screens.first {
                    initializeWindow(screen: screen)
                }
            }
        }
    }

    /// Updates the hover state of the DynamicNotch, and processes necessary hover behavior.
    /// - Parameter hovering: a boolean indicating whether the mouse is hovering over the notch.
    func updateHoverState(_ hovering: Bool) {
        // Ensure that we only update when the state changes
        guard state != .hidden, hovering != isHovering else { return }

        isHovering = hovering

        if hoverBehavior.contains(.hapticFeedback) {
            let performer = NSHapticFeedbackManager.defaultPerformer
            performer.perform(.alignment, performanceTime: .default)
        }
    }
}

// MARK: - Public

extension DynamicNotch {
    public func expand(on screen: NSScreen = NSScreen.screens[0]) async {
        await _expand(on: screen, skipHide: false)
    }

    func _expand(on screen: NSScreen = NSScreen.screens[0], skipHide: Bool) async {
        guard state != .expanded else { return }

        closePanelTask?.cancel()
        if state == .hidden {
            initializeWindow(screen: screen)
        }

        Task {
            if state != .hidden {
                if !skipHide {
                    withAnimation(style.closingAnimation) {
                        self.state = .hidden
                    }
                    
                    guard self.state == .hidden else { return }
                    
                    try? await Task.sleep(for: .seconds(0.25))
                }

                withAnimation(style.conversionAnimation) {
                    self.state = .expanded
                }
            } else {
                withAnimation(style.openingAnimation) {
                    self.state = .expanded
                }
            }
        }
        
        // This is the time it takes for the animation to complete
        // See DynamicNotchStyle's animations
        try? await Task.sleep(for: .seconds(0.4))
    }
    
    public func compact(on screen: NSScreen) async {
        await _compact(on: screen, skipHide: false)
    }

    func _compact(on screen: NSScreen = NSScreen.screens[0], skipHide: Bool) async {
        guard state != .compact else { return }

        if effectiveStyle(for: screen).isFloating {
            await hide()
            return
        }

        if disableCompactLeading, disableCompactTrailing {
            await hide()
            return
        }

        closePanelTask?.cancel()
        if state == .hidden {
            initializeWindow(screen: screen)
        }

        Task {
            if state != .hidden {
                if !skipHide {
                    withAnimation(style.closingAnimation) {
                        self.state = .hidden
                    }
                    
                    try? await Task.sleep(for: .seconds(0.25))
                    
                    guard self.state == .hidden else { return }
                }

                withAnimation(style.conversionAnimation) {
                    self.state = .compact
                }
            } else {
                withAnimation(style.openingAnimation) {
                    self.state = .compact
                }
            }
        }
        
        // This is the time it takes for the animation to complete
        // See DynamicNotchStyle's animations
        try? await Task.sleep(for: .seconds(0.4))
    }
    
    public func hide() async {
        await withCheckedContinuation { continuation in
            _hide {
                continuation.resume()
            }
        }
    }
    
    /// Hides the popup, with a completion handler when the animation is completed.
    func _hide(completion: (() -> ())? = nil) {
        guard state != .hidden else {
            completion?()
            return
        }

        if hoverBehavior.contains(.keepVisible), isHovering {
            Task {
                try? await Task.sleep(for: .seconds(0.1))
                _hide(completion: completion)
            }
            return
        }

        withAnimation(style.closingAnimation) {
            state = .hidden
            isHovering = false
        }

        closePanelTask?.cancel()
        closePanelTask = Task {
            try? await Task.sleep(for: .seconds(0.4)) // Wait for animation to complete
            guard Task.isCancelled != true else { return }
            deinitializeWindow()
            completion?()
        }
    }
}

// MARK: - Window Management

private extension DynamicNotch {
    /// Determines the effective style for a selected screen.
    /// - Parameter screen: the screen to check for a notch.
    /// - Returns: the effective style for the screen.
    func effectiveStyle(for screen: NSScreen) -> DynamicNotchStyle {
        if style == .auto {
            return screen.hasNotch ? .notch : .floating
        }
        return style
    }

    /// Initializes the window for the DynamicNotch.
    /// - Parameter screen: the screen to initialize the window on.
    func initializeWindow(screen: NSScreen) {
        // so that we don't have a duplicate window
        deinitializeWindow()

        notchSize = screen.notchFrameWithMenubarAsBackup.size
        menubarHeight = screen.menubarHeight

        let style = effectiveStyle(for: screen)
        let view = NSHostingView(rootView: NotchContentView(dynamicNotch: self, style: style))

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

    /// Deinitializes the window and removes it from the screen.
    func deinitializeWindow() {
        guard let windowController else { return }
        windowController.close()
        self.windowController = nil
    }
}
