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
    
}