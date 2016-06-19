//
//  LoginBackgroundViewController.m
//  iFixit
//
//  Created by David Patierno on 2/13/12.
//  Copyright (c) 2012 iFixit. All rights reserved.
//

class LoginBackgroundViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bgColor = Config.currentConfig().backgroundColor
        let imageName =  (bgColor == UIColor.whiteColor()) ? "concreteBackgroundWhite.png" : "concreteBackground.png"
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named:imageName)!)
    }

}
