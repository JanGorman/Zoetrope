# Zoetrope

[![Version](https://img.shields.io/cocoapods/v/Zoetrope.svg?style=flat)](http://cocoapods.org/pods/Zoetrope)
[![License](https://img.shields.io/cocoapods/l/Zoetrope.svg?style=flat)](http://cocoapods.org/pods/Zoetrope)
[![Platform](https://img.shields.io/cocoapods/p/Zoetrope.svg?style=flat)](http://cocoapods.org/pods/Zoetrope)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

## Requirements

- Swift 4.2
- iOS 8.0+
- Xcode 9+

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

To use Zoetrope in your own project:

```swift
import Zoetrope

func viewDidLoad() {
	super.viewDidLoad()
	
	if let path = Bundle.main.url(forResource: "animated", withExtension: "gif") {
		do {
			let data = try Data(contentsOf: path)
			try imageView.setData(data)
		} catch let error {
			print("Invalid gif \(error)")
		}
    }
}

```

Here's an animated gif of the simulator displaying an animated gif.

![image](https://www.dropbox.com/s/ixutl4ehrgszhde/zoetrope.gif?raw=1)

## Installation

Zoetrope is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Zoetrope"
```

And [Carthage](https://github.com/Carthage/Carthage). Add the following to your `Cartfile` and then run `carthage update`:

```ogdl
github "JanGorman/Zoetrope"
```

## Author

[@JanGorman](https://twitter.com/JanGorman/)

## License

Zoetrope is available under the MIT license. See the LICENSE file for more info.
