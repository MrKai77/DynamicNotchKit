# DynamicNotchKit

## Examples:

<div><video controls src="https://github.com/user-attachments/assets/09a139a8-1a40-4214-bcd9-1937764fb071" muted="true"></video></div>

## Installation

Compatibility: **macOS 13+**

Add `https://github.com/MrKai77/DynamicNotchKit` in the [“Swift Package Manager” tab in Xcode](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app).

## Usage

It's really easy! All the UI is handled by SwiftUI. That means that you can use your existing views *directly* in DynamicNotchKit!

Here's an example:
```swift
let notch = DynamicNotch {
    ContentView()
}
await notch.expand()
```

Where `ContentView` conforms to `View`.

DynamicNotchKit also supports Macs without a notch, meaning that this package supports _all_ Mac styles! You will see an example of that below.

## DynamicNotchInfo

In addition, there is also a `DynamicNotchInfo`, which is a fine-tuned version of the DynamicNotch specifically tailored to show general information:
```swift
let notch = DynamicNotchInfo(
    icon: .init(systemName: "figure"),
    title: "Figure",
    description: "Looks like a person"
)
await notch.expand()
```

This will result in a popover as so:

<img src="media/demo.gif" width="50%"/>

Furthermore, there is a `.floating` style, which will **automatically** be used on Macs without a notch:

<img src="media/demo-floating.gif" width="50%"/>

This is only a basic glimpse into this framework's capabilities. Documentation is available for **all** public methods and properties, so I encourage you to take a look at it for more advanced usage. Alternatively, you can take a look at the unit tests for this package, where I have added some usage examples as well.

Feel free to ask questions/report issues in the Issues tab!

# License

This project is licensed under the [MIT license](LICENSE).
