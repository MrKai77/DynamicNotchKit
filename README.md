# DynamicNotchKit

Utilize then MacOS notch for enhanced user experiences.

## Examples:

| <img src="media/output-device.gif" width="100%"/> | <img src="media/battery.gif" width="100%"/> |
| -------- | ------- |
| <img src="media/info-panel.png" width="100%"/>  | <img src="media/window-management.gif" width="100%"/> |

## Usage

It's really easy! All the UI is handled by SwiftUI. That means, that you can use your existing views *directly* in DynamicNotchKit!

Here's an example:
```swift
let dynamicNotch = DynamicNotch(content: ContentView())
dynamicNotch.show(for: 2)
```

Where `ContentView` is a View.

Notice the `show(for: 2)`. This will make it show for 2 seconds, then hide again. In DynamicNotch, you can either:
- `show()`
- `show(for: seconds)`
- `hide()`
- `toggle()`

to control the visibility of the dropdown.

### DynamicNotchInfoWindow

In addition, there is also a `DynamicNotchInfoWindow`, which is a fine-tuned version of the DynamicNotch, specifically made to show general information:
```swift
let notch = DynamicNotchInfoWindow(
    systemImage: "figure",
    title: "Figure",
    description: "Looks like a person"
)
notch.show(for: 2)
```

Here are the available initializers for it:
- `DynamicNotchInfoWindow(systemImage: String, iconColor: Color = .white, title: String, description: String! = nil)`
- `DynamicNotchInfoWindow(image: Image! = nil, iconColor: Color = .white, title: String, description: String! = nil)`
- `DynamicNotchInfoWindow(keyView: Content, title: String, description: String! = nil)`

In fact, this was used 3/4 of the examples above :D  
The final listed intializer, which has `keyView`, can be used to show small indicators such as a circular progress bar.

...I'm probably going to improve these examples later :)  
Feel free to ask questions/report issues in the `Issues` tab!

# License

This project is licensed under the [MIT license](LICENSE).
