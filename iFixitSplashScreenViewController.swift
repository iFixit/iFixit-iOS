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

struct ScreenSize
{
    static let SCREEN_WIDTH         = UIScreen.mainScreen().bounds.size.width
    static let SCREEN_HEIGHT        = UIScreen.mainScreen().bounds.size.height
    static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct DeviceType
{
    static let IS_IPHONE_4_OR_LESS  = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5          = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6          = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P         = UIDevice.currentDevice().userInterfaceIdiom == .Phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
    static let IS_IPAD              = UIDevice.currentDevice().userInterfaceIdiom == .Pad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
}

class iFixitSplashScreenViewController :  UIViewController {
    var initialLoad:  Bool?
    @IBOutlet  var startRepairButton : UIButton!
    @IBOutlet  var splashBackground : UIImageView!
   
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        print("init with nib")
        super.init(nibName:nibNameOrNil, bundle:nibBundleOrNil)
   
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
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
                self.startRepairButton.hidden = false
            },
            completion: nil
            
        )
    }

    override func viewWillAppear(animated: Bool) {
        let interfaceOrientation = UIDevice.currentDevice().orientation
        self.reflowImages(interfaceOrientation)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
   
    
    @IBAction func startRepairButtonPushed(sender: UIButton)  {
        self.startRepairButton.backgroundColor = UIColor(red:0.0, green:113.0/255.0, blue:206.0/255.0, alpha:1.0)
        
        UIView.transitionWithView(self.view, duration:1.0, options:.TransitionNone,
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

    func buttonTouchDragOutside(sender:UIButton) {
        self.startRepairButton.backgroundColor = UIColor(red:0.0, green:113.0/255.0, blue:206.0/255.0, alpha:1.0)
    }

    func reflowImages(orientation: UIDeviceOrientation) {
       let landscape = UIDeviceOrientationIsLandscape(orientation)
        let deviceIdiom = UIScreen.mainScreen().traitCollection.userInterfaceIdiom
      
        
        switch (deviceIdiom){
        case .Phone:
            // It's an iPhone
            if landscape{
                if DeviceType.IS_IPHONE_5 {
                    self.startRepairButton.frame = CGRectMake(177, 170, 219, 45)
                    self.splashBackground.image = UIImage(named:"Default-568h-Landscape")
                } else {
                    self.startRepairButton.frame = CGRectMake(131, 170, 219, 45)
                    self.splashBackground.image = UIImage(named:"Default-Landscape")
                }
                
            } else {
                if DeviceType.IS_IPHONE_5 {
                    self.startRepairButton.frame = CGRectMake(51, 292, 218, 45)
                    self.splashBackground.image = UIImage(named:"Default-568h")
                } else {
                    self.startRepairButton.frame = CGRectMake(51, 244, 218, 45)
                    self.splashBackground.image = UIImage(named:"Default")
                }
            }
         case .Pad:
            // It's an iPad
            if landscape {
                self.startRepairButton.frame = CGRectMake(390, 410, 244, 50)
                self.splashBackground.image = UIImage(named:"Default-Landscape")
            } else {
                self.startRepairButton.frame = CGRectMake(263, 550, 244, 50);
                self.splashBackground.image = UIImage(named:"Default-Portrait")
            }
        default:
            // Uh, oh! What could it be?
        self.startRepairButton.frame = CGRectMake(51, 244, 218, 45)
        self.splashBackground.image = UIImage(named:"Default")
        }
    
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

   func buttonTouchedDown(sender: UIButton) {
        self.startRepairButton.backgroundColor = UIColor(red:0.0, green:46.0/255.0, blue:95.0/255.0, alpha:1.0)
    }
    
}