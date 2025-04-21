//
//  DynamicNotchState.swift
//  DynamicNotchKit
//
//  Created by Kai Azim on 2025-04-20.
//

import SwiftUI

/// Represents the state of the dynamic notch. Currently, we try and match Apple's functionality of the Dynamic Island.
public enum DynamicNotchState: Equatable {
    /// The notch is in the expanded state, showing the expanded content.
    case expanded

    /// The notch is in the compact state, showing the leading and trailing contents.
    case compact

    /// The notch is hidden,.
    case hidden
}
