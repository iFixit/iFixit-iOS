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
#import "SplashViewController.h"
#import "FeaturedViewController.h"
#import "DozukiSplashViewController.h"
#import "DozukiInfoViewController.h"
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

@synthesize window, splitViewController, areasViewController, detailViewController, splashViewController;
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
    [Config currentConfig].dozuki = NO;
    
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
        NSString *domain = [[NSUserDefaults standardUserDefaults] valueForKey:@"domain"];
        if (domain) {
            NSString *colorHex = [[NSUserDefaults standardUserDefaults] objectForKey:@"color"];
            UIColor *color = [UIColor colorFromHexString:colorHex];
            [self loadSite:domain withColor:color];
        }
        
        [self showSiteSplash];
        
        if (!domain)
            [self showDozukiSplash];
        
        firstLoad = NO;
    }
    
    return YES;
}

- (void)showDozukiSplash {
    // Make sure we're not pointing at a site requiring setup.
    [[Config currentConfig] setSite:ConfigIFixit];
    
    // Reset the saved choice.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:nil forKey:@"domain"];
    [defaults synchronize];

    if (YES || [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        // Dozuki splash
        DozukiSplashViewController *dsvc = [[DozukiSplashViewController alloc] initWithNibName:@"DozukiSplashView" bundle:nil];
        dsvc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self.window.rootViewController presentModalViewController:dsvc animated:!firstLoad];
        [dsvc release];
    }
    else {
        // Create a navigation controller and load the info view.
        DozukiInfoViewController *divc = [[DozukiInfoViewController alloc] initWithNibName:@"DozukiInfoView" bundle:nil];
        UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:divc];
        nvc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self.window.rootViewController presentModalViewController:nvc animated:!firstLoad];
        if (!firstLoad)
            [divc showList];
        [nvc release];
        [divc release];
    }
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
    // Create the split view controller.
    UISplitViewController *svc = [[UISplitViewController alloc] init];
    svc.delegate = detailViewController;
    self.splitViewController = svc;
    [svc release];
    
    // Create its two children.
    AreasViewController *rvc = [[AreasViewController alloc] initWithNibName:@"AreasView" bundle:nil];
    self.areasViewController = rvc;
    [rvc release];
    DetailViewController *dvc = [[DetailViewController alloc] initWithNibName:@"DetailView" bundle:nil];
    self.detailViewController = dvc;
    [dvc release];
    
    areasViewController.detailViewController = detailViewController;
    
    ListViewController *lvc = [[ListViewController alloc] initWithRootViewController:areasViewController];
    splitViewController.viewControllers = [NSArray arrayWithObjects:lvc, detailViewController, nil];
    
    areasViewController.delegate = self;
    
    // Dozuki ends here, but iFixit gets a fancy tab bar at the bottom.
    if ([Config currentConfig].dozuki)
        return splitViewController;
    
    // Create the featured view controller
    FeaturedViewController *featuredViewController = [[FeaturedViewController alloc] init];
    
    // Initialize the tab bar items.
    splitViewController.tabBarItem = [[[UITabBarItem alloc] initWithTitle:@"Repair" image:nil tag:0] autorelease];
    featuredViewController.tabBarItem = [[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFeatured tag:0] autorelease];
    
    // Create the tab bar.
    UITabBarController *tbc = [[UITabBarController alloc] init];
    tbc.viewControllers = [NSArray arrayWithObjects:featuredViewController, splitViewController, nil];
    [featuredViewController release];
    
    return [tbc autorelease];
}

- (UIViewController *)iPhoneRoot {
    AreasViewController *rvc = [[AreasViewController alloc] initWithNibName:@"AreasView" bundle:nil];
    self.areasViewController = rvc;
    [rvc release];
    
    ListViewController *lvc = [[ListViewController alloc] initWithRootViewController:areasViewController];
    
    lvc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    return [lvc autorelease];
}

- (void)showBrowser {
    NSMutableArray *controllers = [splitViewController.viewControllers mutableCopy];
    [controllers replaceObjectAtIndex:1 withObject:detailViewController];
    splitViewController.viewControllers = [NSArray arrayWithArray:controllers];
}

- (void)loadSite:(NSString *)domain {
    [self loadSite:domain withColor:nil];
}

- (void)loadSite:(NSString *)domain withColor:(UIColor *)color {
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
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setValue:domain forKey:@"domain"];
            [defaults setValue:nil forKey:@"color"];
            [defaults synchronize];
            
            [self loadSite:domain];
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
    [splashViewController viewWillAppear:NO];
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

