//
//  EnvironmentValues+Extensions.swift
//  DynamicNotchKit
//
//  Created by Kai Azim on 2025-03-26.
//

import SwiftUI

public extension EnvironmentValues {
    @Entry var notchStyle: DynamicNotchStyle = .auto
    @Entry var notchAnimation: Animation = .timingCurve(0.16, 1, 0.3, 1, duration: 0.7)
}
