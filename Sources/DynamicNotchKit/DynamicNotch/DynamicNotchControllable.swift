//
//  DynamicNotchControllable.swift
//  DynamicNotchKit
//
//  Created by Kai Azim on 2025-04-20.
//

import AppKit

@MainActor
public protocol DynamicNotchControllable {
    func expand(on screen: NSScreen)
    func compact(on screen: NSScreen)
    func hide()
}
