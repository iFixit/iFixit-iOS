//
//  iFixitSplashScreenViewController.swift
//  iFixit
//
//  Created by Amy Eliason on 10/3/15.
//
//

import Foundation
import QuartzCore
import UIKit


extension UIViewController {
    var appDelegate:iFixitAppDelegate {
        return UIApplication.sharedApplication().delegate as! iFixitAppDelegate
    }
}

class iFixitSplashScreenViewController :  UIViewController {
    var initialLoad:  Bool?
    @IBOutlet  var startRepairButton : UIButton!
    @IBOutlet  var splashBackground : UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureButton()
    }
    
    override func viewDidAppear(animated : Bool){
        self.presentStartRepairButton()
        initialLoad = true
    }

    func presentStartRepairButton() {
        UIView.transitionWithView(self.startRepairButton, duration:0.3, options:UIViewAnimationOptions.TransitionCrossDissolve,
            animations:{
                self.startRepairButton.hidden = true
            },
            completion: nil
            
        )
    }

    override func viewWillAppear(animated: Bool) {
        self.reflowImages(self.interfaceOrientation())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func startRepairButtonPushed(sender: UIButton)  {
        self.startRepairButton.backgroundColor = UIColor(red:0.0, green:113.0/255.0, blue:206.0/255.0, alpha:1.0)
        
        UIView.transitionWithView(self.view, duration:1.0, options:UIViewAnimationOptions.TransitionNone,
            animations:{
                self.view.alpha = 0;
            }, completion:{ finished in
                self.appDelegate.showSiteSplash()
                self.view.alpha = 1
            }
        )
    }
    
    
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        coordinator.animateAlongsideTransition({ (UIViewControllerTransitionCoordinatorContext) -> Void in
            
            let orient = UIApplication.sharedApplication().statusBarOrientation
            
            switch orient {
            case .Portrait:
                print("Portrait")
                // Do something
            default:
                print("Anything But Portrait")
                // Do something else
            }
            
            }, completion: { (UIViewControllerTransitionCoordinatorContext) -> Void in
                print("rotation completed")
        })
        
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }

  
    
    func configureButton() {
       
        self.startRepairButton.layer.cornerRadius = 24.0
        self.startRepairButton.clipsToBounds = true
        self.startRepairButton.layer.masksToBounds = true
        self.startRepairButton.titleLabel!.font = UIFont(name: "OpenSans-Bold", size: 17)
        self.startRepairButton.titleLabel!.adjustsFontSizeToFitWidth = true
        
        // was a localized string research
        self.startRepairButton.setTitle("START A REPAIR", forState: UIControlState.Normal)
    }
    
    override func prefersStatusBarHidden() -> Bool
    {
        return true;
    }

    
}