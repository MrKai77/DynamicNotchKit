//
//  DynamicNotchStyle.swift
//  DynamicNotchKit
//
//  Created by Kai Azim on 2025-04-18.
//

import Foundation

/// The style of a DynamicNotch.
public enum DynamicNotchStyle {
    /// Notch-style, meant to be used on screens with a notch
    ///
    /// Note that `topCornerRadius` and `bottomCornerRadius` are only use when the notch is in the expected state.
    case notch(
        topCornerRadius: CGFloat,
        bottomCornerRadius: CGFloat
    )

    /// Floating style, to be used on screens without a notch
    case floating(
        cornerRadius: CGFloat
    )

    /// Automatically choose the style based on the screen
    case auto

    static public let notch: DynamicNotchStyle = .notch(topCornerRadius: 15, bottomCornerRadius: 20)
    static public let floating: DynamicNotchStyle = .floating(cornerRadius: 20)

    var isNotch: Bool {
        if case .notch = self {
            return true
        } else {
            return false
        }
    }

    var isFloating: Bool {
        if case .floating = self {
            return true
        } else {
            return false
        }
    }
}

extension DynamicNotchStyle: Equatable {
    public static func == (lhs: DynamicNotchStyle, rhs: DynamicNotchStyle) -> Bool {
        switch (lhs, rhs) {
        case (.notch(let lhsTop, let lhsBottom), .notch(let rhsTop, let rhsBottom)):
            return lhsTop == rhsTop && lhsBottom == rhsBottom
        case (.floating(let lhsRadius), .floating(let rhsRadius)):
            return lhsRadius == rhsRadius
        case (.auto, .auto):
            return true
        default:
            return false
        }
    }
}
