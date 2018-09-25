//
//  Copyright © 2018 Schnaub. All rights reserved.
//

import UIKit

extension UIImage {

  private static var zoetropeKey: UInt8 = 0

  public convenience init?(gifName: String) {
    guard let url = Bundle.main.url(forResource: gifName,
                                    withExtension: (gifName as NSString).pathExtension),
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
