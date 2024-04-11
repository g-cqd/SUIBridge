#  SUIBridge
## The missing bridge between SwiftUI and UIKit

<details>

<summary><h2>Preliminary Words</h2></summary>

By these words, I want to inform you that my Swift development journey started not that long ago and that the present article may contain inaccuracies. Feel free to put some shame on me on any social media you can find me on, but don't forget to tag me on it so I can improve my content.

Also, the content itself may not be easy to understand for a beginner developer in the Swift ecosystem but I'm doing my best to provide as many resources as I can without getting too much into the details of some simple concepts. SUIBridge is geared toward iOS and macOS developers and every person who would have to deal with some legacy code or requires some old APIs to achieve complex developments in their application.

</details>


<details>

<summary><h2>A bit of context</h2></summary>

Everything started when I began developing a Web browser for iOS – still in development by the way. I set 3 goals starting this project:

1. Use **SwiftUI**[^swiftui] as much as possible
2. Be as **native** as possible
3. Design the browser as **flexibly** yet as **straightforward** as possible

These goals are motivated by SwiftUI being convenient and fast to write, easy to develop with and that it benefits from **Xcode previews**. It's also the latest GUI framework released by Apple and the whole iOS development ecosystem is geared toward the conversion of UIKit-based applications to SwiftUI.

Keeping the app as native as possible will help avoid third-party libraries and help keep the application light and safe with new features and technologies from Apple being faster and easier to implement.

The third goal is something I have to take care of on another level of concern that does not really suit this article.

Sticking to those goals would vastly accelerate development and increase productivity, but to achieve them on iOS, there's one thing that we can't circumvent: we have to use Apple **WebKit**[^webkit] APIs. It was a requirement before [Apple release changes to their applications policies](https://www.apple.com/newsroom/2024/01/apple-announces-changes-to-ios-safari-and-the-app-store-in-the-european-union/){:target="_blank"} due to European Union DMA[^dma].
Besides this, it is also the best way to go fully native and that's exactly what I wanted to do as I just said.

</details>

## What problems does SUIBridge solve?

Webkit, on iOS at least, is constrained to the use of `WKWebView`[^wkwebview], a **UIKit**[^uikit] based view – it means that the system is using "old" iOS APIs to display the web page.

However, UIKit-based views, to be integrated into a modern SwiftUI context, need to use a `UIViewRepresentable`[^uiviewrepresentable] conforming class and implement at least 2 methods:

```swift
struct Bridge: UIViewRepresentable {

    func makeUIView(context: Self.Context) -> Self.UIViewType
    func updateUIView(uiView: Self.UIViewType, context: Self.Context)

    ...
}
```

Depending on your requirements, you may also want to implement:

```swift
struct Bridge: UIViewRepresentable {

    ...

    func makeCoordinator() -> Self.Coordinator
    func dismantleUIView(_ uiView: Self.UIViewType, context: Self.Context)
}
```

My main concern here is that we are moving away from the SwiftUI development paradigm. By using that, we would have to utilize _imperative programming_ outside of our SwiftUI views to implement the actual handling of the view _lifecycle_ through a UIKit-like structure that is compatible with `View`. Moreover, UIKit views are classes and own a lot of properties that are not usable through modifiers as in SwiftUI and this makes view configuration even less convenient.

Therefore, **SUIBridge's essence is to close the gap between SwiftUI and UIKit paradigms**, unifying the iOS developer experience by applying _declarative programming_ to UIKit. Moreover, working on that bridge is a good way to deepen my knowledge of iOS and learn key concepts about the system.

## How do we bridge those paradigms?

Using UIKit views implies handling of many core concepts, presented here in a _non-exhaustive_ list:

- Initializing the view
- Making the view
- Updating the view according to the view content and the actual app/view model states
- Performing actions depending on the app/view model states

SwiftUI abstracts those thanks to `@Environment`, `@State` and `@Binding` variables.

After all of that said, we're starting to understand what SUIBridge should be addressing. And actually, it addresses (_almost_) all of those requirements.

### What is exactly SUIBridge?

SUIBridge is a **Swift Package**[^swiftpkg] containing a `Bridge` struct, conforming to `UIViewRepresentable` protocol and a few other entities supporting it to achieve the goal.

`Bridge` and its components rely on _generics_[^generics] that inherit `UIView`, making the bridge compatible with all types of views.

Also, `Bridge` obviously and necessarily implements needed methods but it also contains cool other methods:

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

    /// Perform an action during the `dismantleUIView` step of the view
    /// lifecycle
    func onDismantle(
        perform action: @escaping (ViewType?, Context?) -> Void
    ) -> Self

    /// Perform an action at an arbitrary moment of the view
    /// lifecycle, by default during both `makeUIView` and 
    /// `updateUIView` steps
    func perform(
        _ action: @escaping (ViewType?, Context?) -> Void,
        during step: CycleMoment = .all
    ) -> Self

}
```

### About `ReferenceWritableKeyPath`

To be able to set properties for the underlying view in a generic way — without knowing the view type or the property type beforehand, I use `ReferenceWritableKeyPath`[^referencewritablekeypath] that takes 2 types: the actual view type and the targeted property type.

`ReferenceWritableKeyPath` defines a path to reach a property of an object. This object has to be reference-based (as are classes in Swift, and therefore as are views in UIKit), and we access the property as a writable property so we can change its value and act on it.

I decided to pass the view and the context to these methods to preserve the feature parity with the `UIViewRepresentable`.

### Behind the scenes of `.set(...)` methods

`.set(...)` methods, as you can read it, accept a path and a value, alongside a moment of the cycle you want to perform this set operation at, or an `@autoclosure`[^autoclosure] escaped value.

The actual action of setting a specific property to a value is saved as a function behind the scenes. This function is then called at every moment defined by the `step` argument.

This function is part of a structure called `ViewConfiguration`[^viewconfiguration]. This structure leverages functional programming[^funcprog] to _compose_ all the functions defined by those `.set(...)` methods and then the bridge uses that composed function and calls it at the right time in the cycle. 


```swift
struct Bridge {

    ...

    func makeUIView(context: Context) -> ViewType {
        context.coordinator.compose(.make, configurations: self.configurations)(self.view, context).view
    }

    func updateUIView(_ uiView: ViewType, context: Context) {
        context.coordinator.compose(.update, configurations: self.configurations)(uiView, context)
    }

    func dismantleUIView(_ uiView: ViewType, coordinator: Coordinator) {
        coordinator.compose(.dismantle, configurations: self.configurations)(uiView, nil)
    }

    ...

}
```

Let's have a look at this `.compose(...)` method of the coordinator:

```swift
class BridgeCoordinator {

    ...

    func compose(_ moment: CycleMoment, configurations: Configuration...) -> Configuration {
        configurations.reduce(.init(moment), +)
    }

    func compose(_ moment: CycleMoment, configurations: [Configuration]) -> Configuration {
        configurations.reduce(.init(moment), +)
    }
}
```

Other methods `.onMake(...)`, `.onUpdate(...)`, `.onDismantle(...)` and `.perform(...)` are making use of the same mechanism and add configurations to the view to be applied in the same fashion.

All of the mentioned methods act as modifiers for `Bridge` — and therefore the resulting view itself. They all return a `Bridge` instance created according to the cascade of modifiers.

In the SUIBridge package, `UIView`, the inherited class by every view of UIKit, is extended with those same modifiers, returning a `Bridge` instance instead of a `UIView` to make it work seamlessly.

### Some cool stuff

Because I really want to ease the use of SUIBridge, I extended `UIView` with a few other features.

First, you can _call_ a view. Calling a view refers to the `.containing(...)` method below. When you call a view, you pass an escaped closure that lets you add subviews to your view directly as if you were writing SwiftUI code, but it's only about `UIView` at the moment.


```swift
extension Bridge {

    /// Add subviews to the view you're building
    func containing(
        @SubviewBuilder subview: () -> UIView
    ) -> Self {
        self.view!.addSubview( subview() )
        return Self(self.view!, self.configurations)
    }

}
```

```swift
extension UIView {

    func callAsFunction(@SubviewBuilder subview: () -> UIView? = { nil }) -> Self {
        if let subview = subview() {
            self.addSubview(subview)
        }
        return self
    }

    func callAsFunction(@SubviewBuilder subview: () -> UIView? = { nil }) -> Bridge {
        if let subview = subview() {
            self.addSubview(subview)
        }
        return Bridge(self)
    }
}
```

What does all of that mean? I can imagine it's not the most straightforward code you saw today. Quick examples of what you can write in your actual code:

```swift
struct ContentView {
    var body: some View {

        UIView() {}
        
        UIView()()

        UIView() {
            UIView()
            UIView()
        }

        UIView()
            .containing {
                UIView()
            }
    }
}
```

And that works with **all** (custom or not) views that inherit `UIView`. The `SubviewBuilder` works (_almost_) the same way a `@ViewBuilder` would work. I let you have a look at the [documentation about the "Result Builders"](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/advancedoperators#Result-Builders){:target="_blank"} to understand this API.

_Right now, the builder is not able to understand SwiftUI views, but it's a future implementation._

The last thing I added to `UIView` is:

```swift
extension UIView {
    func asView() -> Bridge {
        .init(self)
    }
}
```

It makes it easy to just convert any view to a SwiftUI view explicitly without losing any meaning in the code as it could be the case if we were _calling_ the view as seen above.

### One more thing...

Because I plan to continue to work on the bridge, the bridge is already capable of handling `NSView`[^nsview] as well as `UIView`. The bridge has basic compatibility with AppKit[^appkit] and works exactly the same as with UIKit. Nothing has been tested yet with it though but that could mean that it is already working for macOS application development.

## I guess I have to conclude

As of today, this is the state of SUIBridge. You can [find it on GitHub](https://github.com/g-cqd/SUIBridge){:target="_blank"} and use it in Xcode as a package dependency directly.

Performance has not been tested but I welcome any benchmark process idea from the community and invite you to inform me about problems related to your use of the package, feature requests, improvements,...

If you have any comments or questions, find me on social media and reach out to me or submit an issue here.

You can find the [prototype of the bridge here](https://github.com/g-cqd/SUIBridgePrototype){:target="_blank"}. It does not work but it shows what I had in mind starting this project.

I also invite you to have a look at the project of Antoine van der Lee [**SwiftUIKitView**](https://github.com/AvdLee/SwiftUIKitView) which is something really close if not the same, that I discovered after having done the prototype. I used Antoine's as inspiration to improve mine and I noticed that his project may encounter some problems and may not work currently so I consider that SUIBridge currently fixes problems his had and also does things that I'm not aware his is doing.

Accompanying these words, I'll let you with a simple example of SUIBridge in use:

```swift
import SwiftUI
import SUIBridge

struct ContentView: View {

    @State var text: String = ""

    var body: some View {
        VStack {
            UILabel()
                .set(\.text, to: $text.wrappedValue)
                .fixedSize()
                .background(Color.teal)
        }
        .onAppear {
            text = "Hello World"
        }
    }
}

#Preview {
    ContentView()
}
```

[^dma]: The Digital Markets Act: ensuring fair and open digital markets<br>[https://commission.europa.eu/.../digital-markets-act-ensuring-fair-and-open-digital-markets_en](https://commission.europa.eu/strategy-and-policy/priorities-2019-2024/europe-fit-digital-age/digital-markets-act-ensuring-fair-and-open-digital-markets_en){:target="_blank"}

[^swiftui]: SwiftUI Overview - Xcode - Apple Developer<br>[https://developer.apple.com/xcode/swiftui/](https://developer.apple.com/xcode/swiftui/){:target="_blank"}

[^webkit]: WebKit \| Apple Developer Documentation<br>[https://developer.apple.com/documentation/webkit](https://developer.apple.com/documentation/webkit){:target="_blank"}

[^uikit]: UIKit \| Apple Developer Documentation<br>[https://developer.apple.com/documentation/uikit](https://developer.apple.com/documentation/uikit){:target="_blank"}

[^wkwebview]: `WKWebView` \| Apple Developer Documentation<br>[https://developer.apple.com/documentation/webkit/wkwebview](https://developer.apple.com/documentation/webkit/wkwebview){:target="_blank"}

[^swiftpkg]: _Swift packages are reusable components of Swift, Objective-C, Objective-C++, C, or C++ code that developers can use in their projects. They bundle source files, binaries, and resources in a way that’s easy to use in your app’s project._<br>Swift packages \| Apple Developer Documentation<br>[https://developer.apple.com/documentation/xcode/swift-packages](https://developer.apple.com/documentation/xcode/swift-packages){:target="_blank"}

[^generics]: Generics \| Documentation \| Swift.org<br>[https://docs.swift.org/swift-book/documentation/the-swift-programming-language/generics/](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/generics/)

[^uiviewrepresentable]: `UIViewRepresentable` \| Apple Developer Documentation<br>[https://developer.apple.com/documentation/swiftui/uiviewrepresentable](https://developer.apple.com/documentation/swiftui/uiviewrepresentable){:target="_blank"}

[^referencewritablekeypath]: `ReferenceWritableKeyPath` \| Apple Developer Documentation<br>[https://developer.apple.com/documentation/swift/referencewritablekeypath](https://developer.apple.com/documentation/swift/referencewritablekeypath){:target="_blank"}

[^autoclosure]: Autoclosures \| Closures \| Apple Developer Documentation<br>[https://docs.swift.org/swift-book/documentation/the-swift-programming-language/closures/#Autoclosures](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/closures/#Autoclosures){:target="_blank"}

[^viewconfiguration]: `ViewConfiguration` \| SUIBridge \| GitHub <br>[https://github.com/g-cqd/SUIBridge/blob/main/Sources/SUIBridge/ViewConfiguration.swift](https://github.com/g-cqd/SUIBridge/blob/main/Sources/SUIBridge/ViewConfiguration.swift){:target="_blank"}

[^funcprog]: Functional programming - Wikipedia<br>[https://en.wikipedia.org/wiki/Functional_programming](https://en.wikipedia.org/wiki/Functional_programming){:target="_blank"}

[^appkit]: AppKit \| Apple Developer Documentation<br>[https://developer.apple.com/documentation/appkit](https://developer.apple.com/documentation/appkit){:target="_blank"}

[^nsview]: `NSView` \| Apple Developer Documentation<br>[https://developer.apple.com/documentation/appkit/nsview/](https://developer.apple.com/documentation/appkit/nsview/){:target="_blank"}


*[DMA]: Digital Markets Act
*[GUI]: Graphical User Interface
*[API]: Application Programming Interface
*[APIs]: Application Programming Interfaces
