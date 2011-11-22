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
#import "AreasViewController.h"
#import "DetailViewController.h"
#import "FeaturedViewController.h"
#import "DozukiSplashViewController.h"
#import "DozukiInfoViewController.h"
#import "SVWebViewController.h"
#import "GuideBookmarks.h"
#import "Guide.h"
#import "UIColor+Hex.h"
#import "GANTracker.h"

static const NSInteger kGANDispatchPeriodSec = 10;

@implementation UISplitViewController (SplitViewRotate)

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

@end

@implementation iFixitAppDelegate

@synthesize window, splitViewController, areasViewController, detailViewController;
@synthesize api, firstLoad;

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
    [Config currentConfig].dozuki = YES;
    
    /* Track. */
    [TestFlight takeOff:@"c74d40d00ff8789a3c63bc4c2ee210e6_MTcxMjIwMTEtMDktMTIgMTc6MzY6MzcuNzIyMTQ3"];
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

        if (NO && site) {
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
    // Make sure we're not pointing at a site requiring setup.
    [[Config currentConfig] setSite:ConfigIFixit];
    
    // Reset the saved choice.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:nil forKey:@"site"];
    [defaults synchronize];

    if (YES || [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        // Dozuki splash
        DozukiSplashViewController *dsvc = [[DozukiSplashViewController alloc] init];
        dsvc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.window.rootViewController = dsvc;
        [dsvc release];
    }
    else {
        // Create a navigation controller and load the info view.
        DozukiInfoViewController *divc = [[DozukiInfoViewController alloc] initWithNibName:@"DozukiInfoView" bundle:nil];
        UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:divc];
        nvc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.window.rootViewController = nvc;
        if (!firstLoad)
            [divc showList];
        [nvc release];
        [divc release];
    }
    
    [window makeKeyAndVisible];
}

- (void)showSiteSplash {
    [GuideBookmarks reset];

    if (self.window.rootViewController) {
        for (UIView *subview in self.window.subviews)
            [subview removeFromSuperview];
    }
    
    UIViewController *root = 
    [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ?
        [self iPadRoot] : [self iPhoneRoot];
 
    self.window.rootViewController = root;
    [window makeKeyAndVisible];
    
    /*
    root.view.alpha = 0.0;
    [self.window addSubview:root.view];
    
    [UIView animateWithDuration:0.5 animations:^{
        root.view.alpha = 1.0;
    } completion:^(BOOL finished) {
        self.window.rootViewController = root;
        [window makeKeyAndVisible];
    }];    
    */
}

- (UIViewController *)iPadRoot {
    // Create the split controller children.
    AreasViewController *rvc = [[AreasViewController alloc] init];
    self.areasViewController = rvc;
    [rvc release];
    DetailViewController *dvc = [[DetailViewController alloc] init];
    self.detailViewController = dvc;
    [dvc release];
    
    // Create the split view controller.
    UISplitViewController *svc = [[UISplitViewController alloc] init];
    svc.delegate = detailViewController;
    self.splitViewController = svc;
    [svc release];
    
    areasViewController.detailViewController = detailViewController;
    
    ListViewController *lvc = [[ListViewController alloc] initWithRootViewController:areasViewController];
    splitViewController.viewControllers = [NSArray arrayWithObjects:lvc, detailViewController, nil];
    [lvc release];
    
    areasViewController.delegate = self;
    
    // Dozuki ends here, but iFixit gets a fancy tab bar at the bottom.
    if (![Config currentConfig].collectionsEnabled)
        return splitViewController;
    
    // Create some more view controllers.
    FeaturedViewController *featuredViewController = [[FeaturedViewController alloc] init];
    //SVWebViewController *answersViewController = [[SVWebViewController alloc] initWithAddress:@"http://www.ifixit.com/Answers"];
    //answersViewController.tintColor = [Config currentConfig].toolbarColor;
    //answersViewController.showsDoneButton = NO;
    SVWebViewController *storeViewController = [[SVWebViewController alloc] initWithAddress:@"http://www.ifixit.com/Parts-Store"];
    storeViewController.tintColor = [Config currentConfig].toolbarColor;
    storeViewController.showsDoneButton = NO;
    
    // Initialize the tab bar items.
    NSString *guideTitle = @"Guides";
    if ([Config currentConfig].site == ConfigMake)
        guideTitle = @"Projects";
    else if ([Config currentConfig].site == ConfigIFixit)
        guideTitle = @"Repair Manuals";
    
    NSString *storeTitle = @"Store";
    if ([Config currentConfig].site == ConfigIFixit) {
        storeTitle = @"Parts & Tools";
        splitViewController.tabBarItem = [[[UITabBarItem alloc] initWithTitle:guideTitle image:[UIImage imageNamed:@"tabBarItemWrench.png"] tag:0] autorelease];
    }
    else {
        splitViewController.tabBarItem = [[[UITabBarItem alloc] initWithTitle:guideTitle image:[UIImage imageNamed:@"tabBarItemBooks.png"] tag:0] autorelease];
    }
    
    splitViewController.tabBarItem = [[[UITabBarItem alloc] initWithTitle:guideTitle image:[UIImage imageNamed:@"tabBarItemWrench.png"] tag:0] autorelease];
    featuredViewController.tabBarItem = [[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFeatured tag:0] autorelease];
    //answersViewController.tabBarItem = [[[UITabBarItem alloc] initWithTitle:@"Answers" image:[UIImage imageNamed:@"tabBarItemBubbles.png"] tag:0] autorelease];
    storeViewController.tabBarItem = [[[UITabBarItem alloc] initWithTitle:storeTitle image:[UIImage imageNamed:@"tabBarItemGears.png"] tag:0] autorelease];

    // Create the tab bar.
    UITabBarController *tbc = [[UITabBarController alloc] init];
    tbc.viewControllers = [NSArray arrayWithObjects:featuredViewController, splitViewController, storeViewController, nil];
    [featuredViewController release];
    //[answersViewController release];
    [storeViewController release];
    
    return [tbc autorelease];
}

- (UIViewController *)iPhoneRoot {
    AreasViewController *avc = [[AreasViewController alloc] init];
    self.areasViewController = avc;
    [avc release];
    
    ListViewController *lvc = [[ListViewController alloc] initWithRootViewController:areasViewController];

    lvc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    return [lvc autorelease];
}

- (void)loadSiteWithDomain:(NSString *)domain {
    NSDictionary *site = [NSDictionary dictionaryWithObject:domain forKey:@"domain"];
    [self loadSite:site];
}

- (void)loadSite:(NSDictionary *)site {
    NSString *domain = [site valueForKey:@"domain"];
    NSString *colorHex = [site valueForKey:@"color"];
    UIColor *color = [UIColor colorFromHexString:colorHex];
    
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
        [Config currentConfig].baseURL = [NSString stringWithFormat:@"http://%@/Guide", domain];
        
        if (color)
            [Config currentConfig].toolbarColor = color;
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
    
    // Save this choice for future launches, first removing any null values.
    NSMutableDictionary *simpleSite = [NSMutableDictionary dictionary];
    for (NSString *key in [site allKeys]) {
        NSObject *value = [site objectForKey:key];
        if (![value isEqual:[NSNull null]])
            [simpleSite setValue:value forKey:key];
    }
    [[NSUserDefaults standardUserDefaults] setValue:simpleSite forKey:@"site"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Show the main app!
    [[iFixitAPI sharedInstance] loadSession];
    [self showSiteSplash];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    
    NSString *urlString = [url absoluteString];

    // Pull out the site name with a regex.
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
    [areasViewController viewWillAppear:NO];
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

