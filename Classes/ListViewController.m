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

@implementation UINavigationBar (UINavigationBarCategory)

// iOS 4.3
- (void)drawRect:(CGRect)rect {
    UIColor *color = [UIColor colorWithRed:39/255.0f green:41/255.0f blue:43/255.0f alpha:1.0f];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColor(context, CGColorGetComponents([color CGColor]));
    CGContextFillRect(context, rect);
}

@end

@implementation ListViewController

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
        self.navigationBar.tintColor = [Config currentConfig].toolbarColor;
        [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearance] setBackgroundColor:[Config currentConfig].toolbarColor];
    } else if ([Config currentConfig].site == ConfigMjtrim) {
        self.navigationBar.tintColor = [UIColor colorWithRed:204/255.0f green:0 blue:0 alpha:1];
        self.navigationItem.leftBarButtonItem.tintColor = self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:140/255.0f green:48/255.0f blue:49/255.0f alpha:1];
    } else {
        self.navigationBar.tintColor = [Config currentConfig].toolbarColor;
        if ([Config currentConfig].buttonColor) {
            self.navigationItem.rightBarButtonItem.tintColor = [Config currentConfig].buttonColor;
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
    } else {
        [self.categoryTabBarViewController updateTabBar:[self.topViewController categoryMetaData]];
    }
    
    return viewController;
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
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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

- (void)favoritesButtonPushed {
    
    BookmarksViewController *bvc = [[BookmarksViewController alloc] initWithNibName:@"BookmarksView" bundle:nil];
    bvc.listViewController = self;
    
    // Create the animation ourselves to mimic a modal presentation
    // On iPad we must push the view onto a stack, instead of presenting
    // it modally or else undesired side effects occur
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        [UIView animateWithDuration:0.7
                         animations:^{
                             [self pushViewController:bvc animated:NO];
                             [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.view cache:YES];
                         }];
    else {
        UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:bvc];
        
        nvc.navigationBar.tintColor = [Config currentConfig].toolbarColor;
        
        [self presentModalViewController:nvc animated:YES];
        [nvc release];
    }
        
    [bvc release];
}

@end
