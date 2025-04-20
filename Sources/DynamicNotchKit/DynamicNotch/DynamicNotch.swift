//
//  DynamicNotch.swift
//  DynamicNotchKit
//
//  Created by Kai Azim on 2023-08-24.
//

import SwiftUI

@MainActor
public protocol DynamicNotchControllable {
    func expand(on screen: NSScreen)
    func compact(on screen: NSScreen)
    func hide()
}

public enum DynamicNotchState: Equatable {
    case expanded
    case compact
    case hidden
    
    func animation(to newState: DynamicNotchState) -> Animation {
        switch (self, newState) {
        case (.hidden, .expanded):
            .bouncy
        case (.hidden, .compact):
            .bouncy
        case (.expanded, .compact):
            .snappy
        case (.compact, .expanded):
            .spring
        default:
            .smooth
        }
    }
}

// MARK: - DynamicNotch

/// A flexible custom notch-styled window that can be shown on the screen.
@MainActor
public final class DynamicNotch<Expanded, CompactLeading, CompactTrailing>: ObservableObject, DynamicNotchControllable where Expanded: View, CompactLeading: View, CompactTrailing: View {
    /// Public in case user wants to modify the underlying NSPanel
    public var windowController: NSWindowController?

    /// Notch Options
    public let style: DynamicNotchStyle
    @Published public var state: DynamicNotchState = .hidden
    public let hoverBehavior: DynamicNotchHoverBehavior

    /// Content Properties
    let expandedContent: Expanded
    let compactLeadingContent: CompactLeading
    let compactTrailingContent: CompactTrailing

    /// Notch Properties
    @Published private(set) var notchSize: CGSize = .zero
    @Published private(set) var menubarHeight: CGFloat = 0
    @Published private(set) var isHovering: Bool = false

    /// Cancellable tasks for asynchronous operations
    private var hideTask: Task<(), Never>? // Used to cancel the hide task if the mouse is inside
    private var closePanelTask: Task<(), Never>? // Used to close the panel after hiding completes

    /// Makes a new DynamicNotch with custom content and style.
    /// - Parameters:
    ///   - style: the popover's style. If unspecified, the style will be automatically set according to the screen (notch or floating).
    ///   - content: a SwiftUI View to be shown in the popup.
    public init(
        hoverBehavior: DynamicNotchHoverBehavior = [.keepVisible],
        style: DynamicNotchStyle = .auto,
        @ViewBuilder expanded: @escaping () -> Expanded,
        @ViewBuilder compactLeading: @escaping () -> CompactLeading ,
        @ViewBuilder compactTrailing: @escaping () -> CompactTrailing
    ) {
        self.hoverBehavior = hoverBehavior
        self.style = style

        self.expandedContent = expanded()
        self.compactLeadingContent = compactLeading()
        self.compactTrailingContent = compactTrailing()

        observeScreenParameters()
    }
    
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
    }

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

public extension DynamicNotch {
    func expand(on screen: NSScreen = NSScreen.screens[0]) {
        guard state != .expanded else { return }
        
        closePanelTask?.cancel()
        if state == .hidden {
            initializeWindow(screen: screen)
        }
        
        Task {
            let animation = state.animation(to: .expanded)
            
            withAnimation(animation) {
                self.state = .expanded
            }
        }
    }
    
    func compact(on screen: NSScreen = NSScreen.screens[0]) {
        guard state != .compact else { return }
        
        if compactLeadingContent.self is EmptyView && compactLeadingContent.self is EmptyView {
            hide()
            return
        }

        closePanelTask?.cancel()
        if state == .hidden {
            initializeWindow(screen: screen)
        }

        Task {
            let animation = state.animation(to: .compact)
            
            withAnimation(animation) {
                self.state = .compact
            }
        }
    }

    /// Hide the popup.
    func hide() {
        guard state != .hidden else { return }

        if hoverBehavior.contains(.keepVisible), isHovering {
            Task {
                try? await Task.sleep(for: .seconds(0.1))
                hide()
            }
            return
        }

        let animation = state.animation(to: .hidden)

        withAnimation(animation) {
            state = .hidden
            isHovering = false
        }

        closePanelTask?.cancel()
        closePanelTask = Task {
            try? await Task.sleep(for: .seconds(0.8)) // Wait for animation to complete
            guard Task.isCancelled != true else { return }
            deinitializeWindow()
        }
    }
}

// MARK: - Window Management

private extension DynamicNotch {
    func initializeWindow(screen: NSScreen) {
        // so that we don't have a duplicate window
        deinitializeWindow()

        notchSize = screen.notchFrameWithMenubarAsBackup.size
        menubarHeight = screen.menubarHeight

        let style = style == .auto ? (screen.hasNotch ? .notch : .floating) : style
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

    func deinitializeWindow() {
        guard let windowController else { return }
        windowController.close()
        self.windowController = nil
    }
}
