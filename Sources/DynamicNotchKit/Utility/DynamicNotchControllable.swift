//
//  DynamicNotchControllable.swift
//  DynamicNotchKit
//
//  Created by Kai Azim on 2025-04-20.
//

import AppKit

/// Protocol for controlling the dynamic notch behavior.
@MainActor
public protocol DynamicNotchControllable {
    /// Sets the notch's appearance to be expanded, showing the expanded content.
    /// - Parameter screen: the screen on which to show the expanded notch.
    func expand(on screen: NSScreen) async

    /// Sets the notch's appearance to be compact, showing the leading and trailing contents.
    /// - Parameter screen: the screen on which to show the compact notch.
    func compact(on screen: NSScreen) async

    /// Sets the notch's appearance to be hidden, hiding all content and deinitializing the window.
    func hide() async
}
