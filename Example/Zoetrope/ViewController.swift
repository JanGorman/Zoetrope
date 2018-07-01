//
//  Copyright (c) 2015 Jan Gorman. All rights reserved.
//

import UIKit
import Zoetrope

class ViewController: UIViewController {

  @IBOutlet private var imageView: ZoetropeImageView!

  override func viewDidLoad() {
    super.viewDidLoad()
    guard let path = Bundle.main.url(forResource: "animated", withExtension: "gif"),
          let data = try? Data(contentsOf: path) else { return }
    do {
      try imageView.setData(data)
    } catch let error {
      print("Invalid gif \(error)")
    }
  }

}

