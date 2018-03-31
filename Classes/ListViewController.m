//
//  ListViewController.m
//  iFixit
//
//  Created by David Patierno on 3/24/11.
//  Copyright 2011. All rights reserved.
//

#import "ListViewController.h"
#import "iFixitAppDelegate.h"
#import "BookmarksViewController.h"
#import "Config.h"
#import "CategoriesViewController.h"
#import "LoginViewController.h"

@implementation UINavigationBar (UINavigationBarCategory)

@end

@implementation ListViewController

@synthesize xframe, xbounds;

- (id)initWithRootViewController:(UIViewController *)rvc {
    if ((self = [super initWithRootViewController:rvc])) {
        // Custom initializing
        [self configureProperties];
    }
    
    return self;
}
- (void)dealloc {
    [super dealloc];
}

- (void)configureProperties {
    [self showFavoritesButton:self];
    
    // Set Navigation bar
    if ([Config currentConfig].site == ConfigIFixit) {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            self.navigationBar.translucent = NO;
        } else {
            self.navigationBar.tintColor = [Config currentConfig].toolbarColor;
            [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
            [[UINavigationBar appearance] setBackgroundColor:[Config currentConfig].toolbarColor];
            [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
        }
        
        self.navigationItem.leftBarButtonItem.tintColor = self.navigationItem.rightBarButtonItem.tintColor = [Config currentConfig].buttonColor;
    } else if ([Config currentConfig].site == ConfigMjtrim) {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            self.navigationBar.translucent = NO;
            self.navigationItem.leftBarButtonItem.tintColor = self.navigationItem.rightBarButtonItem.tintColor = [Config currentConfig].buttonColor;
        } else {
            [[UINavigationBar appearance] setTintColor:[Config currentConfig].toolbarColor];
        }

        NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                   [UIColor whiteColor],UITextAttributeTextColor,
                                                   nil];
        
        [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
    } else if ([Config currentConfig].site == ConfigDozuki) {
        self.navigationBar.translucent = NO;
        self.navigationItem.leftBarButtonItem.tintColor = self.navigationItem.rightBarButtonItem.tintColor = [Config currentConfig].buttonColor;
    } else {
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            self.navigationBar.translucent = NO;
        }

        if ([Config currentConfig].buttonColor) {
            self.navigationItem.leftBarButtonItem.tintColor = self.navigationItem.rightBarButtonItem.tintColor = [Config currentConfig].buttonColor;
        }
    }
    
}

// Override delegate method so we always have control of what to do when we pop a viewcontroller off the stack
- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    id viewController = [super popViewControllerAnimated:animated];
    
    // 1 view controller means we are at the root of our stack
    if (self.viewControllers.count == 1) {
        
        // Only on iPad do we want to force a selection on tabbar item 0
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            if (UIDeviceOrientationIsPortrait([viewController interfaceOrientation])) {
                [self.categoryTabBarViewController hideBrowseInstructions:NO];
            } else {
                [self.categoryTabBarViewController hideBrowseInstructions:YES];
                self.categoryTabBarViewController.browseButton.hidden = YES;
            }
            
            // Set the category to nil, force a selection on guides, then configure the frame.
            self.categoryTabBarViewController.selectedIndex = 0;
            [self.categoryTabBarViewController showTabBar:UIDeviceOrientationIsPortrait([viewController interfaceOrientation])];
            [self.categoryTabBarViewController enableTabBarItems:NO];
            [self.categoryTabBarViewController.detailGridViewController setCategory:nil];
            [self.categoryTabBarViewController.detailGridViewController.tableView reloadData];
            [self.categoryTabBarViewController configureSubViewFrame:0];
            
            // Make sure we always hide this on the root view
            [self.categoryTabBarViewController.detailGridViewController showNoGuidesImage:NO];
            
        } else {
            [self.categoryTabBarViewController showTabBar:NO];
        }
        
        // Force a rotate to ensure our logo is the correct size
        [self.viewControllers[0] willAnimateRotationToInterfaceOrientation:[viewController interfaceOrientation] duration:0];
    // Make sure that we only update the tabbar when we need to
    } else if ([viewController isKindOfClass:[CategoriesViewController class]]) {
        [self.categoryTabBarViewController updateTabBar:[self.topViewController categoryMetaData]];
         
//         self.xframe = ((UIViewController*)viewController).view.frame;
//         self.xbounds = ((UIViewController*)viewController).view.bounds;
    }
    
    return viewController;
}

- (void) viewDidLayoutSubviews {
     CGRect frame = self.view.frame;
     if (frame.size.width == 1024) {
        self.view.frame = self.xframe;
     } else {
          self.xframe = self.view.frame;
     }
}

- (void)statusBarBackground {
    UIView *statusBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10000, 50)];
    statusBarView.backgroundColor = [UIColor blackColor];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    // Terrible hack, this ensures that the tabbar is in the correct position in landscape, fixes an edgecase
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad && self.viewControllers.count == 1) {
        if (UIDeviceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) ) {
            self.categoryTabBarViewController.browseButton.hidden = YES;
        } else {
            self.categoryTabBarViewController.browseButton.hidden = NO;
        }
        
        [self.categoryTabBarViewController hideBrowseInstructions:YES];
    }
    
     [super pushViewController:viewController animated:animated];

     if ([viewController isKindOfClass:[CategoriesViewController class]]) {
//         self.xframe = ((CategoriesViewController*)viewController).view.frame;
//         self.xbounds = ((CategoriesViewController*)viewController).view.bounds;
    }
     
}
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self statusBarBackground];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {

    // This is so bad, but we force a redraw only on iPad+Landscape to avoid an edgecases
    if (UIDeviceOrientationIsLandscape(toInterfaceOrientation) && [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad &&
      SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        UIView *view = [window.subviews objectAtIndex:0];
        [view removeFromSuperview];
        [window addSubview:view];
    }

    [[UIApplication sharedApplication] setStatusBarOrientation:toInterfaceOrientation animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)showFavoritesButton:(id)viewController {
    // Create Favorites button if it doesn't already exist and add to navigation controller
    if (!self.favoritesButton) {
        UIBarButtonItem *favoritesButton = [[UIBarButtonItem alloc]
                                            initWithTitle:NSLocalizedString(@"Favorites", nil)
                                            style:UIBarButtonItemStyleBordered
                                            target:self action:@selector(favoritesButtonPushed)];
        
        self.favoritesButton = favoritesButton;
        [favoritesButton release];
    }
    
    [viewController navigationItem].rightBarButtonItem = self.favoritesButton;
}

- (void)refresh {
    [iFixitAPI checkCredentialsForViewController:self];
}

- (void)favoritesButtonPushed {
    [iFixitAPI checkCredentialsForViewController:self];
}

@end
