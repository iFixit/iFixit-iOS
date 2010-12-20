//
//  iFixitAppDelegate.h
//  iFixit
//
//  Created by David Patierno on 8/6/10.
//  Copyright iFixit 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iFixitAPI.h"

@class RootViewController;
@class DetailViewController;
@class GuideStepViewController;
@class SplashViewController;

@interface iFixitAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    
    UISplitViewController *splitViewController;
    
    RootViewController *rootViewController;
    DetailViewController *detailViewController;
    SplashViewController *splashViewController;
	
	iFixitAPI *api;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet UISplitViewController *splitViewController;
@property (nonatomic, retain) IBOutlet RootViewController *rootViewController;
@property (nonatomic, retain) IBOutlet DetailViewController *detailViewController;
@property (nonatomic, retain) IBOutlet SplashViewController *splashViewController;

@property (nonatomic, retain) iFixitAPI *api;

- (void)showGuide:(NSInteger)guideid;
- (void)hideGuide;
- (void)showBrowser;
- (void)showSplash;

@end
