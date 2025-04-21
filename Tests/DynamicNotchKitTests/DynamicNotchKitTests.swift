@testable import DynamicNotchKit
import SwiftUI
import Testing

extension Tag {
    @Tag static var notchStyle: Self
    @Tag static var floatingStyle: Self
}

/// Hey there! Looks like you found DynamicNotchKit's tests.
///
/// Please note that these tests do NOT actaully "test" anything. They are moreso here to serve as examples of usage of DynamicNotchKit.
/// To run these tests, simply `cd` into the `DynamicNotchKit` directory and run `swift test`.
@MainActor
@Suite(.serialized)
struct DynamicNotchKitTests {

    // MARK: - DynamicNotchInfo - Simple

    @Test("Info - Simple Notch Style", .tags(.notchStyle))
    func dynamicNotchInfoSimpleNotchStyle() async throws {
        try await _dynamicNotchInfoSimple(with: .notch)
    }
    
    @Test("Info - Simple Floating Style", .tags(.floatingStyle))
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
    
    @Test("Info - Advanced Notch Style", .tags(.notchStyle))
    func dynamicNotchInfoAdvancedNotchStyle() async throws {
        try await _dynamicNotchInfoAdvanced(with: .notch)
    }
    
    @Test("Info - Advanced Floating Style", .tags(.floatingStyle))
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

    @Test("Info - Custom Notch Style & Gradient", .tags(.notchStyle))
    func dynamicNotchInfoCustomNotchStyle() async throws {
        try await _dynamicNotchInfoGradientCustomRadii(with: .notch(topCornerRadius: 10, bottomCornerRadius: 40))
    }
    
    @Test("Info - Custom Floating Style & Gradient", .tags(.floatingStyle))
    func dynamicNotchInfoCustomFloatingStyle() async throws {
        try await _dynamicNotchInfoGradientCustomRadii(with: .floating(cornerRadius: 40))
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
            title: "Gradient!",
            style: style
        )

        await notch.expand()
        try await Task.sleep(for: .seconds(4))
        await notch.hide()
    }

//    func testInfoWithAppIcon() async throws {
//        let notch = DynamicNotchInfo(
//            icon: .init(image: Image(nsImage: .init(named: NSImage.applicationIconName)!)),
//            title: "App Icon",
//            description: "In a test environment, this should be a folder!"
//        )
//        notch.show(for: .seconds(3))
//        try await Task.sleep(for: .seconds(4))
//    }
}
