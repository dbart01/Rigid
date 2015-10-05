# Rigid
String-based operations are inherintly unsafe, error-prone and lack basic convenience from code completion and compiler checks. Inspired by the WWDC 2015 session - Swift In Practice (#411), Rigid is a command-line utility that quickly embeds into your Xcode project and provides generated `.swift` code for all your static assets, `.xib` files, segue identifier, view controller identifiers, and more.

### How It Works
Rigid will automatically scan your Xcode project directory looking for images, nibs, storyboards, etc. It will then generate a `.swift` file with typed constants and convenience methods for common operations like instantiating a `UIImage`, `UINib`, `UIViewController`, etc. It is also cross-platform and will seemlessly work on both iOS and Mac OS X without any additional configuration!

It replaces using error-prone string literals:
```swift
if let image = UIImage(named: "Kittens") {
    // Use image here
}
```
with safe, compile-time-checked constants:
```swift
let image = UIImage(named: .Kittens)
```
This is all possible thanks to the enums generated by Rigid. The `Rigid.swift` file will contain something like this:
```swift
public enum Image: String {
    case Kittens  = "Kittens"
    case Puppies  = "Puppies"
    case Chickens = "Chickens"
    case Dolphins = "Dolphins"
    // etc...
}
```
But that isn't enough. We also need a way to use the `Image` enum. Rigid also provides overrides for common use cases like instantiating an image from your bundle:
```swift
extension UIImage {
    convenience init(named name: Image) {
        self.init(named: name.rawValue)!
    }
}
```
### Why It Matters
While the example above may seem like a trivial change, we do, in fact, gain several very important advantages from using Rigid's generated code:
   - the initializer is garanteed to succeed and will therefore return a `UIImage` instead of `UIImage?`
   - if the image is removed, renamed or somehow is no longer available, a compile-time error will be emitted instead of silently failing at runtime, *when it matters*
   - code completion!


