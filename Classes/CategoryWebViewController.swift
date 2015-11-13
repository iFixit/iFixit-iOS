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
    var loadingProgress : MBProgressHUD?
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
    

     func webViewDidStartLoad(webView: UIWebView ) {
        // Hide any previous loading items
        self.loadingProgress.hide()
    
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
    
        
        var frame = CGRectMake(self.view.frame.size.width/2.0 - 60, yCoord, 120.0, 120.0)
    
        self.loadingProgress = MBProgressHUD(frame:frame)
        self.loadingProgress.showInView(self.view)
    }

    func webViewDidFinishLoad(webView: UIWebView ) {
    
        UIView.transitionWithView(self.webView,
            duration:0.3, options:UIViewAnimationOptionTransitionCrossDissolve,
            animations:{
                self.loadingProgress(hide)
                if self.webViewType.isEqualToString("answers") {
                    self.injectCSSIntoWebview();
                }
            }, completion:(animation:BOOL){
                self.webView.hidden = false
            })
    }

    func injectCSSIntoWebview() {
        let  css = "\"header, #header { display: none; } #mainBody { margin-top: 20px; } \"";
        var jsString = "var styleNode = document.createElement('style');\n" +
            "styleNode.type = \"text/css\";\n" +
            "var styleText = document.createTextNode(%@);\n"+
        "styleNode.appendChild(styleText);\n"+
        "document.getElementsByTagName('head')[0].appendChild(styleNode);\n"
        
        let js = String(format:jsString,css)
        
        self.webView.stringByEvaluatingJavaScriptFromString(js)
    }

    
    func configureProperties() {
    
    // Only configure the nav bar on iPhone
        if IS_IPHONE {
            self.configureNavigationBar()
            self.view.autoresizesSubviews = true
        }
    }
    
    
    
   

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        coordinator.animateAlongsideTransition(nil, completion: {context in
            if(UIDevice.currentDevice().orientation == UIDeviceOrientation.Portrait || UIDevice.currentDevice().orientation == UIDeviceOrientation.PortraitUpsideDown){
                //this is portrait (or upsidedown), do something
            }else{
                //landscape
            }
        })
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
    
    func configureNavigationBar() {
        self.categoryNavigationBar.hidden = false
        self.categoryNavigationBar.translucent = false
    
        var backButtonItem = UINavigationItem.initWithTitle("")
        var titleItem = UINavigationItem.initWithTitle("")
        var favoritesButtonItem = self.categoryNavigationBar.items[0]
    
    // Hack to get a back button, title view, and a right bar button item on a navigation bar without having to use a navigation controller
        self.categoryNavigationBar.items = [backButtonItem, titleItem, favoritesButtonItem]
        self.categoryNavigationBar.delegate = self.categoryTabBarViewController
    }
    
    func favoritesButtonPushed(sender: AnyObject?) {
        iFixitAPI.checkCredentialsForViewController(self.listViewController)
    }
    
    
    class func configureHtmlForWebview(categoryMetaData: NSDictionary) {
        // Load our css
        var header = String(format: "<html><head><style type=\"text/css\"> %@ </style></head><body>", arguments:Config.currentConfig().moreInfoCSS)
        
        var footer = "</body></html>"
    
        // Build our image tag that will display an image of the category we are looking at
        if let image = categoryMetaData["image"] {
            image = String(format: "<img id=\"categoryImage\" src=\"%@.standard\">", arguments: categoryMetaData["image"]["original"])
        } else {
            image = ""
        }
    
    
        // Add our wiki content
        var content = String(format: "<div id=\"moreInfoContent\">%@</div>", arguments: categoryMetaData["contents_rendered"])
    
        return header+image+content+footer
    }


}