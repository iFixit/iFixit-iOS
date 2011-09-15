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
#import "DozukiSplashViewController.h"
#import "DozukiInfoViewController.h"
#import "GuideBookmarks.h"

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

+ (BOOL)isIPad {
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
}

// Override point for customization after app launch.
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    [TestFlight takeOff:@"c74d40d00ff8789a3c63bc4c2ee210e6_MTcxMjIwMTEtMDktMTIgMTc6MzY6MzcuNzIyMTQ3"];

    [[Config currentConfig] setSite:ConfigIFixit];
    
    [Config currentConfig].dozuki = YES;
    self.window.rootViewController = nil;
    firstLoad = YES;
    
    // Load a previous choice
    NSString *domain = [[NSUserDefaults standardUserDefaults] valueForKey:@"domain"];
    if (domain)
        [self loadSite:domain];

    /** IFIXIT *************************************************************************/
    [self showSiteSplash];
    
    /** DOZUKI *************************************************************************/
    if (!domain)
        [self showDozukiSplash];

    firstLoad = NO;
    
    return YES;
}

- (void)showDozukiSplash {
    // Make sure we're not pointing at a site requiring setup.
    [[Config currentConfig] setSite:ConfigIFixit];
    
    // Reset the saved choice.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:nil forKey:@"domain"];
    [defaults synchronize];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
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
    
    // Inject the splash view controller if necessary.
    if ([Config currentConfig].site != ConfigDozuki) {
        self.splashViewController = [[SplashViewController alloc] initWithNibName:@"SplashView" bundle:nil];
        [self showSplash];
    }
    
    return splitViewController;
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
- (void)showSplash {
    NSMutableArray *controllers = [splitViewController.viewControllers mutableCopy];
    [controllers replaceObjectAtIndex:1 withObject:splashViewController];
    splitViewController.viewControllers = [NSArray arrayWithArray:controllers];
}

- (void)loadSite:(NSString *)domain {
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
    }
    
    // Show the main app!
    [[iFixitAPI sharedInstance] loadSession];
    [self showSiteSplash];
}

- (void)showGuideid:(NSInteger)guideid {
    if (!guideid)
        return;

	GuideViewController *vc = [GuideViewController initWithGuideid:guideid];
    
    if ([iFixitAppDelegate isIPad])
        [splitViewController presentModalViewController:vc animated:YES];
    else
        [window.rootViewController presentModalViewController:vc animated:YES];
}

- (void)showGuide:(Guide *)guide {
    if (!guide)
        return;
    
	GuideViewController *vc = [GuideViewController initWithGuide:guide];
    
    if ([iFixitAppDelegate isIPad])
        [splitViewController presentModalViewController:vc animated:YES];
    else
        [window.rootViewController presentModalViewController:vc animated:YES];
}

- (void)hideGuide {
    if ([iFixitAppDelegate isIPad])
        [splitViewController dismissModalViewControllerAnimated:YES];
    else
        [window.rootViewController dismissModalViewControllerAnimated:YES];
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

