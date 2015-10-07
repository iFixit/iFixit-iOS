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
    
    
        UIView.transitionWithView(self.view, duration:1.0, options:nil,
            animations:{
                self.view.alpha = 0;
            }, completion:{ finished in
                appDelegate.showSiteSplash()
                self.view.alpha = 1
            }
        )
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        coordinator.animateAlongsideTransition({ (UIViewControllerTransitionCoordinatorContext) -> Void in
            
            let orient = UIApplication.sharedApplication().statusBarOrientation
            
            switch orient {
            case .Portrait:
                println("Portrait")
                // Do something
            default:
                println("Anything But Portrait")
                // Do something else
            }
            
            }, completion: { (UIViewControllerTransitionCoordinatorContext) -> Void in
                println("rotation completed")
        })
        
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }

    func shouldAutorotateToInterfaceOrientation( toInterfaceOrientation : UIInterfaceOrientation)
    {
        return true;
    }
    
    func configureButton() {
       
        self.startRepairButton.layer.cornerRadius = 24.0
        self.startRepairButton.clipsToBounds = true
        self.startRepairButton.layer.masksToBounds = true
        self.startRepairButton.titleLabel!.font = UIFont(name: "OpenSans-Bold", size: 17)
        self.startRepairButton.titleLabel!.adjustsFontSizeToFitWidth = true
        self.startRepairButton.setTitle(NSLocalizedString("START A REPAIR", nil) forState:UIControlStateNormal)
    }
    
    override func prefersStatusBarHidden() -> Bool
    {
        return true;
    }

    
}