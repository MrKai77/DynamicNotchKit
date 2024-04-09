# DynamicNotchKit

Utilize then MacOS notch for enhanced user experiences.

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
let dynamicNotch = DynamicNotch(content: ContentView())
dynamicNotch.show(for: 2)
```

Where `ContentView` is a View.

This will result in a window as so:  
<img src="media/demo.gif" width="50%"/>

Notice the `show(for: 2)`. This will make it show for 2 seconds, on the primary display, then hide again.  
The available methods to set the DynamicNotch's visibility are:
- `show(on screen: NSScreen = NSScreen.screens[0], for time: Double = 0)`
- `hide()`
- `toggle()`

Anyways, there are much more methods available, which I haven't listed here. I have added much more detailed documentation to each available public method, so if you are curious, please check there!

...I'm probably going to improve these docs later :)  
Feel free to ask questions/report issues in the Issues tab!

# License

This project is licensed under the [MIT license](LICENSE).
