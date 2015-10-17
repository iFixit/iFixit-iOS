//
//  GuideBookmarker.m
//  iFixit
//
//  Created by David Patierno on 4/6/11.
//  Copyright 2011 iFixit. All rights reserved.
//

import UIKit

class GuideBookmarker : NSObject, LoginViewControllerDelegate {
    
    var delegate: UIViewController?
    var poc:UIPopoverController?
    var lvc:LoginViewController!
    var progress:UIProgressView?
    var iGuideid = 0
    
    override init() {
        super.init()
        let vc = LoginViewController()
        vc.delegate = self
        self.lvc = vc
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            let pc = UIPopoverController(contentViewController:vc)
            self.poc = pc
        }
    }

    func setNewGuideId(newGuideid:Int) {
        self.iGuideid = newGuideid
        
        let guideExists = (GuideBookmarks.sharedBookmarks()?.guideForGuideid(self.iGuideid) != nil) ? true : false
        
//        if ([delegate isKindOfClass:[GuideViewController class]]) {
            //        [delegate setOfflineGuide:guideExists];
//        }
        
        if (guideExists == false) {
            let bookmarkButton = UIBarButtonItem(title:NSLocalizedString("Favorite", comment:""),
                style:.Plain,
                target:self,
                action:"bookmark:")
            self.delegate!.navigationItem.rightBarButtonItem = bookmarkButton
        }
        else {
            self.bookmarked()
        }
    }

    func bookmark(button:UIBarButtonItem?) {
        // Require a login
        if (iFixitAPI.sharedInstance.user == nil) {
            // iPad is easy, just show the popover.
            if (poc != nil) {
                if (poc!.popoverVisible) {
                    poc!.dismissPopoverAnimated(true)
                }
                else {
                    self.resizePopoverViewControllerContents()
                    poc!.presentPopoverFromBarButtonItem(button!, permittedArrowDirections:.Any, animated:true)
                }
            }
                // On the iPhone, we need to first wrap the login view in a nav controller
            else {
                iFixitAPI.checkCredentialsForViewController(self)
            }
            
            return;
        }
        else {
            if (poc != nil) {
                poc!.dismissPopoverAnimated(true)
                lvc.dismissViewControllerAnimated(true, completion:nil)
            }
        }
        
        // Show a spinner
        let spinner = UIActivityIndicatorView(frame:CGRectMake(0, 0, 20, 20))
        spinner.activityIndicatorViewStyle = .White
        let b = UIBarButtonItem(customView:spinner)
        spinner.startAnimating()
        self.delegate!.navigationItem.rightBarButtonItem = b
        
        // Save online
        //    [[iFixitAPI sharedInstance] like:iGuideid forObject:self withSelector:@selector(liked:)];
        iFixitAPI.sharedInstance.like(iGuideid, handler:{ (results) in
            self.liked(results)
        })
        
    }

// Resize the popover view controller contents
    func resizePopoverViewControllerContents() {
        let screenSize = UIScreen.mainScreen().bounds.size
        let isLandscape = UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation)
        poc!.popoverContentSize = isLandscape ? CGSizeMake(320, screenSize.width / 2) : CGSizeMake(320, screenSize.height / 2)
    }

    func liked(result:[String:AnyObject]?) {
        let config = Config.currentConfig()
        
        if (result!["statusCode"] as! Int) != 204 {
            iFixitAPI.displayConnectionErrorAlert()
            self.setNewGuideId(self.iGuideid)
            self.bookmark(self.delegate!.navigationItem.rightBarButtonItem)
            return
        }
        
        // Show a progress bar
        let progressContainer = UIView(frame:CGRectMake(0, 0, 90, 40))
        let progressLabel = UILabel(frame:CGRectMake(0, 2, 90, 20))
        progressLabel.textAlignment = .Center
        progressLabel.font = UIFont.italicSystemFontOfSize(12.0)
        progressLabel.backgroundColor = UIColor.clearColor()
        
        if (config.site == .Make || config.site == .MakeDev) {
            progressLabel.textColor = UIColor.darkGrayColor()
            progressLabel.shadowColor = UIColor.whiteColor()
        } else {
            progressLabel.textColor = UIColor.whiteColor()
            progressLabel.shadowColor = UIColor.darkGrayColor()
        }
        
        progressLabel.shadowOffset = CGSizeMake(0.0, -1.0)
        progressLabel.text = NSLocalizedString("Downloading...", comment:"")
        progressContainer.addSubview(progressLabel)
        
        let p = UIProgressView(frame:CGRectMake(0, 25, 85, 10))
        progressContainer.addSubview(p)
        self.progress = p
        
        let progressItem = UIBarButtonItem(customView:progressContainer)
        self.delegate!.navigationItem.rightBarButtonItem = progressItem
        
        // Save the guide in the bookmarks list.
        GuideBookmarks.sharedBookmarks()!.addGuideid(iGuideid, forBookmarker:self)
        
        // Analytics
        let gaInfo = GAIDictionaryBuilder.createEventWithCategory("Guide", action: "download", label: "Guide downloaded", value: iGuideid).build()
        GAI.sharedInstance().defaultTracker.send(gaInfo as [NSObject:AnyObject])
    }

    func refresh() {
        self.bookmark(nil)
    }

    func bookmarked() {
        let config = Config.currentConfig()
        // Change the button to a label.
        let bookmarkedLabel = UILabel(frame:CGRectMake(0, 0, 80, 40))
        bookmarkedLabel.textAlignment = .Center
        bookmarkedLabel.font = UIFont.italicSystemFontOfSize(14.0)
        bookmarkedLabel.backgroundColor = UIColor.clearColor()
        
        if ((config.site == .Make || config.site == .MakeDev) &&
            UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
                bookmarkedLabel.textColor = UIColor.darkGrayColor()
                bookmarkedLabel.shadowColor = UIColor.whiteColor()
        }
        else {
            bookmarkedLabel.textColor = UIColor.whiteColor()
            bookmarkedLabel.shadowColor = UIColor.darkGrayColor()
        }
        
        bookmarkedLabel.shadowOffset = CGSizeMake(0.0, -1.0)
        bookmarkedLabel.text = NSLocalizedString("Saved", comment:"")
        
        let bookmarkedItem = UIBarButtonItem(customView:bookmarkedLabel)
        self.delegate!.navigationItem.rightBarButtonItem = bookmarkedItem
    }

    func presentViewController(viewController:UIViewController, animated:Bool, completion: (() -> Void)?) {
        delegate!.presentViewController(viewController, animated:animated, completion:nil)
        poc?.dismissPopoverAnimated(true)
    }

}
