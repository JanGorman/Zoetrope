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

public struct Zoetrope {

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

    guard !frames.isEmpty else {
      throw ZoetropeError.invalidData
    }
    posterImage = frames.first?.image
  }
  
  subscript(imageAtIndex index: Int) -> UIImage? {
    guard index >= 0 && index < frames.count else {
      return nil
    }
    return frames[index].image
  }
  
  subscript(delayAtIndex index: Int) -> Double? {
    guard index >= 0 && index < frames.count else {
      return nil
    }
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
        let delay = delayTime(fromProperties: gifFrameProperties, previousFrameDelay: previous)
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
