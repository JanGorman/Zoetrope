# Zoetrope

[![Version](https://img.shields.io/cocoapods/v/Zoetrope.svg?style=flat)](http://cocoapods.org/pods/Zoetrope)
[![License](https://img.shields.io/cocoapods/l/Zoetrope.svg?style=flat)](http://cocoapods.org/pods/Zoetrope)
[![Platform](https://img.shields.io/cocoapods/p/Zoetrope.svg?style=flat)](http://cocoapods.org/pods/Zoetrope)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

To use Zoetrope in your own project:

```swift
import Zoetrope

func viewDidLoad() {
	super.viewDidLoad()
	
	if let path = NSBundle.mainBundle().URLForResource("animated", withExtension: "gif"),
           data = NSData(contentsOfURL: path) {
		imageView.data = data
    }
}

```

Here's an animated gif of the simulator displaying an animated gif. Talk about self referential.

![image](https://dl.dropboxusercontent.com/u/512759/zoetrope.gif)

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

Jan Gorman, gorman.jan@gmail.com

## License

Zoetrope is available under the MIT license. See the LICENSE file for more info.
