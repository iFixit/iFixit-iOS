//
//  DozukiSplashViewController.m
//  iFixit
//
//  Created by David Patierno on 8/16/11.
//  Copyright (c) 2011 iFixit. All rights reserved.
//

class DozukiSplashViewController : UIViewController,UINavigationControllerDelegate {

    @IBOutlet weak var introView:UIView!
    @IBOutlet weak var dozukiSlogan:UILabel!
    @IBOutlet weak var dozukiDescription:UILabel!
    @IBOutlet weak var getStarted:UILabel!

    var nextViewController:UINavigationController!
    var showingList = false
    
    init() {
        
        super.init(nibName:"DozukiSplashView", bundle:nil)

        // Custom initialization
        showingList = false
        
        // Create a navigation controller and load the info view.
        let divc = DozukiInfoViewController(nibName:"DozukiInfoView", bundle:nil)
        let nvc = UINavigationController(rootViewController:divc)
        nvc.delegate = self
        divc.showList()
        
        nvc.modalPresentationStyle = .FormSheet
        nvc.modalTransitionStyle = UIDevice.currentDevice().userInterfaceIdiom == .Pad ?
            .FlipHorizontal : .CrossDissolve;
        self.nextViewController = nvc
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }

    // MARK: - View lifecycle

    func configureLabels() {
        self.dozukiSlogan.text = NSLocalizedString("Visual is better.", comment:"")
        self.dozukiDescription.text = NSLocalizedString("A modern documentation platform for everything from work instructions to product support.", comment:"")
        self.getStarted.text = NSLocalizedString("Get Started", comment:"")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureLabels()
        
        if (showingList) {
            self.introView.hidden = true
        }
    }

    override func viewWillAppear(animated:Bool) {
        for view in self.introView.subviews {
            view.alpha = 0.0
        }
    }

    override func viewDidAppear(animated:Bool) {
        UIView.animateWithDuration(0.5, animations:{
            for view in self.introView.subviews {
                view.alpha = 1.0
            }
        })
    }

    @IBAction func getStarted(sender:AnyObject?) {
        let originalFrame = self.introView.frame
        
        UIView.animateWithDuration(0.3, animations:{
            var frame = originalFrame
            frame.origin.x = -frame.size.width
            self.introView.frame = frame
        }, completion:{ (finished) in
            self.introView.hidden = false
            self.introView.frame = originalFrame
            self.showingList = false
        })
        
        if nextViewController.viewControllers.count == 1 {
            nextViewController.viewControllers = [nextViewController.viewControllers[0]]
            (nextViewController.topViewController as! DozukiInfoViewController).showList()
        }
        
        self.presentViewController(self.nextViewController, animated:true, completion:nil)
    }

    func navigationController(navigationController:UINavigationController, willShowViewController viewController:UIViewController, animated:Bool) {
        
        if viewController is DozukiSelectSiteViewController {
            return
        }
        
        self.dismissViewControllerAnimated(true, completion:nil)
        
        let originalFrame = self.introView.frame
        var frame = originalFrame;
        frame.origin.x = -originalFrame.size.width
        self.introView.frame = frame
        self.introView.hidden = false
        
        let delay:NSTimeInterval = UIDevice.currentDevice().userInterfaceIdiom == .Pad ? 0.3 : 0.0
        UIView.animateWithDuration(0.3, delay:delay, options:.CurveEaseInOut, animations:{
            self.introView.frame = originalFrame
        }, completion:{ (finished) in
            self.showingList = false
        })
    }

}
