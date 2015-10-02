//
//  iFixitAppDelegate.swift
//  iFixit
//
//  Created by David Patierno on 8/6/10.
//  Copyright iFixit 2010. All rights reserved.
//

import UIKit

class iFixitAppDelegate: UIResponder, UIApplicationDelegate, LoginViewControllerDelegate {
    
    var window: UIWindow?
    var splitViewController: MGSplitViewController?
    var categoriesViewController: CategoriesViewController?
//    var detailViewController: DetailViewController?
    
    var api: iFixitAPI?
    var firstLoad = true
    var showsTabBar = false

    //#import <Crashlytics/Crashlytics.h>
    
    static let kGANDispatchPeriodSec = 10
    
//    
//    @implementation UITabBarController (Rotate)
//    
//    // Hack fix for wonky landscape/portrait orientation on iOS 4.x iPads after Dozuki site select.
//    - (void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//    
//    // Only apply this hack to iPads...
//    if ([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad)
//    return;
//    
//    // ...running iOS <5.0
//    NSString* version = [[UIDevice currentDevice] systemVersion];
//    if ([version compare:@"5.0" options:NSNumericSearch] != NSOrderedAscending)
//    return;
//    
//    // If we're in landscape, force portrait!
//    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
//    if (UIInterfaceOrientationIsLandscape(orientation)) {
//    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
//    }
//    }
//    
//    @end
    
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
        
        /* Configure. */
        Config.currentConfig().dozuki = false
        Config.currentConfig().site = ConfigIFixit
        
        /* Track. */
        self.setupAnalytics()
        
        /* iOS appearance */
        self.configureAppearance()
        
        /* Setup and launch. */
        self.window?.rootViewController = nil
        firstLoad = true
        
        /* iFixit is easy. */
        if Config.currentConfig().site == ConfigIFixit {
            self.showiFixitSplash()
        } else if Config.currentConfig().dozuki == false {
            self.showSiteSplash()
        } else {
            
            /* Dozuki gets a little more complicated. */
            let site = NSUserDefaults.standardUserDefaults().dictionaryForKey("site")
            
            if site {
                self.loadSite(site)
            } else {
                self.showDozukiSplash()
            }
            
            firstLoad = false
        }
        
        
        //    [Crashlytics startWithAPIKey:@"25b29ddac9745140e41d9a00281ea38965b44f4c"];
        
        return true
    }
    
    func configureAppearance() {
        
        UITabBar.appearance().backgroundImage = UIImage(named: "customTabBarBackground.png")
        
        UINavigationBar.appearance().barTintColor = Config.currentConfig().toolbarColor
        UINavigationBar.appearance().titleTextAttributes = [ NSForegroundColorAttributeName: Config.currentConfig().textColor ]
        UINavigationBar.appearance().tintColor = Config.currentConfig().buttonColor

        UISearchBar.appearance().tintColor = UIColor.grayColor()
        
        UITabBar.appearance().tintColor = Config.currentConfig().tabBarColor
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
        
        let root:UIViewController?
        let nvc:UINavigationController?
        
        // Only refresh our UIWindow on a very special edge case
        if ([UIDevice currentDevice].userInterfaceIdiom ==
            UIUserInterfaceIdiomPad && [Config currentConfig].site == ConfigDozuki) {
                [self refreshUIWindow];
        }
        
        if (![iFixitAPI sharedInstance].user && [Config currentConfig].private) {
            // Private sites require immediate login.
            LoginViewController *vc = [[LoginViewController alloc] init];
            vc.message = NSLocalizedString(@"Private site. Authentication required.", nil);
            vc.delegate = self;
            nvc = [[UINavigationController alloc] initWithRootViewController:vc];
            nvc.modalPresentationStyle = UIModalPresentationFormSheet;
            
            // iPad: display in form sheet
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                root = [[LoginBackgroundViewController alloc] init];
                self.window.rootViewController = root;
                [window makeKeyAndVisible];
                vc.modal = YES;
                [root presentModalViewController:nvc animated:NO];
                return;
            }
            else {
                // iPhone: set as root
                root = nvc;
            }
        }
        else {
            root = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ?
                [self iPadRoot] : [self iPhoneRoot];
        }
        
        self.window.rootViewController = root;
        [self.window makeKeyAndVisible];
    }
    
    /**
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
        if iFixitAPI.sharedInstance().user != nil {
            self.showSiteSplash()
        }
    }
    
    func presentModalViewController(viewController: UIViewController!, animated: Bool) {
        window!.rootViewController?.presentViewController(viewController, animated: animated, completion: nil)
    }
    
    func iPadRoot() -> UIViewController {
        let config = Config.currentConfig()
    self.showsTabBar = config.collectionsEnabled || config.store
    
    if (config.site == ConfigMagnolia) {
        UIApplication.sharedApplication().statusBarStyle = .Default
    } else {
        UIApplication.sharedApplication().statusBarStyle = .LightContent
    }
    
    // Create the split controller children.
    CategoriesViewController *rvc = [[CategoriesViewController alloc] initWithNibName:@"CategoriesViewController" bundle:nil]
    self.categoriesViewController = rvc
    
    // Create the split view controller.
    MGSplitViewController *svc = [[MGSplitViewController alloc] init]
    
    self.splitViewController = svc
    
    ListViewController *lvc = [[ListViewController alloc] initWithRootViewController:categoriesViewController];
    CategoryTabBarViewController *ctvc = [[CategoryTabBarViewController alloc] initWithNibName:@"CategoryTabBarViewController" bundle:nil]
    
    if (config.dozuki) {
    [[iFixitAPI sharedInstance] getSiteInfoForObject:ctvc withSelector:@selector(gotSiteInfoResults:)]
    }
    
    lvc.categoryTabBarViewController = ctvc
    ctvc.listViewController = lvc
    
    splitViewController.viewControllers = [lvc, ctvc]
    splitViewController.delegate = ctvc
    
    categoriesViewController.delegate = self
    
    // Stop here, or put a fancy tab bar at the bottom.
        if (!self.showsTabBar) {
    return splitViewController
        }
    
    // Initialize the tab bar items.
    var guideTitle = NSLocalizedString(@"Guides", nil);
    if ([Config currentConfig].site == ConfigMake)
    guideTitle = NSLocalizedString(@"Projects", nil);
    else if (config.site == ConfigIFixit)
    guideTitle = NSLocalizedString(@"Repair Manuals", nil);
    
    if (config.site == ConfigIFixit) {
    splitViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:guideTitle image:[UIImage imageNamed:@"tabBarItemWrench.png"] tag:0];
    }
    else {
    splitViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:guideTitle image:[UIImage imageNamed:@"tabBarItemBook.png"] tag:0];
    }
    
    // Optionally add the store button.
    SVWebViewController *storeViewController = nil;
    NSString *storeTitle = NSLocalizedString(@"Store", nil);
    UIImage *storeImage = [UIImage imageNamed:@"FA-Store.png"];
    
    if (config.store) {
    storeViewController = [[SVWebViewController alloc] initWithAddress:[Config currentConfig].store withTitle:storeTitle];
    storeViewController.tintColor = config.toolbarColor;
    storeViewController.showsDoneButton = NO;
    storeViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:storeTitle image:storeImage tag:0];
    }
    
    // Create the tab bar.
    let tbc = UITabBarController()
    
    tbc.tabBar.translucent = false
    
    if (config.collectionsEnabled) {
    FeaturedViewController *featuredViewController = [[FeaturedViewController alloc] init];
    featuredViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Featured", nil) image:[UIImage imageNamed:@"FA-Featured.png"] tag:0];
    tbc.viewControllers = [NSArray arrayWithObjects:featuredViewController, splitViewController, storeViewController, nil];
    }
    else {
    tbc.viewControllers = [NSArray arrayWithObjects:splitViewController, storeViewController, nil];
    }
    
    return tbc;
    }
    
    func iPhoneRoot() -> UIViewController {
        CategoryTabBarViewController *ctbvc = [[CategoryTabBarViewController alloc] initWithNibName:@"CategoryTabBarViewController" bundle:nil];
        
        if ([Config currentConfig].dozuki) {
        [[iFixitAPI sharedInstance] getSiteInfoForObject:ctbvc withSelector:@selector(gotSiteInfoResults:)];
        }
        
        if ([Config currentConfig].site == ConfigMagnolia) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackTranslucent;
        } else {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        }
        
        return ctbvc;
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
            config.answersEnabled = [[site valueForKey:@"answers"] boolValue];
            config.collectionsEnabled = [[site valueForKey:@"collections"] boolValue];
        }
        
        config.private = [[site valueForKey:@"private"] boolValue];
        config.sso = [[site valueForKey:@"authentication"] valueForKey:@"sso"];
        config.store = [site valueForKey:@"store"];
        
        // Save this choice for future launches, first removing any null values.
        var simpleSite = []
        for (NSString *key in [site allKeys]) {
            NSObject *value = [site objectForKey:key];
            if (![value isEqual:[NSNull null]])
            [simpleSite setValue:value forKey:key];
        }
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setValue(simpleSite, forKey:"site")
        defaults.synchronize()
        
        config.siteData = simpleSite
        
        // Show the main app!
        iFixitAPI.sharedInstance().loadSession()
        self.showSiteSplash()
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
        NSString *urlString = [url absoluteString];
        
        // Pull out the site name with a regex.
        if ([Config currentConfig].dozuki) {
            if (urlString) {
                NSError *error = nil;
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^dozuki://(.*?)$"
                options:NSRegularExpressionCaseInsensitive error:&error];
                NSTextCheckingResult *match = [regex firstMatchInString:urlString options:0 range:NSMakeRange(0, [urlString length])];
                
                if (match) {
                    NSRange keyRange = [match rangeAtIndex:1];
                    NSString *domain = [urlString substringWithRange:keyRange];
                    NSDictionary *site = [NSDictionary dictionaryWithObject:domain forKey:@"domain"];
                    
                    [[NSUserDefaults standardUserDefaults] setValue:site forKey:@"site"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    [self loadSite:site];
                    return YES;
                }
            }
        }
        else {
            NSError *error = nil;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^ifixit://guide/(.*?)$"
            options:NSRegularExpressionCaseInsensitive error:&error];
            NSTextCheckingResult *match = [regex firstMatchInString:urlString options:0 range:NSMakeRange(0, [urlString length])];
            
            if (match) {
                NSRange keyRange = [match rangeAtIndex:1];
                NSString *guideidString = [urlString substringWithRange:keyRange];
                NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
                [f setNumberStyle:NSNumberFormatterDecimalStyle];
                NSNumber *iGuideid = [f numberFromString:guideidString];
                
                GuideViewController *vc = [[GuideViewController alloc] initWithGuideid:iGuideid];
                [self.window.rootViewController presentModalViewController:vc animated:NO];
                
                return YES;
            }
        }
        
        return NO;
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
