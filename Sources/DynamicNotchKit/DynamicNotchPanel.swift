//
// SwiftUIView.swift
// DynamicNotchKit
//
// Created by Huy D. on 11/1/24
// mjn2max.github.io 😜
//
// Copyright © 2024. All rights reserved.
//

import AppKit

class DynamicNotchPanel: NSPanel {
    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        self.hasShadow = false
        self.backgroundColor = .clear
        self.level = .screenSaver
        self.collectionBehavior = .canJoinAllSpaces
        self.orderFrontRegardless()
    }

    override var canBecomeKey: Bool {
        true
    }

    override var canBecomeMain: Bool {
        true
    }
}
