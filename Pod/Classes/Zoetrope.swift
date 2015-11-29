//
//  Copyright (c) 2015 Jan Gorman. All rights reserved.
//

import UIKit
import ImageIO
import MobileCoreServices

public enum ZoetropeError: ErrorType {
    case InvalidData
}

private struct Frame {
    private let delay: Double
    private let image: UIImage
}

private struct Zoetrope {

    let posterImage: UIImage?
    let loopCount: Int
    let frameCount: Int

    private let framesForIndexes: [Int: Frame]

    init(data: NSData) throws {
        guard let imageSource = CGImageSourceCreateWithData(data, nil),
                  imageType = CGImageSourceGetType(imageSource)
            where UTTypeConformsTo(imageType, kUTTypeGIF) else {
                throw ZoetropeError.InvalidData
        }
        loopCount = try Zoetrope.loopCountFromImageSource(imageSource)
        framesForIndexes = Zoetrope.frames(imageSource)
        frameCount = framesForIndexes.count
        guard !framesForIndexes.isEmpty else {
            throw ZoetropeError.InvalidData
        }
        posterImage = framesForIndexes[0]?.image
    }

    func imageAtIndex(index: Int) -> UIImage? {
        return framesForIndexes[index]?.image
    }

    func delayAtIndex(index: Int) -> Double? {
        return framesForIndexes[index]?.delay
    }

}

private extension Zoetrope {
    
    static func loopCountFromImageSource(imageSource: CGImageSource) throws -> Int {
        guard let imageProperties: NSDictionary = CGImageSourceCopyProperties(imageSource, nil),
            gifProperties = imageProperties[kCGImagePropertyGIFDictionary as String] as? NSDictionary,
            loopCount = gifProperties[kCGImagePropertyGIFLoopCount as String] as? Int else {
                throw ZoetropeError.InvalidData
        }
        return loopCount
    }
    
    static func frames(imageSource: CGImageSource) -> [Int: Frame] {
        var frames = [Int: Frame]()
        for i in 0..<CGImageSourceGetCount(imageSource) {
            if let cgImage = CGImageSourceCreateImageAtIndex(imageSource, i, nil),
                frameProperties: NSDictionary = CGImageSourceCopyPropertiesAtIndex(imageSource, i, nil),
                gifFrameProperties = frameProperties[kCGImagePropertyGIFDictionary as String] as? NSDictionary {
                    let previous: Double! = i == 0 ? 0.1 : frames[i - 1]?.delay
                    let delay = Zoetrope.delayTimefromProperties(gifFrameProperties, previousFrameDelay: previous)
                    frames[i] = Frame(delay: delay, image: UIImage(CGImage: cgImage))
            }
        }
        return frames
    }
    
    static func delayTimefromProperties(properties: NSDictionary, previousFrameDelay: Double) -> Double {
        var delayTime: Double! = (properties[kCGImagePropertyGIFUnclampedDelayTime as String]
            ?? properties[kCGImagePropertyGIFDelayTime as String]) as? Double
        if delayTime == nil {
            delayTime = previousFrameDelay
        }
        if delayTime < (0.02 - DBL_EPSILON) {
            delayTime = 0.02
        }
        return delayTime
    }
    
}

/**
    `ZoetropeImageView` is a `UIImageView` subclass for displaying animated gifs.
 
    Use like any other `UIImageView` and call `setData:` to pass in the `NSData`
    that represents your animated gif.
*/
public class ZoetropeImageView: UIImageView {
    
    private var currentFrameIndex = 0
    private var loopCountDown = 0
    private var accumulator = 0.0
    private var needsDisplayWhenImageBecomesAvailable = false
    private var currentFrame: UIImage!
    
    public override var image: UIImage? {
        get {
            return animatedImage != nil ? currentFrame : super.image
        }
        set {
            super.image = image
        }
    }

    private lazy var displayLink: CADisplayLink = { [unowned self] in
        let displayLink = CADisplayLink(target: self, selector: "displayDidRefresh:")
        displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
        return displayLink
    }()

    private var animatedImage: Zoetrope! {
        didSet {
            image = nil
            highlighted = false
            invalidateIntrinsicContentSize()
            
            currentFrame = animatedImage.posterImage
            currentFrameIndex = 0
            loopCountDown = animatedImage.loopCount > 0 ? animatedImage.loopCount : NSIntegerMax

            if shouldAnimate {
                startAnimating()
            }

            layer.setNeedsDisplay()
        }
    }

    /**
        Call setData with the `NSData` representation of your gif after adding it to your view.
     
        - Parameter data:   The `NSData` representation of your gif
        - Throws: `ZoetropeError.InvalidData` if the `data` parameter does not contain valid gif data.
    */
    public func setData(data: NSData) throws {
        animatedImage = try Zoetrope(data: data)
    }

    private var shouldAnimate: Bool {
        return animatedImage != nil && superview != nil
    }
    
    public override func didMoveToWindow() {
        super.didMoveToWindow()
        if shouldAnimate {
            startAnimating()
        } else {
            stopAnimating()
        }
    }
    
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if shouldAnimate {
            startAnimating()
        } else {
            stopAnimating()
        }
    }
    
    public override func intrinsicContentSize() -> CGSize {
        guard let _ = animatedImage, image = image else {
            return super.intrinsicContentSize()
        }
        return image.size
    }
    
    public override func startAnimating() {
        if animatedImage != nil {
            displayLink.paused = false
        } else {
            super.startAnimating()
        }
    }
    
    public override func stopAnimating() {
        if animatedImage != nil {
            displayLink.paused = true
        } else {
            super.stopAnimating()
        }
    }
    
    public override func isAnimating() -> Bool {
        guard animatedImage != nil && !displayLink.paused else {
            return super.isAnimating()
        }
        return true
    }
    
    func displayDidRefresh(displayLink: CADisplayLink) {
        if let image = animatedImage.imageAtIndex(currentFrameIndex),
               delayTime = animatedImage.delayAtIndex(currentFrameIndex) {
            currentFrame = image
            if needsDisplayWhenImageBecomesAvailable {
                layer.setNeedsDisplay()
                needsDisplayWhenImageBecomesAvailable = false
            }

            accumulator += displayLink.duration
            
            while accumulator >= delayTime {
                accumulator -= delayTime
                ++currentFrameIndex
                if currentFrameIndex >= animatedImage.frameCount {
                    --loopCountDown
                    guard loopCountDown > 0 else {
                        stopAnimating()
                        return
                    }
                    currentFrameIndex = 0
                }
                needsDisplayWhenImageBecomesAvailable = true
            }
            
        }
    }
    
    public override func displayLayer(layer: CALayer) {
        guard let image = image else {
            return
        }
        layer.contents = image.CGImage
    }
    
    deinit {
        displayLink.invalidate()
    }

}
