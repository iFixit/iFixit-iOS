//
//  iFixitAppDelegate.h
//  iFixit
//
//  Created by David Patierno on 8/6/10.
//  Copyright iFixit 2010. All rights reserved.
//

#import "iFixitAPI.h"

#import "LoginViewControllerDelegate.h"

@class CategoriesViewController;
@class DetailViewController;
@class GuideStepViewController;
@class SplashViewController;
@class Guide;
@class IntelligentSplitViewController;

@interface iFixitAppDelegate : NSObject <UIApplicationDelegate, LoginViewControllerDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IntelligentSplitViewController *splitViewController;
@property (nonatomic, retain) CategoriesViewController *categoriesViewController;
@property (nonatomic, retain) DetailViewController *detailViewController;

@property (nonatomic, retain) iFixitAPI *api;
@property (nonatomic) BOOL firstLoad;
@property (nonatomic) BOOL showsTabBar;

- (void)showDozukiSplash;
- (void)showSiteSplash;
- (UIViewController *)iPadRoot;
- (UIViewController *)iPhoneRoot;
- (void)loadSite:(NSDictionary *)site;
- (void)loadSiteWithDomain:(NSString *)domain;

@end
