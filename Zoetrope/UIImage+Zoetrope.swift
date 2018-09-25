//
//  Copyright © 2018 Schnaub. All rights reserved.
//

import UIKit

extension UIImage {

  private static var zoetropeKey: UInt8 = 0

  public convenience init?(gifName: String) {
    let pathExtension = (gifName as NSString).pathExtension
    let resourceName = (gifName as NSString).deletingPathExtension
    guard let url = Bundle.main.url(forResource: resourceName, withExtension: pathExtension),
          let data = try? Data(contentsOf: url) else {
            return nil
    }
    self.init(gifData: data)
  }


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
