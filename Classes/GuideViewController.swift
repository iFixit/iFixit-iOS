    //
//  GuideViewController.m
//  iFixit
//
//  Created by David Patierno on 8/9/10.
//  Copyright 2010 iFixit. All rights reserved.
//

import UIKit

class GuideViewController: UIViewController, UIScrollViewDelegate, UIAlertViewDelegate {

    let dummyVC = UIViewController()
    
    @IBOutlet weak var spinner:UIActivityIndicatorView!
    @IBOutlet weak var navBar:UINavigationBar!
    @IBOutlet weak var scrollView:UIScrollView!
    @IBOutlet weak var pageControl:UIPageControl!
    
    var bookmarker:GuideBookmarker!
    var viewControllers:[UIViewController] = []
    var guide:Guide?
    var iGuideid = 0
    var shouldLoadPage = 0
    var memoryCache:NSCache?

    // To be used when scrolls originate from the UIPageControl
    var pageControlUsed = false
    var offlineGuide = false

    convenience init(guide:Guide) {
        self.init(guideid:0, guide:guide)
    }

    convenience init(guideid:NSNumber) {
        self.init(guideid:guideid, guide:nil)
    }
    
    init(guideid:NSNumber, guide:Guide?) {
        
        super.init(nibName:"GuideView", bundle:nil)
        
        self.guide = guide
        self.iGuideid = guide?.iGuideid ?? Int(guideid)
        self.shouldLoadPage = 0
        self.modalTransitionStyle = .FlipHorizontal
        
        let b = GuideBookmarker()
        b.delegate = self
        self.bookmarker = b
        
        UIApplication.sharedApplication().idleTimerDisabled = true
        
        
        // Analytics
        let gaInfo = GAIDictionaryBuilder.createEventWithCategory("Guide", action:"Viewed", label:"Guide", value:self.iGuideid).build()
        GAI.sharedInstance().defaultTracker.send(gaInfo as [NSObject:AnyObject])
        
        if (self.memoryCache == nil) {
            self.memoryCache = NSCache()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }

    override func viewWillAppear(animated:Bool) {
        // Make sure we have the correct orientation when our
        // view appears, this fixes orientation issues regarding
        // rotating after logging in.
        self.willRotateToInterfaceOrientation(UIApplication.sharedApplication().statusBarOrientation, duration:0)
        self.pageControl.hidden = true
    }

    override func viewDidLoad() {
        let config = Config.currentConfig()
        
        super.viewDidLoad()
        
        // Replace black with concrete.
        var bgColor = config.backgroundColor
        if bgColor == UIColor.whiteColor() {
            bgColor = UIColor(patternImage:UIImage(named:"concreteBackgroundWhite.png")!)
        } else {
            bgColor = UIColor(patternImage:UIImage(named:"concreteBackground.png")!)
        }
        
        self.view.backgroundColor = bgColor
        
        if (self.guide != nil) {
            self.gotGuide(self.guide)
        } else {
            // Load the data
            iFixitAPI.sharedInstance.getGuide(self.iGuideid, handler:{ (aGuide) in
                self.gotGuide(aGuide)
            })
            
        }
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            
            // Landscape
            if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
                spinner.frame = CGRectMake(494.0, 333.0, 37.0, 37.0);
            }
            // Portrait
            else {
                spinner.frame = CGRectMake(365.0, 450.0, 37.0, 37.0);
            }
            
        }
        
        self.navigationController?.navigationBar.translucent = false
    }

    func showOrHidePageControlForInterface(orientation:UIInterfaceOrientation) {
        UIView.transitionWithView(pageControl,
                          duration:0.3, options:.TransitionCrossDissolve,
                        animations:{
                            // We only want to hide on the intro page and in landscape
                            self.pageControl.hidden = (UIInterfaceOrientationIsLandscape(orientation) && self.pageControl.currentPage == 0 && UIDevice.currentDevice().userInterfaceIdiom == .Phone);
                            
                        }, completion:nil)
    }
    
    func closeGuide() {
        if ((bookmarker.poc?.popoverVisible) != nil) {
            bookmarker.poc?.dismissPopoverAnimated(true)
        }
        
        // Hide the guide. Only on iOS 7 do we want to cross disolve instead of horizontal flip
        self.modalTransitionStyle = .CrossDissolve
        
        dismissViewControllerAnimated(true, completion:nil)
    }

    func alertView(alertView:UIAlertView, clickedButtonAtIndex buttonIndex:Int) {
        // Try Again
        if (buttonIndex != 0) {
            iFixitAPI.sharedInstance.getGuide(self.iGuideid, handler:{ (aGuide) in
                self.gotGuide(aGuide)
            })
        }
        // Cancel
        else {
            dismissViewControllerAnimated(true, completion:nil)
        }
    }

    func adjustScrollViewContentSizeForInterfaceOrientation(interfaceOrientation:UIInterfaceOrientation) {
        let numPages = (self.guide?.steps.count ?? 0) + 1
  //      let numPages = (self.guide?.steps.count)! + 1
        var frame:CGRect!
        let screenSize = UIScreen.mainScreen().bounds.size
        
        // iPad
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            // Landscape
            if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
                spinner.frame = CGRectMake(494.0, 333.0, 37.0, 37.0)
                // A nasty hack to make sure our view frame isn't cut off.
                // In iOS 8, screenSize.height returns a different value before and after
                // the view is drawn, so it'd be wrong the first time around. So we hardcode it.
                frame = CGRectMake(0, 0, 1024.0, 724.0)
            }
            // Portrait
            else {
                spinner.frame = CGRectMake(365.0, 450.0, 37.0, 37.0)
                
                frame = CGRectMake(0, 0, 768.0, 980.0)
            }
        }
        // iPhone
        else {
            // Landscape
            if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
                frame = CGRectMake(0, 0, screenSize.height, screenSize.width - 44)
            }
            // Portrait
            else {
                frame = CGRectMake(0, 0, screenSize.width, screenSize.height - 64)
            }
        }
        
        scrollView.frame = frame;
        scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * CGFloat(numPages), scrollView.frame.size.height)
    }

    func gotGuide(guide:Guide?) {
        spinner.stopAnimating()
        
        if (guide == nil) {
            let alertView = UIAlertView(title:NSLocalizedString("Error", comment:""),
                                        message:NSLocalizedString("Failed loading guide.", comment:""),
                                        delegate:self,
                                        cancelButtonTitle:NSLocalizedString("Cancel", comment:""),
                                        otherButtonTitles:NSLocalizedString("Try Again", comment:""))
            alertView.show()
            return
        }
        
        self.guide = guide
        
        // Steps plus one for intro
        let numPages = (self.guide!.steps.count) + 1
        
        // view controllers are created lazily
        // in the meantime, load the array with placeholders which will be replaced on demand
        var controllers:[UIViewController] = []
        for (var i = 0; i < numPages; i += 1) {
            controllers.append(dummyVC)
        }
        self.viewControllers = controllers
        
        // a page is the width of the scroll view
        scrollView.pagingEnabled = true
        self.adjustScrollViewContentSizeForInterfaceOrientation(self.interfaceOrientation)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.scrollsToTop = false
        scrollView.delegate = self
        
        // Steps plus one for intro
        pageControl.numberOfPages = numPages
        pageControl.currentPage = 0
        pageControl.hidden = true
        
        // Setup the navigation items to show back arrow and bookmarks button
        var title = guide!.title
        if UIDevice.currentDevice().userInterfaceIdiom != .Pad && guide!.subject.characters.count > 0 {
            title = guide!.subject
        }
        
        self.title = title
        
        
        let doneButton = UIBarButtonItem(title:NSLocalizedString("Done", comment:""),
                                                                       style:.Done,
                                                                      target:self,
                                                                      action:"closeGuide")
        
        self.navigationItem.leftBarButtonItem = doneButton
        
        bookmarker.setNewGuideId(self.guide!.iGuideid)
        
        if (shouldLoadPage != 0) {
            self.showPage(shouldLoadPage)
        } else {
            self.loadScrollViewWithPage(0)
            self.loadScrollViewWithPage(1)
        }
    }

    func showPage(page:Int) {
        if (self.guide != nil) {
            pageControl.currentPage = page
            self.changePage(nil)
        } else {
            shouldLoadPage = page
        }
    }

    func loadScrollViewWithPage(page:Int) {
        
        if (page < 0 || page >= pageControl.numberOfPages) {
            return
        }
        
        let stepNumber = page - 1
        
        // replace the placeholder if necessary
        var controller = viewControllers[page]
        if controller == dummyVC {
            if (stepNumber == -1) {
                controller = GuideIntroViewController(guide:self.guide!)
                (controller as! GuideIntroViewController).delegate = self
            } else {
                controller = GuideStepViewController(step:self.guide!.steps[stepNumber], withAbsolute:stepNumber + 1)
                (controller as! GuideStepViewController).delegate = self
                (controller as! GuideStepViewController).guideViewController = self
            }
            
            viewControllers[page] = controller
        }
        
        // add the controller's view to the scroll view
        if (nil == controller.view.superview) {
            var frame = scrollView.frame
            frame.origin.x = frame.size.width * CGFloat(page)
            frame.origin.y = 0
            controller.view.frame = frame
            controller.willRotateToInterfaceOrientation(self.interfaceOrientation, duration:0)
            scrollView.addSubview(controller.view)
        }
    }

    func scrollViewDidScroll(sender:UIScrollView) {
        
        // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
        // which a scroll event generated from the user hitting the page control triggers updates from
        // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
        if (pageControlUsed) {
            // do nothing - the scroll was initiated from the page control, not the user dragging
            return
        }
        
        // Switch the indicator when more than 50% of the previous/next page is visible
        let pageWidth = scrollView.frame.size.width;
        let page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1
        pageControl.currentPage = Int(page)
        
        self.showOrHidePageControlForInterface(self.interfaceOrientation)
    }

// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
    func scrollViewWillBeginDragging(scrollView:UIScrollView) {
        pageControlUsed = false
    }

    func unloadViewControllers() {
    let page = pageControl.currentPage
    
    // Unload the views+controllers which are no longer visible
    for (var i = 2; i < pageControl.numberOfPages; i += 1) {
        let distance = fabs(CGFloat(page - i + 1))
        if (distance > 2.0) {
            let vc = viewControllers[i]
            if vc != dummyVC {
                vc.viewWillDisappear(false)
                vc.view.removeFromSuperview()
                vc.view = nil
                viewControllers[i] = dummyVC
            }
        }
    }
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
    func scrollViewDidEndDecelerating(scrollView:UIScrollView) {
        pageControlUsed = false
        
        self.preloadForCurrentPage(pageControl.currentPage)
        self.unloadViewControllers()
        
        // If the user scrolls super fast, a view controller may be null, this will force a view load if we come across that behavior
        if viewControllers[pageControl.currentPage] == dummyVC {
            self.scrollViewWillBeginDragging(scrollView)
        }
        
        // Only load secondary images if we are looking at the current view for longer than half a second
        if (pageControl.currentPage > 0) {
            let controller = viewControllers[pageControl.currentPage]
            if controller is GuideStepViewController {
                (controller as! GuideStepViewController).moviePlayer?.prepareToPlay()
            }
            controller.performSelector("loadSecondaryImages", withObject:nil, afterDelay:0.8)
        }
    }

    @IBAction func changePage(sender:AnyObject?) {
        let page = pageControl.currentPage
        
        // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
        self.preloadForCurrentPage(page)
        self.unloadViewControllers()
        
        // update the scroll view to the appropriate page
        var frame = scrollView.frame
        frame.origin.x = frame.size.width * CGFloat(page)
        frame.origin.y = 0
        
        scrollView.scrollRectToVisible(frame, animated:sender != nil)
        
        // Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
        pageControlUsed = true
        
        // Only load secondary images if we are looking at the current view for longer than .8 second
        if (page > 0) {
            let controller = viewControllers[pageControl.currentPage]
            if controller is GuideStepViewController {
                (controller as! GuideStepViewController).moviePlayer?.prepareToPlay()
            }
            viewControllers[page].performSelector("loadSecondaryImages", withObject:nil, afterDelay:0.8)
            self.showOrHidePageControlForInterface(self.interfaceOrientation)
        }
    }

    func preloadForCurrentPage(page:Int) {
        
        self.loadScrollViewWithPage(page - 1)
        self.loadScrollViewWithPage(page)
        self.loadScrollViewWithPage(page + 1)
    }

    override func willRotateToInterfaceOrientation(toInterfaceOrientation:UIInterfaceOrientation, duration:NSTimeInterval) {
        let page = pageControl.currentPage
        
        self.adjustScrollViewContentSizeForInterfaceOrientation(toInterfaceOrientation)
        
//        if (viewControllers != nil) {
            self.showOrHidePageControlForInterface(toInterfaceOrientation)
//        }
        
        for (var i=0; i<viewControllers.count; i += 1) {
            let vc = viewControllers[i]
            
            if vc != dummyVC {
                var frame = scrollView.frame
                frame.origin.x = frame.size.width * CGFloat(i)
                frame.origin.y = 0
                
                vc.view.frame = frame
                vc.willRotateToInterfaceOrientation(toInterfaceOrientation, duration:0)
            }
        }
        
        self.showPage(page)
    }

    override func viewDidAppear(animated:Bool) {
        self.showOrHidePageControlForInterface(self.interfaceOrientation)
    }

    deinit {
        UIApplication.sharedApplication().idleTimerDisabled = false
    }

}
