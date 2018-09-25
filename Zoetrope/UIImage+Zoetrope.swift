//
//  Copyright © 2018 Schnaub. All rights reserved.
//

import UIKit

extension UIImage {

  private static var zoetropeKey: UInt8 = 0

  /// Initialise a UIImage from a gif file located in your app's main bundle or any other bundle if you pass
  /// the optional bundle parameter
  ///
  /// - Parameters:
  ///   - gifName: The gif file name
  ///   - bundle: The Bundle to load the file from. Defaults to `.main`
  public convenience init?(gifName: String, bundle: Bundle = .main) {
    let pathExtension = (gifName as NSString).pathExtension
    let resourceName = (gifName as NSString).deletingPathExtension
    guard let url = bundle.url(forResource: resourceName, withExtension: pathExtension),
          let data = try? Data(contentsOf: url) else {
            return nil
    }
    self.init(gifData: data)
  }

  /// Initialise a UIImage from raw gif data
  ///
  /// - Parameter data: The raw gif `Data`
  public convenience init?(gifData data: Data) {
    guard let zoetrope = try? Zoetrope(data: data) else {
      return nil
    }
    self.init()
    self.zoetrope = zoetrope
  }

  public var zoetrope: Zoetrope? {
    get {
      return objc_getAssociatedObject(self, &UIImage.zoetropeKey) as? Zoetrope
    }
    set {
      objc_setAssociatedObject(self, &UIImage.zoetropeKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

}
