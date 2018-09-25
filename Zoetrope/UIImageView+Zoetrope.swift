//
//  Copyright © 2018 Schnaub. All rights reserved.
//

import UIKit

extension UIImageView {

  private static var animationPropertiesKey: UInt8 = 0
  private static var currentFrameKey: UInt8 = 1
  private static var animatedImageKey: UInt8 = 2
  private static var displayLinkKey: UInt8 = 3

  open override func didMoveToWindow() {
    super.didMoveToWindow()
    if window == nil {
      displayLink?.invalidate()
      displayLink = nil
    } else if displayLink == nil {
      displayLink = makeDisplayLink()
      displayLink?.isPaused = false
    }
  }
  
  open override func display(_ layer: CALayer) {
    guard let image = currentFrame else {
      return
    }
    layer.contents = image.cgImage
  }
  
  public func displayGif(_ image: UIImage) {
    guard let zoetrope = image.zoetrope else {
      return
    }
    self.zoetrope = zoetrope
    currentFrame = zoetrope.posterImage
    animationProperties = AnimationProperties()
    animationProperties?.loopCountDown = zoetrope.loopCount > 0 ? zoetrope.loopCount : .max
    displayLink = makeDisplayLink()
    displayLink?.isPaused = false
  }
  
  private func makeDisplayLink() -> CADisplayLink {
    let displayLink = CADisplayLink(target: self, selector: #selector(refreshDisplay))
    displayLink.add(to: .main, forMode: .common)
    return displayLink
  }

  private var animationProperties: AnimationProperties? {
    get {
      return objc_getAssociatedObject(self, &UIImageView.animationPropertiesKey) as? AnimationProperties
    }
    set {
      objc_setAssociatedObject(self, &UIImageView.animationPropertiesKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
  
  private var displayLink: CADisplayLink? {
    get {
      return objc_getAssociatedObject(self, &UIImageView.displayLinkKey) as? CADisplayLink
    }
    set {
      objc_setAssociatedObject(self, &UIImageView.displayLinkKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  private var currentFrame: UIImage? {
    get {
      return objc_getAssociatedObject(self, &UIImageView.currentFrameKey) as? UIImage
    }
    set {
      objc_setAssociatedObject(self, &UIImageView.currentFrameKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  public var zoetrope: Zoetrope? {
    get {
      return objc_getAssociatedObject(self, &UIImageView.animatedImageKey) as? Zoetrope
    }
    set {
      objc_setAssociatedObject(self, &UIImageView.animatedImageKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
  
  @objc
  private func refreshDisplay(_ displayLink: CADisplayLink) {
    guard var animationProperties = animationProperties,
          let zoetrope = zoetrope,
          let image = zoetrope[imageAtIndex: animationProperties.currentFrameIndex],
          let delayTime = zoetrope[delayAtIndex: animationProperties.currentFrameIndex] else {
      return
    }
    
    currentFrame = image
    if animationProperties.needsDisplayWhenImageBecomesAvailable {
      layer.setNeedsDisplay()
      animationProperties.needsDisplayWhenImageBecomesAvailable = false
    }
    animationProperties.accumulator += displayLink.duration
    
    while animationProperties.accumulator >= delayTime {
      animationProperties.accumulator -= delayTime
      animationProperties.currentFrameIndex += 1
      
      if animationProperties.currentFrameIndex >= zoetrope.frameCount {
        animationProperties.loopCountDown -= 1
        guard animationProperties.loopCountDown > 0 else {
          stopDisplayLink()
          return
        }
        animationProperties.currentFrameIndex = 0
      }
      animationProperties.needsDisplayWhenImageBecomesAvailable = true
    }
    
    self.animationProperties = animationProperties
  }
  
  private func stopDisplayLink() {
    displayLink?.isPaused = true
  }

}

private struct AnimationProperties {

  var currentFrameIndex = 0
  var loopCountDown = 0
  var accumulator = 0.0
  var needsDisplayWhenImageBecomesAvailable = false

}
