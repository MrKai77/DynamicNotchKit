//
//  DynamicNotchHoverBehavior.swift
//  DynamicNotchKit
//
//  Created by Kai Azim on 2025-04-19.
//

import Foundation

/// Defines the behavior of the notch when hovered over.
public struct DynamicNotchHoverBehavior: OptionSet, Sendable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// All behaviors combined.
    public static let all: DynamicNotchHoverBehavior = [.keepVisible, .hapticFeedback, .increaseShadow]

    /// Ensures that the notch is always visible during hover.
    public static let keepVisible: DynamicNotchHoverBehavior = .init(rawValue: 1 << 0)

    /// Triggers haptic feedback when hovered over.
    public static let hapticFeedback: DynamicNotchHoverBehavior = .init(rawValue: 1 << 1)

    /// Increases the shadow of the notch during hover.
    public static let increaseShadow: DynamicNotchHoverBehavior = .init(rawValue: 1 << 2)
}
