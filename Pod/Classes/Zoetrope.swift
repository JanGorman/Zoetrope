//
//  Copyright (c) 2015 Jan Gorman. All rights reserved.
//

import UIKit
import ImageIO
import MobileCoreServices

public enum ZoetropeError: Error {
  case invalidData
}

private struct Frame {
  fileprivate let delay: Double
  fileprivate let image: UIImage
}

private struct Zoetrope {

  let posterImage: UIImage?
  let loopCount: Int
  let frameCount: Int

  private let frames: [Frame]

  init(data: Data) throws {
    guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil),
          let imageType = CGImageSourceGetType(imageSource), UTTypeConformsTo(imageType, kUTTypeGIF) else {
            throw ZoetropeError.invalidData
    }
    loopCount = try Zoetrope.loopCount(fromImageSource: imageSource)
    frames = Zoetrope.frames(imageSource)
    frameCount = frames.count

    guard !frames.isEmpty else { throw ZoetropeError.invalidData }
    posterImage = frames.first?.image
  }
  
  subscript(imageAtIndex index: Int) -> UIImage? {
    guard index >= 0 && index < frames.count else { return nil }
    return frames[index].image
  }
  
  subscript(delayAtIndex index: Int) -> Double? {
    guard index >= 0 && index < frames.count else { return nil }
    return frames[index].delay
  }

}

private extension Zoetrope {

  static func loopCount(fromImageSource imageSource: CGImageSource) throws -> Int {
    guard let imageProperties = CGImageSourceCopyProperties(imageSource, nil) as? [String: Any],
          let gifProperties = imageProperties[kCGImagePropertyGIFDictionary as String] as? [String: Any],
          let loopCount = gifProperties[kCGImagePropertyGIFLoopCount as String] as? Int else {
            throw ZoetropeError.invalidData
    }
    return loopCount
  }

  static func frames(_ imageSource: CGImageSource) -> [Frame] {
    var frames: [Frame] = []
    for i in 0..<CGImageSourceGetCount(imageSource) {
      if let cgImage = CGImageSourceCreateImageAtIndex(imageSource, i, nil),
         let frameProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, i, nil) as? [String: Any],
         let gifFrameProperties = frameProperties[kCGImagePropertyGIFDictionary as String] as? [String: Any] {

        let previous = i == 0 ? 0.1 : frames[i - 1].delay
        let delay = Zoetrope.delayTime(fromProperties: gifFrameProperties, previousFrameDelay: previous)
        frames.append(Frame(delay: delay, image: UIImage(cgImage: cgImage)))
      }
    }
    return frames
  }

  static func delayTime(fromProperties properties: [String: Any], previousFrameDelay: Double) -> Double {
    let delayTime = (properties[kCGImagePropertyGIFUnclampedDelayTime as String]
      ?? properties[kCGImagePropertyGIFDelayTime as String]) as? Double ?? previousFrameDelay
    return max(0.02, delayTime)
  }

}

/// `ZoetropeImageView` is a `UIImageView` subclass for displaying animated gifs.
///
/// Use like any other `UIImageView` and call `setData:` to pass in the `Data` that represents an animated gif.
///
open class ZoetropeImageView: UIImageView {

  private var currentFrameIndex = 0
  private var loopCountDown = 0
  private var accumulator = 0.0
  private var needsDisplayWhenImageBecomesAvailable = false
  private var currentFrame: UIImage!
  
  private var shouldAnimate: Bool {
    return animatedImage != nil && superview != nil
  }

  open override var image: UIImage? {
    get {
      return animatedImage != nil ? currentFrame : super.image
    }
    set {
      super.image = image
    }
  }

  private lazy var displayLink: CADisplayLink = {
    let displayLink = CADisplayLink(target: self, selector: #selector(displayDidRefresh))
    displayLink.add(to: .main, forMode: .commonModes)
    return displayLink
  }()

  private var animatedImage: Zoetrope! {
    didSet {
      image = nil
      isHighlighted = false
      invalidateIntrinsicContentSize()

      currentFrame = animatedImage.posterImage
      currentFrameIndex = 0
      loopCountDown = animatedImage.loopCount > 0 ? animatedImage.loopCount : .max

      if shouldAnimate {
        startAnimating()
      }

      layer.setNeedsDisplay()
    }
  }

  /// Call setData with the `Data` representation of your gif after adding it to your view.
  ///
  /// - Parameter data: The `Data` representation of your gif
  /// - Throws: `ZoetropeError.InvalidData` if the `data` parameter does not contain valid gif data.
  open func setData(_ data: Data) throws {
    animatedImage = try Zoetrope(data: data)
  }

  open override func didMoveToWindow() {
    super.didMoveToWindow()
    if shouldAnimate {
      startAnimating()
    } else {
      stopAnimating()
    }
  }

  open override func didMoveToSuperview() {
    super.didMoveToSuperview()
    if shouldAnimate {
      startAnimating()
    } else {
      stopAnimating()
    }
  }

  open override var intrinsicContentSize : CGSize {
    guard let _ = animatedImage, let image = image else { return super.intrinsicContentSize }
    return image.size
  }

  open override func startAnimating() {
    if animatedImage != nil {
      displayLink.isPaused = false
    } else {
      super.startAnimating()
    }
  }

  open override func stopAnimating() {
    if animatedImage != nil {
      displayLink.isPaused = true
    } else {
      super.stopAnimating()
    }
  }

  open override var isAnimating : Bool {
    guard animatedImage != nil && !displayLink.isPaused else { return super.isAnimating }
    return true
  }

  @objc private func displayDidRefresh(_ displayLink: CADisplayLink) {
    guard let image = animatedImage[imageAtIndex: currentFrameIndex],
          let delayTime = animatedImage[delayAtIndex: currentFrameIndex] else { return }

    currentFrame = image
    if needsDisplayWhenImageBecomesAvailable {
      layer.setNeedsDisplay()
      needsDisplayWhenImageBecomesAvailable = false
    }

    accumulator += displayLink.duration

    while accumulator >= delayTime {
      accumulator -= delayTime
      currentFrameIndex += 1
      if currentFrameIndex >= animatedImage.frameCount {
        loopCountDown -= 1
        guard loopCountDown > 0 else {
          stopAnimating()
          return
        }
        currentFrameIndex = 0
      }
      needsDisplayWhenImageBecomesAvailable = true
    }
  }

  open override func display(_ layer: CALayer) {
    guard let image = image else { return }
    layer.contents = image.cgImage
  }

  deinit {
    displayLink.invalidate()
  }

}
