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

@interface iFixitAppDelegate : NSObject <UIApplicationDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) UISplitViewController *splitViewController;
@property (nonatomic, retain) AreasViewController *areasViewController;
@property (nonatomic, retain) DetailViewController *detailViewController;

@property (nonatomic, retain) iFixitAPI *api;
@property (nonatomic) BOOL firstLoad;

- (void)showDozukiSplash;
- (void)showSiteSplash;
- (UIViewController *)iPadRoot;
- (UIViewController *)iPhoneRoot;
- (void)loadSite:(NSString *)domain;
- (void)loadSite:(NSString *)domain withColor:(UIColor *)color;

@end
