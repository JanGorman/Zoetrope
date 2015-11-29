//
//  Copyright (c) 2015 Jan Gorman. All rights reserved.
//

import UIKit
import Zoetrope

class ViewController: UIViewController {

    @IBOutlet var imageView: ZoetropeImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let path = NSBundle.mainBundle().URLForResource("animated", withExtension: "gif"),
            data = NSData(contentsOfURL: path) {
                do {
                    try imageView.setData(data)
                } catch let error {
                    print("Invalid gif \(error)")
                }
        }
    }

}

