//
//  DynamicNotchStyle.swift
//  DynamicNotchKit
//
//  Created by Kai Azim on 2025-04-18.
//

import SwiftUI

/// The style of a DynamicNotch.
public enum DynamicNotchStyle: Sendable {
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

    public static let notch: DynamicNotchStyle = .notch(topCornerRadius: 15, bottomCornerRadius: 20)
    public static let floating: DynamicNotchStyle = .floating(cornerRadius: 20)

    var isNotch: Bool {
        if case .notch = self {
            true
        } else {
            false
        }
    }

    var isFloating: Bool {
        if case .floating = self {
            true
        } else {
            false
        }
    }

    var openingAnimation: Animation {
        if isNotch {
            .bouncy(duration: 0.4)
        } else {
            .snappy(duration: 0.4)
        }
    }

    var closingAnimation: Animation {
        .smooth(duration: 0.4)
    }

    var conversionAnimation: Animation {
        .snappy(duration: 0.4)
    }
}

extension DynamicNotchStyle: Equatable {
    public static func == (lhs: DynamicNotchStyle, rhs: DynamicNotchStyle) -> Bool {
        switch (lhs, rhs) {
        case let (.notch(lhsTop, lhsBottom), .notch(rhsTop, rhsBottom)):
            lhsTop == rhsTop && lhsBottom == rhsBottom
        case let (.floating(lhsRadius), .floating(rhsRadius)):
            lhsRadius == rhsRadius
        case (.auto, .auto):
            true
        default:
            false
        }
    }
}
