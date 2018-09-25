//
//  Copyright © 2018 Schnaub. All rights reserved.
//

import UIKit

extension UIImageView {

  private static var animationPropertiesKey: UInt8 = 0
  private static var currentFrameKey: UInt8 = 1
  private static var animatedImageKey: UInt8 = 2

  public func setGifImage(_ image: UIImage) {
    
  }

  private var animationProperties: AnimationProperties? {
    get {
      return objc_getAssociatedObject(self, &UIImageView.animationPropertiesKey) as? AnimationProperties
    }
    set {
      objc_setAssociatedObject(self, &UIImageView.animationPropertiesKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
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

  public var animatedImage: UIImage? {
    get {
      return (objc_getAssociatedObject(self, &UIImageView.animatedImageKey) as? UIImage) != nil ? currentFrame : image
    }
    set {
      objc_setAssociatedObject(self, &UIImageView.animatedImageKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

}

private struct AnimationProperties {

  var currentFrameIndex = 0
  var loopCountDown = 0
  var accumulator = 0.0
  var needsDisplayWhenImageBecomesAvailable = false

}
