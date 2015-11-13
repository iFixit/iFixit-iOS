//
//  ListViewController.m
//  iFixit
//
//  Created by David Patierno on 3/24/11.
//  Copyright 2011. All rights reserved.
//

class ListViewController: UINavigationController, UINavigationControllerDelegate, UINavigationBarDelegate {

    var categoryTabBarViewController:CategoryTabBarViewController?
    var favoritesButton:UIBarButtonItem?

    override init(rootViewController:UIViewController) {
        super.init(rootViewController:rootViewController)
        
        self.configureProperties()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName:nibNameOrNil, bundle:nibBundleOrNil)
        
        self.configureProperties()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        
        self.configureProperties()
    }

    func configureProperties() {
        let config = Config.currentConfig()
        
        showFavoritesButton(self)
        
        // Set Navigation bar
        if (config.site == .IFixit) {
            self.navigationBar.translucent = false
            
            self.navigationItem.leftBarButtonItem?.tintColor = config.buttonColor
            self.navigationItem.rightBarButtonItem?.tintColor = config.buttonColor
        } else if (config.site == .Mjtrim) {
            self.navigationBar.translucent = false
            self.navigationItem.leftBarButtonItem?.tintColor = config.buttonColor
            self.navigationItem.rightBarButtonItem?.tintColor = config.buttonColor
            
            let navbarTitleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
            
            UINavigationBar.appearance().titleTextAttributes = navbarTitleTextAttributes
        } else if (config.site == .Dozuki) {
            self.navigationBar.translucent = false
            self.navigationItem.leftBarButtonItem?.tintColor = config.buttonColor
            self.navigationItem.rightBarButtonItem?.tintColor = config.buttonColor
        } else {
            self.navigationBar.translucent = false
            
            if (config.buttonColor != nil) {
                self.navigationItem.leftBarButtonItem?.tintColor = config.buttonColor
                self.navigationItem.rightBarButtonItem?.tintColor = config.buttonColor
            }
        }
        
    }

// Override delegate method so we always have control of what to do when we pop a viewcontroller off the stack
    override func popViewControllerAnimated(animated:Bool) -> UIViewController? {
        
        let viewController = super.popViewControllerAnimated(animated)
        
        // 1 view controller means we are at the root of our stack
        if (self.viewControllers.count == 1) {
            
            // Only on iPad do we want to force a selection on tabbar item 0
            if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
                if (UIInterfaceOrientationIsPortrait(viewController!.interfaceOrientation)) {
                    self.categoryTabBarViewController!.hideBrowseInstructions(false)
                } else {
                    self.categoryTabBarViewController!.hideBrowseInstructions(true)
                    self.categoryTabBarViewController!.browseButton!.hidden = true
                }
                
                // Set the category to nil, force a selection on guides, then configure the frame.
                self.categoryTabBarViewController!.selectedIndex = 0
                self.categoryTabBarViewController!.showTabBar(UIInterfaceOrientationIsPortrait(viewController!.interfaceOrientation))
                self.categoryTabBarViewController!.enableTabBarItems(false)
                self.categoryTabBarViewController!.detailGridViewController!.category = nil
                self.categoryTabBarViewController!.detailGridViewController!.tableView.reloadData()
                self.categoryTabBarViewController!.configureSubViewFrame(0)
                
                // Make sure we always hide this on the root view
                self.categoryTabBarViewController!.detailGridViewController!.showNoGuidesImage(false)
                
            } else {
                self.categoryTabBarViewController!.showTabBar(false)
            }
            
            // Force a rotate to ensure our logo is the correct size
            self.viewControllers[0].willAnimateRotationToInterfaceOrientation(viewController!.interfaceOrientation, duration:0)
            // Make sure that we only update the tabbar when we need to
        } else if (viewController is CategoriesViewController) {
            self.categoryTabBarViewController!.updateTabBar((self.topViewController as! CategoriesViewController).categoryMetaData as! [String:AnyObject])
        }
        
        return viewController
    }

    func statusBarBackground() {
        let statusBarView = UIView(frame:CGRectMake(0, 0, 10000, 50))
        statusBarView.backgroundColor = UIColor.blackColor()
    }

    override func pushViewController(viewController:UIViewController, animated: Bool) {
        // Terrible hack, this ensures that the tabbar is in the correct position in landscape, fixes an edgecase
        if (UIDevice.currentDevice().userInterfaceIdiom == .Pad && self.viewControllers.count == 1) {
            if (UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication().statusBarOrientation) ) {
                self.categoryTabBarViewController!.browseButton!.hidden = true
            } else {
                self.categoryTabBarViewController!.browseButton!.hidden = false
            }
            
            self.categoryTabBarViewController!.hideBrowseInstructions(true)
        }
        
        super.pushViewController(viewController, animated:animated)
    }
    
    override func didReceiveMemoryWarning() {
        // Releases the view if it doesn't have a superview.
        super.didReceiveMemoryWarning()
        
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().statusBarHidden = false
        self.statusBarBackground()
    }

    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        
        // This is so bad, but we force a redraw only on iPad+Landscape to avoid an edgecases
        if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation) && UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
            let window = UIApplication.sharedApplication().keyWindow
            let view = window!.subviews[0]
            view.removeFromSuperview()
            window!.addSubview(view)
        }
        
        UIApplication.sharedApplication().setStatusBarOrientation(toInterfaceOrientation, animated:true)
    }

    func showFavoritesButton(viewController:UIViewController) {
        // Create Favorites button if it doesn't already exist and add to navigation controller
        if (self.favoritesButton == nil) {
            self.favoritesButton = UIBarButtonItem(title:NSLocalizedString("Favorites", comment:""),
                style:.Plain,
                target:self, action:"favoritesButtonPushed")
        }
        
        viewController.navigationItem.rightBarButtonItem = self.favoritesButton
    }

    func refresh() {
        // TODO iFixitAPI.checkCredentialsForViewController(self)
    }

    func favoritesButtonPushed() {
        // TODO iFixitAPI.checkCredentialsForViewController(self)
    }

}
