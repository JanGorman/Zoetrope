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

  fileprivate let framesForIndexes: [Int: Frame]

  init(data: Data) throws {
    guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil),
          let imageType = CGImageSourceGetType(imageSource), UTTypeConformsTo(imageType, kUTTypeGIF) else {
            throw ZoetropeError.invalidData
    }
    loopCount = try Zoetrope.loopCount(fromImageSource: imageSource)
    framesForIndexes = Zoetrope.frames(imageSource)
    frameCount = framesForIndexes.count

    guard !framesForIndexes.isEmpty else { throw ZoetropeError.invalidData }
    posterImage = framesForIndexes[0]?.image
  }

  func image(atIndex index: Int) -> UIImage? {
    return framesForIndexes[index]?.image
  }

  func delay(atIndex index: Int) -> Double? {
    return framesForIndexes[index]?.delay
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

  static func frames(_ imageSource: CGImageSource) -> [Int: Frame] {
    var frames: [Int: Frame] = [:]
    for i in 0..<CGImageSourceGetCount(imageSource) {
      if let cgImage = CGImageSourceCreateImageAtIndex(imageSource, i, nil),
         let frameProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, i, nil) as? [String: Any],
         let gifFrameProperties = frameProperties[kCGImagePropertyGIFDictionary as String] as? [String: Any] {
         let previous: Double! = i == 0 ? 0.1 : frames[i - 1]?.delay
         let delay = Zoetrope.delayTime(fromProperties: gifFrameProperties, previousFrameDelay: previous)
        frames[i] = Frame(delay: delay, image: UIImage(cgImage: cgImage))
      }
    }
    return frames
  }

  static func delayTime(fromProperties properties: [String: Any], previousFrameDelay: Double) -> Double {
    var delayTime: Double! = (properties[kCGImagePropertyGIFUnclampedDelayTime as String]
      ?? properties[kCGImagePropertyGIFDelayTime as String]) as? Double
    if delayTime == nil {
      delayTime = previousFrameDelay
    }
    if delayTime < (0.02 - .ulpOfOne) {
      delayTime = 0.02
    }
    return delayTime
  }

}

/**
 * `ZoetropeImageView` is a `UIImageView` subclass for displaying animated gifs.
 *
 * Use like any other `UIImageView` and call `setData:` to pass in the `Data`
 * that represents your animated gif.
 */
open class ZoetropeImageView: UIImageView {

  fileprivate var currentFrameIndex = 0
  fileprivate var loopCountDown = 0
  fileprivate var accumulator = 0.0
  fileprivate var needsDisplayWhenImageBecomesAvailable = false
  fileprivate var currentFrame: UIImage!

  open override var image: UIImage? {
    get {
      return animatedImage != nil ? currentFrame : super.image
    }
    set {
      super.image = image
    }
  }

  fileprivate lazy var displayLink: CADisplayLink = {
    let displayLink = CADisplayLink(target: self, selector: #selector(displayDidRefresh))
    displayLink.add(to: .main, forMode: .commonModes)
    return displayLink
  }()

  fileprivate var animatedImage: Zoetrope! {
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

  /**
   * Call setData with the `Data` representation of your gif after adding it to your view.
   *
   * - Parameter data:   The `Data` representation of your gif
   * - Throws: `ZoetropeError.InvalidData` if the `data` parameter does not contain valid gif data.
   */
  open func setData(_ data: Data) throws {
    animatedImage = try Zoetrope(data: data)
  }

  fileprivate var shouldAnimate: Bool {
    return animatedImage != nil && superview != nil
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

  @objc func displayDidRefresh(_ displayLink: CADisplayLink) {
    guard let image = animatedImage.image(atIndex: currentFrameIndex),
          let delayTime = animatedImage.delay(atIndex: currentFrameIndex) else { return }

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
