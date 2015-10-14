//
//  iFixitAppDelegate.swift
//  iFixit
//
//  Created by David Patierno on 8/6/10.
//  Copyright iFixit 2010. All rights reserved.
//

import UIKit
import Foundation

//#import <Crashlytics/Crashlytics.h>

extension String {
    func rangeFromNSRange(nsRange : NSRange) -> Range<String.Index>? {
        let from16 = utf16.startIndex.advancedBy(nsRange.location, limit: utf16.endIndex)
        let to16 = from16.advancedBy(nsRange.length, limit: utf16.endIndex)
        if let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self) {
                return from ..< to
        }
        return nil
    }
}

@UIApplicationMain
class iFixitAppDelegate: UIResponder, UIApplicationDelegate, LoginViewControllerDelegate {
    
    var window: UIWindow?
    var splitViewController: MGSplitViewController?
    var categoriesViewController: CategoriesViewController?
//    var detailViewController: DetailViewController?
    
    var api: iFixitAPI?
    var firstLoad = true
    var showsTabBar = false

    static let kGANDispatchPeriodSec = 10
    
    
    // MARK: - Application lifecycle
    
    func setupAnalytics() {
        
        if Config.currentConfig().dozuki {
            return
        }

        GAI.sharedInstance().trackUncaughtExceptions = true
        GAI.sharedInstance().dispatchInterval = 10 //kGANDispatchPeriodSec
    
        GAI.sharedInstance().trackerWithTrackingId("UA-30506-9")
        GAI.sharedInstance().logger.logLevel = .Error
    }
    
    // Override point for customization after app launch.
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let config = Config.currentConfig()
        
        /* Configure. */
        config.dozuki = false
        config.site = ConfigIFixit
        
        /* Track. */
#if !DEBUG
        self.setupAnalytics()
#endif
        
        /* iOS appearance */
        self.configureAppearance()
        
        /* Setup and launch. */
        self.window?.rootViewController = nil
        firstLoad = true
        
        /* iFixit is easy. */
        if config.site == ConfigIFixit {
            self.showiFixitSplash()
        } else if config.dozuki == false {
            self.showSiteSplash()
        } else {
            
            /* Dozuki gets a little more complicated. */
            let site = NSUserDefaults.standardUserDefaults().dictionaryForKey("site")
            
            if site != nil {
                self.loadSite(site!)
            } else {
                self.showDozukiSplash()
            }
            
            firstLoad = false
        }
        
        
//    [Crashlytics startWithAPIKey:"25b29ddac9745140e41d9a00281ea38965b44f4c"];
        
        return true
    }
    
    func configureAppearance() {
        let config = Config.currentConfig()
        
        UITabBar.appearance().backgroundImage = UIImage(named: "customTabBarBackground.png")
        
        UINavigationBar.appearance().barTintColor = config.toolbarColor
        UINavigationBar.appearance().titleTextAttributes = [ NSForegroundColorAttributeName: config.textColor ]
        UINavigationBar.appearance().tintColor = config.buttonColor

        UISearchBar.appearance().tintColor = UIColor.grayColor()
        
        UITabBar.appearance().tintColor = config.tabBarColor
    }
    
    func showDozukiSplash() {
        
        // Make sure we're not pointing at a site requiring setup.
        Config.currentConfig().site = ConfigIFixit
        
        // Reset the saved choice.
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setValue(nil, forKey: "site")
        defaults.synchronize()
        
        // Dozuki splash
        let dsvc = DozukiSplashViewController()
        dsvc.modalTransitionStyle = .CrossDissolve
        window!.rootViewController = dsvc
        
        window!.makeKeyAndVisible()

        if !firstLoad {
            dsvc.getStarted(nil)
        }
    }
    
    func showiFixitSplash() {
        // Hide the status bar
        UIApplication.sharedApplication().statusBarHidden = true
        
        let svc = iFixitSplashScreenViewController(nibName: "iFixitSplashScreenViewController", bundle: nil)
        
        window!.rootViewController = svc
        
        UIView.transitionWithView(window!.rootViewController!.view, duration: 0.3, options: .TransitionCrossDissolve, animations: {}, completion: nil)

        window!.makeKeyAndVisible()
    }
    
    func showSiteSplash() {
        
        GuideBookmarks.reset()
        
        if ((window!.rootViewController) != nil) {
            for subview in window!.subviews {
                subview.removeFromSuperview()
            }
        }
        
        var root:UIViewController?
        var nvc:UINavigationController?
        
        // Only refresh our UIWindow on a very special edge case
        if (UIDevice.currentDevice().userInterfaceIdiom == .Pad && Config.currentConfig().site == ConfigDozuki) {
            refreshUIWindow()
        }
        
        if (iFixitAPI.sharedInstance.user == nil && Config.currentConfig().`private`) {
            // Private sites require immediate login.
            let vc = LoginViewController()
            vc.message = NSLocalizedString("Private site. Authentication required.", comment:"")
            vc.delegate = self
            nvc = UINavigationController(rootViewController:vc)
            nvc!.modalPresentationStyle = .FormSheet
            
            // iPad: display in form sheet
            if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
                root = LoginViewController()

                self.window!.rootViewController = root
                self.window!.makeKeyAndVisible()
                vc.modal = true
                root!.presentViewController(nvc!, animated: false, completion: nil)
                return
            } else {
                // iPhone: set as root
                root = nvc
            }
        } else {
            root = UIDevice.currentDevice().userInterfaceIdiom == .Pad ?
                self.iPadRoot() : self.iPhoneRoot()
        }
        
        self.window!.rootViewController = root;
        window!.makeKeyAndVisible()
    }
    
    /*
    * NOTE: This is a dirty hack, only to be used with iOS 7 and only on iPad.
    * Short Answer : iOS 7 on iPad will "gray" out all
    * UIButtons/UINavigationButtons/UITabBarItems when selecting a nanosite.
    *
    * Long Answer : When we select a nanosite, we remove all current subviews
    * from within the context of window.rootViewController.
    * We then replace window.rootViewController with a new viewcontroller that
    * corresponds to the nanosite selected. Think of it as a "reset" button.
    *
    * This works, but iOS 7 will apply a gray tint color to all buttons when it
    * detects that a view is not the main view (for example when a modal pops up,
    * the current view becomes the background and the modal becomes the foreground).
    * Releasing the current window and creating a new window was the only way to
    * guarantee that our UIWindow is in the foreground always.
    */
    func refreshUIWindow() {
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
    }
    
    func refresh() {
        if iFixitAPI.sharedInstance.user != nil {
            self.showSiteSplash()
        }
    }
    
    func presentViewController(viewController: UIViewController!, animated: Bool, completion: (() -> Void)?) {
        window!.rootViewController?.presentViewController(viewController, animated: animated, completion: completion)
    }
    
    func iPadRoot() -> UIViewController {
        let config = Config.currentConfig()
        self.showsTabBar = config.collectionsEnabled || config.store != nil
        
        if (config.site == ConfigMagnolia) {
            UIApplication.sharedApplication().statusBarStyle = .Default
        } else {
            UIApplication.sharedApplication().statusBarStyle = .LightContent
        }
        
        // Create the split controller children.
        let rvc = CategoriesViewController(nibName:"CategoriesViewController", bundle:nil)
        self.categoriesViewController = rvc
        
        // Create the split view controller.
        self.splitViewController = MGSplitViewController()
        
        let lvc = ListViewController(rootViewController:categoriesViewController!)
        let ctvc = CategoryTabBarViewController(nibName:"CategoryTabBarViewController", bundle:nil)
        
        if (config.dozuki) {
//            iFixitAPI.sharedInstance.getSiteInfoForObject(ctvc, withSelector: "gotSiteInfoResults:")
            iFixitAPI.sharedInstance.getSiteInfo({ (results) in
                ctvc.gotSiteInfoResults(results)
            })
        }
        
// TODO        lvc.categoryTabBarViewController = ctvc
        ctvc.listViewController = lvc
        
        splitViewController!.viewControllers = [lvc, ctvc]
        splitViewController!.delegate = ctvc
        
        categoriesViewController!.delegate = self
        
        // Stop here, or put a fancy tab bar at the bottom.
        if (!self.showsTabBar) {
            return splitViewController!
        }
        
        // Initialize the tab bar items.
        var guideTitle = NSLocalizedString("Guides", comment:"")
        if (config.site == ConfigMake) {
            guideTitle = NSLocalizedString("Projects", comment:"")
        } else if (config.site == ConfigIFixit) {
            guideTitle = NSLocalizedString("Repair Manuals", comment:"")
        }
        
        if (config.site == ConfigIFixit) {
            splitViewController!.tabBarItem = UITabBarItem(title:guideTitle, image:UIImage(named:"tabBarItemWrench.png"), tag:0)
        }
        else {
            splitViewController!.tabBarItem = UITabBarItem(title:guideTitle, image:UIImage(named:"tabBarItemBook.png"), tag:0)
        }
        
        // Optionally add the store button.
        var storeViewController: SVWebViewController? = nil
        let storeTitle = NSLocalizedString("Store", comment:"")
        let storeImage = UIImage(named:"FA-Store.png")
        
        if (config.store != nil) {
            storeViewController = SVWebViewController(address:config.store, withTitle:storeTitle)
            storeViewController!.tintColor = config.toolbarColor
            storeViewController!.showsDoneButton = false
            storeViewController!.tabBarItem = UITabBarItem(title:storeTitle, image:storeImage, tag:0)
        }
        
        // Create the tab bar.
        let tbc = UITabBarController()
        
        tbc.tabBar.translucent = false
        
        if (config.collectionsEnabled) {
            let featuredViewController = FeaturedViewController()
            featuredViewController.tabBarItem = UITabBarItem(title:NSLocalizedString("Featured", comment:""), image:UIImage(named:"FA-Featured.png"), tag:0)
            tbc.viewControllers?.append(featuredViewController)
        }
        
        tbc.viewControllers?.append(splitViewController!)
        if storeViewController != nil {
            tbc.viewControllers?.append(storeViewController!)
        }
        
        return tbc;
    }
    
    func iPhoneRoot() -> UIViewController {
        let config = Config.currentConfig()
        let ctbvc = CategoryTabBarViewController(nibName:"CategoryTabBarViewController", bundle:nil)
        
        if (config.dozuki) {
            iFixitAPI.sharedInstance.getSiteInfo({ (results) in
                ctbvc.gotSiteInfoResults(results)
            })
        }
        
        if (config.site == ConfigMagnolia) {
            UIApplication.sharedApplication().statusBarStyle = .Default
        } else {
            UIApplication.sharedApplication().statusBarStyle = .LightContent
        }
        
        return ctbvc
    }
    
    func loadSiteWithDomain(domain: String) {
        self.loadSite(["domain": domain])
    }
    
    func loadSite(site:[String: AnyObject]) {
        let config = Config.currentConfig()
        let domain = site["domain"] as? String
        
        // Load the right site
        switch domain {
            
        case "www.ifixit.com"?:
            config.site = ConfigIFixit
            config.answersEnabled = true
            config.collectionsEnabled = true
            
        case "www.cminor.com"?:
            config.site = ConfigIFixitDev
            
        case "makeprojects.com"?:
            config.site = ConfigMake
            
        default:
            config.site = ConfigDozuki
            config.host = domain!
            config.custom_domain = site["custom_domain"] as! String
            config.baseURL = "http://\(domain)/Guide"
            config.title = site["title"] as! String
        }
        
        // Enable/disable Answers and/or Collections
        if (config.site != ConfigIFixit) {
            config.answersEnabled = site["answers"] as? Bool ?? false
            config.collectionsEnabled = site["collections"] as? Bool ?? false
        }
        
        config.`private` = site["private"] as? Bool ?? false
        config.sso = (site["authentication"] as! Dictionary)["sso"]
        config.store = site["store"] as! String
        
        // Save this choice for future launches, first removing any null values.
        let simpleSite = [:]
        for key in site.keys {
            let value = site[key]
            if (value is NSNull) == false {
                simpleSite.setValue(value, forKey: key)
            }
        }
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setValue(simpleSite, forKey:"site")
        defaults.synchronize()
        
        config.siteData = simpleSite as [NSObject : AnyObject]
        
        // Show the main app!
        iFixitAPI.sharedInstance.loadSession()
        self.showSiteSplash()
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
        let urlString = url.absoluteString
        
        // Pull out the site name with a regex.
        if (Config.currentConfig().dozuki) {
            do {
                let regex = try NSRegularExpression(pattern:"^dozuki://(.*?)$",
                    options:.CaseInsensitive)
                let match = regex.firstMatchInString(urlString, options:.ReportProgress, range:NSMakeRange(0, urlString.characters.count))
                
                if (match != nil) {
                    let keyRange = match!.rangeAtIndex(1)
                    let domain = urlString.substringWithRange(urlString.rangeFromNSRange(keyRange)!)
                    let site = ["domain": domain]
                    
                    let defaults = NSUserDefaults.standardUserDefaults()
                    
                    defaults.setValue(site, forKey:"site")
                    defaults.synchronize()
                    
                    loadSite(site)
                    return true
                }
            } catch {
                
            }
        }
        else {
            do {
                let regex = try NSRegularExpression(pattern:"^ifixit://guide/(.*?)$",
                    options:.CaseInsensitive)
                let match = regex.firstMatchInString(urlString, options:.ReportProgress, range:NSMakeRange(0, urlString.characters.count))
                
                if (match != nil) {
                    let keyRange = match!.rangeAtIndex(1)
                    let guideidString = urlString.substringWithRange(urlString.rangeFromNSRange(keyRange)!)
                    let iGuideid = Int(guideidString)
                    
                    let vc = GuideViewController(guideid:iGuideid!)
                    window!.rootViewController!.presentViewController(vc, animated:false, completion:nil)
                    
                    return true
                }
            } catch {
                
            }
        }
        
        return false
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        categoriesViewController?.viewWillAppear(false)
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
//        self.saveContext()
    }
    
}
