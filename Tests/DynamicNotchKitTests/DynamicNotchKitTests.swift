@testable import DynamicNotchKit
import XCTest
import SwiftUI

/// Hey there! Looks like you found DynamicNotchKit's tests.
///
/// Please note that these tests do NOT actaully "test" anything. They are moreso here to serve as examples of usage of DynamicNotchKit.
/// To run these tests, simply `cd` into the `DynamicNotchKit` directory and run `swift test`.
@MainActor
final class DynamicNotchKitTests: XCTestCase {
    func testInfoWithSystemImageAndChangingContent() async throws {
        let notch = DynamicNotchInfo(
            icon: .systemImage(systemName: "figure"),
            title: "This is a figure",
        )
        notch.show(for: .seconds(4))

        try await Task.sleep(for: .seconds(2))

        withAnimation {
            notch.title = "ANIMATED changing content!!"
            notch.description = "TEST"
        }

        try await Task.sleep(for: .seconds(3))
    }

    func testFloatingInfoWithSystemImageAndChangingContent() async throws {
        let notch = DynamicNotchInfo(
            icon: .systemImage(systemName: "figure"),
            title: "This is a figure",
            style: .floating(cornerRadius: 12)
        )
        notch.show(for: .seconds(4))

        try await Task.sleep(for: .seconds(2))

        withAnimation {
            notch.title = "ANIMATED changing content!!"
            notch.description = "TEST"
        }

        try await Task.sleep(for: .seconds(3))
    }

    func testInfoWithGradientAndCustomRadii() async throws {
        let notch = DynamicNotchInfo(
            icon: .view {
                LinearGradient(
                    colors: [.blue, .red],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .clipShape(.rect(cornerRadius: 4))
                .aspectRatio(contentMode: .fit)
            },
            title: "Gradient!",
            style: .notch(topCornerRadius: 20, bottomCornerRadius: 20)
        )

        notch.show(for: .seconds(3))
        try await Task.sleep(for: .seconds(4))
    }

    func testFloatingInfoWithGradient() async throws {
        let notch = DynamicNotchInfo(
            icon: .view {
                LinearGradient(
                    colors: [.blue, .red],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .clipShape(.rect(cornerRadius: 4))
                .aspectRatio(contentMode: .fit)
            },
            title: "Gradient!",
            style: .floating
        )

        notch.show(for: .seconds(3))
        try await Task.sleep(for: .seconds(4))
    }

    func testInfoWithAppIcon() async throws {
        let notch = DynamicNotchInfo(
            icon: .appIcon,
            title: "App Icon",
            description: "In a test environment, this should be a folder!"
        )
        notch.show(for: .seconds(3))
        try await Task.sleep(for: .seconds(4))
    }

    func testInfoWithoutIcon() async throws {
        let notch = DynamicNotchInfo(
            icon: .none,
            title: "No Icon",
            description: "This is a test without an icon."
        )
        notch.show(for: .seconds(3))
        try await Task.sleep(for: .seconds(4))
    }

    func testProgressWithChangingValues() async throws {
        let value = Binding<CGFloat>.constant(0.5)

        let notch = DynamicNotchProgress(
            progress: value,
            title: "Progress",
            description: "With live-updating values!"
        )
        notch.progressBarColor = .green
        notch.setProgressBarOverlay {
            Image(systemName: "bolt.fill")
                .foregroundColor(.green)
        }

        notch.show(for: .seconds(3))
        try await Task.sleep(for: .seconds(4))
    }

    func testDynamicNotch() async throws {
        let notch = DynamicNotch {
            VStack(spacing: 12) {
                ForEach(0..<10) { _ in
                    Text("Hello, world!")
                }
            }
        }

        notch.show(for: .seconds(3))
        try await Task.sleep(for: .seconds(4))
    }
}
