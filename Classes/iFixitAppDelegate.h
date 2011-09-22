//
//  iFixitAppDelegate.h
//  iFixit
//
//  Created by David Patierno on 8/6/10.
//  Copyright iFixit 2010. All rights reserved.
//

#import "iFixitAPI.h"

@class AreasViewController;
@class DetailViewController;
@class GuideStepViewController;
@class SplashViewController;
@class Guide;

@interface iFixitAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    
    UISplitViewController *splitViewController;
    
    AreasViewController *areasViewController;
    DetailViewController *detailViewController;
    SplashViewController *splashViewController;
	
	iFixitAPI *api;
    BOOL firstLoad;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) UISplitViewController *splitViewController;
@property (nonatomic, retain) AreasViewController *areasViewController;
@property (nonatomic, retain) DetailViewController *detailViewController;
@property (nonatomic, retain) IBOutlet SplashViewController *splashViewController;

@property (nonatomic, retain) iFixitAPI *api;
@property (nonatomic) BOOL firstLoad;

+ (BOOL)isIPad;
- (void)showDozukiSplash;
- (void)showSiteSplash;
- (UIViewController *)iPadRoot;
- (UIViewController *)iPhoneRoot;
- (void)showBrowser;
- (void)showSplash;
- (void)loadSite:(NSString *)domain;

@end
