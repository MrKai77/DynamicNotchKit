@testable import DynamicNotchKit
import SwiftUI
import Testing

extension Tag {
    @Tag static var notchStyle: Self
    @Tag static var floatingStyle: Self
}

/// Hey there! Looks like you found DynamicNotchKit's tests.
/// Please note that these tests do NOT actually "test" anything. They are only here to serve as examples of usage of DynamicNotchKit.
/// To run these tests, simply `cd` into the `DynamicNotchKit` directory and run `swift test`. Alternatively, open this package directly in Xcode, and the tests should show up in the sidebar.
@MainActor
@Suite(.serialized)
struct DynamicNotchKitTests {

    // MARK: - DynamicNotchInfo - Simple

    @Test("Info - Simple notch style", .tags(.notchStyle))
    func dynamicNotchInfoSimpleNotchStyle() async throws {
        try await _dynamicNotchInfoSimple(with: .notch)
    }
    
    @Test("Info - Simple floating style", .tags(.floatingStyle))
    func dynamicNotchInfoSimpleFloatingStyle() async throws {
        try await _dynamicNotchInfoSimple(with: .floating)
    }
    
    func _dynamicNotchInfoSimple(with style: DynamicNotchStyle) async throws {
        let notch = DynamicNotchInfo(
            icon: .init(systemName: "info.circle"),
            title: "This is `DynamicNotchInfo`",
            description: "It provides preset styles for easy use.",
            style: style
        )

        await notch.expand()

        try await Task.sleep(for: .seconds(4))

        withAnimation {
            notch.icon = .init(systemName: "arrow.trianglehead.2.clockwise")
            notch.title = "Content can be updated as well!"
            notch.description = "It's that simple!"
        }

        try await Task.sleep(for: .seconds(4))
        
        await notch.hide()
    }
    
    // MARK: - DynamicNotchInfo - Advanced
    
    @Test("Info - Advanced notch style", .tags(.notchStyle))
    func dynamicNotchInfoAdvancedNotchStyle() async throws {
        try await _dynamicNotchInfoAdvanced(with: .notch)
    }
    
    @Test("Info - Advanced floating style", .tags(.floatingStyle))
    func dynamicNotchInfoAdvancedFloatingStyle() async throws {
        try await _dynamicNotchInfoAdvanced(with: .floating)
    }
    
    func _dynamicNotchInfoAdvanced(with style: DynamicNotchStyle) async throws {
        let notch = DynamicNotchInfo(
            icon: .init(systemName: "info.circle"),
            title: "`DynamicNotchInfo`: advanced usage",
            description: "More than just images!",
            style: style
        )

        await notch.expand()

        try await Task.sleep(for: .seconds(4))

        withAnimation {
            notch.icon = .init(progress: .constant(0.5))
            notch.title = "Like progress bars..."
            notch.description = nil
        }
        
        try await Task.sleep(for: .seconds(4))
        
        withAnimation {
            notch.icon = nil
            notch.title = "There's also a compact style like iOS!"
            notch.description = "Note: this doesn't work in the floating style."
        }
        
        try await Task.sleep(for: .seconds(4))

        withAnimation {
            notch.compactLeading = .init(systemName: "moon.fill", color: .blue)
        }
        await notch.compact()

        try await Task.sleep(for: .seconds(2))
        
        withAnimation {
            notch.compactTrailing = .init(systemName: "eyes.inverse", color: .orange)
        }

        try await Task.sleep(for: .seconds(2))
        
        withAnimation {
            notch.compactLeading = nil
        }

        try await Task.sleep(for: .seconds(2))
        
        await notch.hide()
    }
    
    // MARK: - DynamicNotchInfo - Custom

    @Test("Info - Custom notch style & gradient", .tags(.notchStyle))
    func dynamicNotchInfoCustomNotchStyle() async throws {
        try await _dynamicNotchInfoGradientCustomRadii(with: .notch(topCornerRadius: 10, bottomCornerRadius: 25))
    }
    
    @Test("Info - Custom floating style & gradient", .tags(.floatingStyle), .disabled("Compact mode does not support floating windows"))
    func dynamicNotchInfoCustomFloatingStyle() async throws {
        try await _dynamicNotchInfoGradientCustomRadii(with: .floating(cornerRadius: 25))
    }
    
    func _dynamicNotchInfoGradientCustomRadii(with style: DynamicNotchStyle) async throws {
        let notch = DynamicNotchInfo(
            icon: .init {
                LinearGradient(
                    colors: [.blue, .red],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .clipShape(.rect(cornerRadius: 4))
                .aspectRatio(contentMode: .fit)
            },
            title: "This a gradient!",
            description: "It ships with a `matchedGeometryEffect` for easy animations.",
            style: style
        )

        await notch.expand()
        try await Task.sleep(for: .seconds(4))
        await notch.compact()
        try await Task.sleep(for: .seconds(2))
        await notch.expand()
        try await Task.sleep(for: .seconds(2))
        await notch.compact()
        try await Task.sleep(for: .seconds(2))
        await notch.hide()
    }
    
    // MARK: DynamicNotchInfo - App Icon
    
    @Test("Info - Notch with custom icon", .tags(.notchStyle))
    func dynamicNotchInfoAppIcon() async throws {
        await _testInfoWithAppIcon(with: .notch)
    }
    
    @Test("Info - Floating with custom icon", .tags(.floatingStyle), .disabled("Compact mode does not support floating windows"))
    func dynamicNotchInfoAppIconFloating() async throws {
        await _testInfoWithAppIcon(with: .floating)
    }

    func _testInfoWithAppIcon(with style: DynamicNotchStyle) async {
        let notch = DynamicNotchInfo(
            icon: .init(image: Image(nsImage: NSImage(named: NSImage.applicationIconName)!)),
            title: "We support custom icons as well!",
            description: "As always, with a provided `matchedGeometryEffect`.",
            style: style
        )

        await notch.expand()
        try? await Task.sleep(for: .seconds(4))
        await notch.compact()
        try? await Task.sleep(for: .seconds(4))
        await notch.hide()
    }
}
