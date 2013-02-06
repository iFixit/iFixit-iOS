//
//  iFixitAppDelegate.m
//  iFixit
//
//  Created by David Patierno on 8/6/10.
//  Copyright iFixit 2010. All rights reserved.
//

#import "iFixitAppDelegate.h"
#import "Config.h"

#import "ListViewController.h"
#import "CategoriesViewController.h"
#import "DetailViewController.h"
#import "FeaturedViewController.h"
#import "GuideViewController.h"
#import "DozukiSplashViewController.h"
#import "DozukiInfoViewController.h"
#import "SVWebViewController.h"
#import "GuideBookmarks.h"
#import "Guide.h"
#import "LoginViewController.h"
#import "LoginBackgroundViewController.h"
#import "UIColor+Hex.h"
#import "GANTracker.h"

static const NSInteger kGANDispatchPeriodSec = 10;

@implementation UISplitViewController (SplitViewRotate)

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

@end

@implementation UITabBarController (Rotate)

// Hack fix for wonky landscape/portrait orientation on iOS 4.x iPads after Dozuki site select.
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // Only apply this hack to iPads...
    if ([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad)
        return;

    // ...running iOS <5.0
    NSString* version = [[UIDevice currentDevice] systemVersion];
    if ([version compare:@"5.0" options:NSNumericSearch] != NSOrderedAscending)
        return;

    // If we're in landscape, force portrait!
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
    }
}

@end

@implementation iFixitAppDelegate

@synthesize window, splitViewController, categoriesViewController, detailViewController;
@synthesize api, firstLoad, showsTabBar;

#pragma mark -
#pragma mark Application lifecycle

- (void)setupAnalytics {
    if ([Config currentConfig].dozuki)
        return;
    
    [[GANTracker sharedTracker] startTrackerWithAccountID:@"UA-30506-9"
                                           dispatchPeriod:kGANDispatchPeriodSec
                                                 delegate:nil];
    
    [[GANTracker sharedTracker] setCustomVariableAtIndex:1
                                                    name:@"model"
                                                   value:[UIDevice currentDevice].model
                                               withError:NULL];
    [[GANTracker sharedTracker] setCustomVariableAtIndex:2
                                                    name:@"systemVersion"
                                                   value:[UIDevice currentDevice].systemVersion
                                               withError:NULL];
    
    [[GANTracker sharedTracker] trackPageview:[NSString stringWithFormat:@"/launch/%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]] withError:NULL];
}

// Override point for customization after app launch.
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    /* Configure. */
    [Config currentConfig].dozuki = NO;

    /* Track. */
    [TestFlight takeOff:@"6b356258f037dc15f6d69d0e5d27fdf7_MzAyOTUyMDEyLTAyLTEyIDE1OjQ2OjUwLjA0NTg5OQ"];
    [self setupAnalytics];
    
    /* iOS 5 appearance */
    if ([UITabBar respondsToSelector:@selector(appearance)])
        [[UITabBar appearance] setBackgroundImage:[UIImage imageNamed:@"customTabBarBackground.png"]];
    
    /* Setup and launch. */
    self.window.rootViewController = nil;
    firstLoad = YES;

    /* iFixit is easy. */
    if (![Config currentConfig].dozuki) {
        [self showSiteSplash];
    }
    /* Dozuki gets a little more complicated. */
    else {
        NSDictionary *site = [[NSUserDefaults standardUserDefaults] objectForKey:@"site"];

        if (site) {
            [self loadSite:site];
            [self showSiteSplash];
        }
        else {
            [self showDozukiSplash];
        }
        
        firstLoad = NO;
    }
    
    return YES;
}

- (void)showDozukiSplash {
    [detailViewController.popoverController dismissPopoverAnimated:NO];
    
    // Make sure we're not pointing at a site requiring setup.
    [[Config currentConfig] setSite:ConfigIFixit];
    
    // Reset the saved choice.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:nil forKey:@"site"];
    [defaults synchronize];
    
    // Dozuki splash
    DozukiSplashViewController *dsvc = [[DozukiSplashViewController alloc] init];
    dsvc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    self.window.rootViewController = dsvc;
    [dsvc release];

    [window makeKeyAndVisible];
    if (!firstLoad) {
        [dsvc getStarted:nil];
    }
}

- (void)showSiteSplash {
    [GuideBookmarks reset];

    if (self.window.rootViewController) {
        for (UIView *subview in self.window.subviews)
            [subview removeFromSuperview];
    }
    
    UIViewController *root = nil;
    UINavigationController *nvc = nil;

    if (![iFixitAPI sharedInstance].user && [Config currentConfig].private) {
        // Private sites require immediate login.
        LoginViewController *vc = [[LoginViewController alloc] init];
        vc.message = @"Private site. Authentication required.";
        vc.delegate = self;
        nvc = [[[UINavigationController alloc] initWithRootViewController:vc] autorelease];        
        nvc.modalPresentationStyle = UIModalPresentationFormSheet;
        nvc.navigationBar.tintColor = [Config currentConfig].toolbarColor;
        [vc release];

        UIImage *icon = [UIImage imageNamed:@"backtosites.png"];
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:icon style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(showDozukiSplash)];
        vc.navigationItem.leftBarButtonItem = button;
        [button release];

        // iPad: display in form sheet
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            root = [[[LoginBackgroundViewController alloc] init] autorelease];
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
    [window makeKeyAndVisible];
}

- (void)refresh {
    if ([iFixitAPI sharedInstance].user) {
        [self showSiteSplash];
    }
}

- (void)presentModalViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self.window.rootViewController presentModalViewController:viewController animated:animated];    
}

- (UIViewController *)iPadRoot {
    self.showsTabBar = [Config currentConfig].collectionsEnabled || [Config currentConfig].store;
    
    // Create the split controller children.
    CategoriesViewController *rvc = [[CategoriesViewController alloc] init];
    self.categoriesViewController = rvc;
    [rvc release];
    DetailViewController *dvc = [[DetailViewController alloc] init];
    self.detailViewController = dvc;
    [dvc release];
    
    // Create the split view controller.
    UISplitViewController *svc = [[UISplitViewController alloc] init];
    svc.delegate = detailViewController;
    self.splitViewController = svc;
    [svc release];
    
    categoriesViewController.detailViewController = detailViewController;
    
    ListViewController *lvc = [[ListViewController alloc] initWithRootViewController:categoriesViewController];
    splitViewController.viewControllers = [NSArray arrayWithObjects:lvc, detailViewController, nil];
    [lvc release];
    
    categoriesViewController.delegate = self;
    
    // Stop here, or put a fancy tab bar at the bottom.
    if (!self.showsTabBar)
        return splitViewController;
    
    // Initialize the tab bar items.
    NSString *guideTitle = @"Guides";
    if ([Config currentConfig].site == ConfigMake)
        guideTitle = @"Projects";
    else if ([Config currentConfig].site == ConfigIFixit)
        guideTitle = @"Repair Manuals";
    
    if ([Config currentConfig].site == ConfigIFixit) {
        splitViewController.tabBarItem = [[[UITabBarItem alloc] initWithTitle:guideTitle image:[UIImage imageNamed:@"tabBarItemWrench.png"] tag:0] autorelease];
    }
    else {
        splitViewController.tabBarItem = [[[UITabBarItem alloc] initWithTitle:guideTitle image:[UIImage imageNamed:@"tabBarItemBook.png"] tag:0] autorelease];
    }
    
    // Optionally add the store button.
    SVWebViewController *storeViewController = nil;
    NSString *storeTitle = @"Store";
    UIImage *storeImage = [UIImage imageNamed:@"tabBarItemPricetag.png"];

    if ([Config currentConfig].store) {
        if ([Config currentConfig].site == ConfigIFixit) {
            storeTitle = @"Parts & Tools";
            storeImage = [UIImage imageNamed:@"tabBarItemGears.png"];
        }
        storeViewController = [[SVWebViewController alloc] initWithAddress:[Config currentConfig].store];
        storeViewController.tintColor = [Config currentConfig].toolbarColor;
        storeViewController.showsDoneButton = NO;        
        storeViewController.tabBarItem = [[[UITabBarItem alloc] initWithTitle:storeTitle image:storeImage tag:0] autorelease];
    }

    // Create the tab bar.
    UITabBarController *tbc = [[UITabBarController alloc] init];
    
    if ([Config currentConfig].collectionsEnabled) {
        FeaturedViewController *featuredViewController = [[FeaturedViewController alloc] init];    
        featuredViewController.tabBarItem = [[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFeatured tag:0] autorelease];
        tbc.viewControllers = [NSArray arrayWithObjects:featuredViewController, splitViewController, storeViewController, nil];
        [featuredViewController release];
    }
    else {
        tbc.viewControllers = [NSArray arrayWithObjects:splitViewController, storeViewController, nil];
    }

    [storeViewController release];
    
    return [tbc autorelease];
}

- (UIViewController *)iPhoneRoot {
    CategoriesViewController *cvc = [[CategoriesViewController alloc] init];
    self.categoriesViewController = cvc;
    [cvc release];
    
    ListViewController *lvc = [[ListViewController alloc] initWithRootViewController:categoriesViewController];

    lvc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    return [lvc autorelease];
}

- (void)loadSiteWithDomain:(NSString *)domain {
    NSDictionary *site = [NSDictionary dictionaryWithObject:domain forKey:@"domain"];
    [self loadSite:site];
}

- (void)loadSite:(NSDictionary *)site {
    NSString *domain = [site valueForKey:@"domain"];
    //NSString *colorHex = [site valueForKey:@"color"];
    //UIColor *color = [UIColor colorFromHexString:colorHex];
    
    // Load the right site
    if ([domain isEqual:@"www.ifixit.com"]) {
        [[Config currentConfig] setSite:ConfigIFixit];
    }
    else if ([domain isEqual:@"www.cominor.com"]) {
        [[Config currentConfig] setSite:ConfigIFixitDev];
    }
    else if ([domain isEqual:@"makeprojects.com"]) {
        [[Config currentConfig] setSite:ConfigMake];
    }
    else {
        [[Config currentConfig] setSite:ConfigDozuki];
        [Config currentConfig].host = domain;
        [Config currentConfig].custom_domain = [site valueForKey:@"custom_domain"];
        [Config currentConfig].baseURL = [NSString stringWithFormat:@"http://%@/Guide", domain];
        
        //if (color)
        //    [Config currentConfig].toolbarColor = color;
    }
    
    // Enable/disable Answers and/or Collections
    if ([Config currentConfig].site == ConfigIFixit) {
        [Config currentConfig].answersEnabled = YES;
        [Config currentConfig].collectionsEnabled = YES;
    }
    else {
        [Config currentConfig].answersEnabled = [[site valueForKey:@"answers"] boolValue];
        [Config currentConfig].collectionsEnabled = [[site valueForKey:@"collections"] boolValue];
    }

    [Config currentConfig].private = [[site valueForKey:@"private"] boolValue];
    [Config currentConfig].sso = [[site valueForKey:@"authentication"] valueForKey:@"sso"];
    [Config currentConfig].store = [site valueForKey:@"store"];
    
    // Save this choice for future launches, first removing any null values.
    NSMutableDictionary *simpleSite = [NSMutableDictionary dictionary];
    for (NSString *key in [site allKeys]) {
        NSObject *value = [site objectForKey:key];
        if (![value isEqual:[NSNull null]])
            [simpleSite setValue:value forKey:key];
    }
    [[NSUserDefaults standardUserDefaults] setValue:simpleSite forKey:@"site"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [Config currentConfig].siteData = simpleSite;
    
    // Show the main app!
    [[iFixitAPI sharedInstance] loadSession];
    [self showSiteSplash];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    
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
            NSNumber *guideid = [f numberFromString:guideidString];
            [f release];
            
            GuideViewController *vc = [[GuideViewController alloc] initWithGuideid:[guideid intValue]];
            [self.window.rootViewController presentModalViewController:vc animated:NO];
            [vc release];
            
            return YES;
        }
    }
	
	return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive.
     */
    [categoriesViewController viewWillAppear:NO];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [splitViewController release];
    [window release];
    [super dealloc];
}


@end

