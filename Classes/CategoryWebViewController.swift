//
//  CategoryWebViewController.swift
//  iFixit
//
//  Created by Amy Eliason on 10/9/15.
//
//

import Foundation
import UIKit

class CategoryWebViewController: UIViewController, UIWebViewDelegate {
    
    var favoritesButton: UIBarButtonItem?
    var webView : UIWebView?
    var loading : WBProgressHUD?
    var category : String?
    var categoryNavigationBar : UINavigationBar?
    var listViewController : ListViewController?
    var categoryTabBarViewController : CategoryTabBarViewController?
    
   
    

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        
        super.init(nibName:nibNameOrNil, bundle:nibBundleOrNil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView?.delegate = self
    }
    
    override func viewWillAppear(animated:Bool) {
        // Only on iPhone do we want to have a nav bar with a title
        
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            self.categoryNavigationBar!.topItem!.title = self.category
            self.favoritesButton!.title = NSLocalizedString("Favorites" , comment: "")
        } else {
            self.resizeWebViewFrameForOrientation(UIApplication.sharedApplication().statusBarOrientation)
        }
    }

    func resizeWebViewFrameForOrientation(orientation:UIInterfaceOrientation) {
        let showsTabBar = appDelegate.showsTabBar()
    
    // TODO: Remove these ternary for reader's sanity
        if (UIDeviceOrientationIsLandscape(orientation)) {
            self.webView.frame = CGRectMake(0, 64, 703, (showsTabBar) ? 663 : 706)
        } else {
            self.webView.frame = CGRectMake(0, 64, 770, (showsTabBar) ? 919 : 963)
        }
    }
    
    func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func webViewDidStartLoad(webView: UIWebView ) {
        // Hide any previous loading items
        self.loading.hide()
    
        // Hide the webview with a transition
        UIView.transitionWithView(self.webView, duration: 0.3, options: UIViewAnimationOptionTransitionCrossDissolve, animations: {
            self.webView?.hidden = true
            }, completion: nil)
    
        var yCoord : double = 0
        // Figure out the yCoord for the loading icon
        if IS_IPAD {
            yCoord = UIDeviceOrientationIsPortrait(self.interfaceOrientation) ? 400 : 300
        } else {
            yCoord = 160
        }
    
        
        var frame :CGRect = CGRectMake(self.view.frame.size.width/2.0 - 60, yCoord, 120.0, 120.0)
    
        self.loading = WBProgressHUD.init()
        self.loading.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    
        self.loading.showInView(self.view)
    }


    
}