//
//  Copyright © 2018 Schnaub. All rights reserved.
//

import UIKit
import Zoetrope

final class ViewController: UIViewController {

  @IBOutlet private var imageView: UIImageView!

  override func viewDidLoad() {
    super.viewDidLoad()
    guard let image = UIImage(gifName: "animated.gif") else {
      return
    }
    imageView.displayGif(image)
  }

}

