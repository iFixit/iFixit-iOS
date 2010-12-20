//
//  iFixitAppDelegate.m
//  iFixit
//
//  Created by David Patierno on 8/6/10.
//  Copyright iFixit 2010. All rights reserved.
//

#import "iFixitAppDelegate.h"


#import "RootViewController.h"
#import "DetailViewController.h"
#import "SplashViewController.h"

@implementation iFixitAppDelegate

@synthesize window, splitViewController, rootViewController, detailViewController, splashViewController;
@synthesize api;

#pragma mark -
#pragma mark Application lifecycle

// Override point for customization after app launch.
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	
	rootViewController.delegate = self;
	
    // Inject the splash view controller.
    self.splashViewController = [[SplashViewController alloc] initWithNibName:@"SplashView" bundle:nil];
    [self showSplash];
    
    // Add the split view controller's view to the window and display.
    [window addSubview:splitViewController.view];
    [window makeKeyAndVisible];

    return YES;
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

- (void)showGuide:(NSInteger)guideid {

	GuideViewController *vc = [GuideViewController initWithGuideid:guideid];
	[splitViewController presentModalViewController:vc animated:YES];
   
   // Save our state.
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setObject:[NSNumber numberWithInt:guideid] forKey:@"last_guide"];
	[prefs synchronize];
	
}

- (void)hideGuide {
	
	[splitViewController dismissModalViewControllerAnimated:YES];
   
   // Save our state.
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setObject:nil forKey:@"last_guide"];
	[prefs setObject:nil forKey:@"last_guide_page"];
	[prefs synchronize];
	
}


- (void)gotAreas:(NSDictionary *)areas {
    
    if ([areas isKindOfClass:[NSDictionary class]]) {
        [rootViewController setData:areas];
        [rootViewController.tableView reloadData];
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Network Error"
                                                            message:@"Failed loading device list."
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Try Again", nil];
        [alertView show];    
    }
	
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [alertView release];
    
    // Try Again
    if (buttonIndex) {
        [[iFixitAPI sharedInstance] getAreas:nil forObject:self withSelector:@selector(gotAreas:)];
    }
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
    if (!rootViewController.tree)
        [[iFixitAPI sharedInstance] getAreas:nil forObject:self withSelector:@selector(gotAreas:)];

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

