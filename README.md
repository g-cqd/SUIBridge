#  SUIBridge
## The missing bridge between SwiftUI and UIKit

<details>

<summary><h2>A bit of context</h2></summary>

Everything started when I began developing a Web browser for iOS – still in development by the way. I set 3 goals starting this project:

1. Use SwiftUI as much as possible
2. Be as native as possible
3. Design the browser in the most flexible way yet as straightforward as possible

To achieve those goals on iOS, there's one thing that we can't circumvent: we have to use Apple WebKit APIs. It was actually a requirement before Apple release changes to their App Store policies due to European Union <abbr>DMA</abbr>.
Also, this is the best way to go fully native and that's exactly what I wanted to do.

## What problem does SUIBridge solve?

Webkit, on iOS at least, is constrained to the use of `WKWebView`, a UIKit based view – it means that the system is using "old" iOS APIs to display the web page.

However, UIKit-based views, to be integrated in a modern SwiftUI context, need to use a `UIViewRepresentable` conforming class and to implement at least 2 methods:

- `func makeUIView(context: Self.Context) -> Self.UIViewType`
- `func updateUIView(uiView: Self.UIViewType, context: Self.Context)`

Depending on your requirements, you may also want to implement:

- `func makeCoordinator() -> Self.Coordinator`
- `func dismantleUIView(_ uiView: Self.UIViewType, context: Self.Context)`

My main concern here is that we are moving away from the SwiftUI development paradigm. We have to declare outside of our SwiftUI views the actual handling of the view lifecycle through a UIKit-like structure that is compatible with `View`. Moreover, UIKit views are classes and own a lot of properties that are not usable through modifiers as in SwiftUI.

Therefore, **SUIBridge's essence is to close the gap between SwiftUI paradigm and UIKit paradigm**, unifying the iOS developer experience.

SwiftUI is convenient and fast to write, easy to develop and benefits from Xcode previews. These advantages vastly accelerate development and increase productivity in the application development process.

</details>

## How do we bridge those 2 paradigms?

Using UIKit views implies many core concepts to handle, presented here in a non-exhaustive list:

- Initializing the view
- Making the view
- Updating the view according to the view content and the actual app/view model states
- Performing actions depending on the app/view model states

SwiftUI abstracts those steps thanks to `@Environment`, `@State` and `@Binding` variables.

After everything that has been said until now, we're starting to understand what SUIBridge should be addressing. And actually, it addresses all of those requirements.

### What is exactly SUIBridge?

SUIBridge is a Swift Package containing a `Bridge` struct, conforming to `UIViewRepresentable` protocol and few other entities supporting it to achieve the goal.

`Bridge` obviously and necessarily implements needed methods but it also contains cool other methods:

```swift
extension Bridge {

    /// Set a value for a specific property of the underlying view
    func set<Value>(
        _ path: ReferenceWritableKeyPath<ViewType, Value>,
        to value: @autoclosure @escaping () -> Value?,
        during step: CycleMoment = .all
    ) -> Self

    /// Set a value for a specific property of the underlying
    /// view by calling the given function closure, taking the
    /// underlying view itself and the context object as arguments
    func set<Value>(
        _ path: ReferenceWritableKeyPath<ViewType, Value>,
        to value: @escaping (ViewType?, Context?) -> Value?,
        during step: CycleMoment = .all
    ) -> Self

    /// Perform an action during the `makeUIView` step of the view
    /// lifecycle
    func onMake(
        perform action: @escaping (ViewType?, Context?) -> Void
    ) -> Self   

    /// Perform an action during the `updateUIView` step of the view
    /// lifecycle
    func onUpdate(
        perform action: @escaping (ViewType?, Context?) -> Void
    ) -> Self

    /// Perform an action at an arbitrary moment of the view
    /// lifecycle, by default during both `makeUIView` and 
    /// `updateUIView` steps
    func perform(
        _ action: @escaping (ViewType?, Context?) -> Void,
        during step: CycleMoment = .all
    ) -> Self

    /// Add subviews to the underlying view
    func containing(
        @SubviewBuilder subview: () -> Representable.Represented
    ) -> Self

}
```

> **Information**
> 
> To be able to set properties for the underlying view in a generic way — without knowing view type before hand, I use `ReferenceWritableKeyPath` that takes 2 types: the actual view type and the targeted property type. `ReferenceWritableKeyPath` defines a path to reach a property of an object. This object has to be reference-based (as are classes in Swift, and therefore as are views in UIKit), and we access the property as a writable property.

Those methods act as modifiers for `Bridge`. They all return a `Bridge` instance is created according to the cascading modifiers.

In SUIBridge package, `UIView`, the inherited class by every views of UIKit, is extended with those same modifiers, returning a `Bridge` instance instead of a `UIView`.

A simple exemple of use in a SwiftUI context is:

```swift
import SwiftUI
import SUIBridge

struct ContentView: View {
    var body: some View {
        VStack {
            UILabel()
                .set( \.text, to: "Hello World!" )
        }
    }
}
```
