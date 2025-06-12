//
//  DynamicNotch.swift
//  DynamicNotchKit
//
//  Created by Kai Azim on 2023-08-24.
//

import SwiftUI

// MARK: - DynamicNotch

///
/// A customizable, notch-styled window for macOS applications.
///
/// ``DynamicNotch`` is the most flexible way to present custom windows using ``DynamicNotchKit``.
/// It accepts SwiftUI views as input and renders them in a dynamic floating window, and is ideal when full control over the content is required.
///
/// Inspired by Apple’s Dynamic Island, ``DynamicNotch`` introduces a similar interface experience for macOS, with built-in support for *expanded* and *compact* display states.
///
/// ### Expanded State
/// The expanded state is generally the largest view.
/// It shows the full content view below the notch, and is also the view used when the window is floating.
///
/// ### Compact State
/// In the compact state, there is the leading content, which is shown on the left side of the notch, and the trailing content, which is shown on the right side of the notch.
///
/// > When using the `floating` style, this framework does not support compact mode.
/// > Calling ``compact(on:)`` on these devices will automatically hide the window.
///
/// ## Usage
///
/// ```swift
/// Task {
///     let notch = DynamicNotch(style: style) {
///         VStack(spacing: 10) {
///             ForEach(0..<10) { i in
///                 Text("Hello World \(i)")
///             }
///         }
///     } compactLeading: {
///         Image(systemName: "moon.fill")
///             .foregroundStyle(.blue)
///     } compactTrailing: {
///         Image(systemName: "sun.max")
///             .foregroundStyle(.yellow)
///     }
///
///     await notch.expand()
///     try await Task.sleep(for: .seconds(2))
///     await notch.compact()
///     try await Task.sleep(for: .seconds(2))
///     await notch.hide()
/// }
/// ```
///
public final class DynamicNotch<Expanded, CompactLeading, CompactTrailing>: ObservableObject, DynamicNotchControllable where Expanded: View, CompactLeading: View, CompactTrailing: View {
    /// Public in case user wants to modify the underlying NSPanel
    public var windowController: NSWindowController?

    /// The window appearance, indicating the style of the notch.
    public let style: DynamicNotchStyle

    /// Behavior of window when mouse enters.
    public let hoverBehavior: DynamicNotchHoverBehavior

    /// Namespace for matched geometry effect. It is automatically generated if `nil` when the notch is first presented.
    @Published public internal(set) var namespace: Namespace.ID?

    /// Content
    let expandedContent: Expanded
    let compactLeadingContent: CompactLeading
    let compactTrailingContent: CompactTrailing
    @Published var disableCompactLeading: Bool = false
    @Published var disableCompactTrailing: Bool = false

    /// Notch Properties
    @Published private(set) var state: DynamicNotchState = .hidden
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
        @ViewBuilder compactLeading: @escaping () -> CompactLeading = { EmptyView() },
        @ViewBuilder compactTrailing: @escaping () -> CompactTrailing = { EmptyView() }
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
        if state == .hidden || windowController?.window?.screen != screen {
            initializeWindow(screen: screen)
        }

        Task { @MainActor in
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

    public func compact(on screen: NSScreen = NSScreen.screens[0]) async {
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
        if state == .hidden || windowController?.window?.screen != screen {
            initializeWindow(screen: screen)
        }

        Task { @MainActor in
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

        panel.layoutIfNeeded()
        panel.orderFrontRegardless()

        windowController = .init(window: panel)
    }

    /// Deinitializes the window and removes it from the screen.
    func deinitializeWindow() {
        guard let windowController else { return }
        windowController.close()
        self.windowController = nil
    }
}
