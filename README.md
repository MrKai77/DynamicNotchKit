# DynamicNotchKit

Utilize the MacOS notch for enhanced user experiences.

## Examples:

| <img src="media/output-device.gif" width="100%"/> | <img src="media/battery.gif" width="100%"/> |
| -------- | ------- |
| <img src="media/info-panel.png" width="100%"/>  | <img src="media/window-management.gif" width="100%"/> |

## Installation

Compatibility: **macOS 12+**

Add `https://github.com/MrKai77/DynamicNotchKit` in the [“Swift Package Manager” tab in Xcode](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app).

## Usage

It's really easy! All the UI is handled by SwiftUI. That means, that you can use your existing views *directly* in DynamicNotchKit!

Here's an example:
```swift
let dynamicNotch = DynamicNotch {
    ContentView()
}
dynamicNotch.show(for: 2)
```

Where `ContentView` is a View.

Notice the `show(for: 2)`. This will cause the popover to be displayed on the primary screen for two seconds before hiding itself automatically.
The available methods to set the DynamicNotch's visibility are:
- `show(on screen: NSScreen = NSScreen.screens[0], for time: Double = 0)`
- `hide()`
- `toggle()`

DynamicNotchKit also supports Macs without a notch, meaning that this package supports _all_ Mac styles! You will see an example of that below.

## DynamicNotchInfo

In addition, there is also a `DynamicNotchInfo`, which is a fine-tuned version of the DynamicNotch specifically tailored to show general information:
```swift
let notch = DynamicNotchInfo(
    icon: Image(systemName: "figure"),
    title: "Figure",
    description: "Looks like a person"
)
notch.show(for: 2)
```

This will result in a popover as so:

<img src="media/demo.gif" width="50%"/>

Furthermore, there is a `.floating` style, which will **automatically** be used on Macs without a notch:

<img src="media/demo-floating.gif" width="50%"/>

In fact, `DynamicNotchInfo` was used 3/4 of the examples above :D

Anyways, there are more methods available, which I haven't listed here, as this package is still in development. I have also added much more detailed documentation to each available public method in the code, so if you are curious, please check there for more usage information!

...I'm probably going to improve these docs later :)

Feel free to ask questions/report issues in the Issues tab!

# License

This project is licensed under the [MIT license](LICENSE).
