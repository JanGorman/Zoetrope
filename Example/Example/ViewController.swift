//
//  Copyright © 2018 Schnaub. All rights reserved.
//

import UIKit
import Zoetrope

final class ViewController: UIViewController {

  @IBOutlet private var imageView: UIImageView!

  override func viewDidLoad() {
    super.viewDidLoad()
//    guard let path = Bundle.main.url(forResource: "animated", withExtension: "gif"),
//          let data = try? Data(contentsOf: path) else { return }
//    do {
//      try imageView.setData(data)
//    } catch let error {
//      print("Invalid gif \(error)")
//    }
//    guard let path = Bundle.main.url(forResource: "animated", withExtension: "gif") {
//      return
//    }
    guard let image = UIImage(gifName: "animated.gif") else {
      return
    }
    imageView.setGifImage(image)
    
//    do {
//      try imageView.setData(data)
//    } catch let error {
//      print("Invalid gif \(error)")
//    }
  }

}

