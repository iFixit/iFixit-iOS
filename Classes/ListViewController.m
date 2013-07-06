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

@implementation ListViewController

- (id)initWithRootViewController:(UIViewController *)rvc {
    if ((self = [super initWithRootViewController:rvc])) {
        // Custom initializing
    }
    
    return self;
}
- (void)dealloc {
    [super dealloc];
}

// Override delegate method so we always have control of what to do when we pop a viewcontroller off the stack
- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    id viewController = [super popViewControllerAnimated:animated];
    
    // 1 view controller means we are at the root of our stack
    if (self.viewControllers.count == 1) {
        [self.categoryTabBarViewController showTabBar:NO];
        
        // Only on iPad do we want to force a selection on tabbar item 0
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            // Set the category to nil, force a selection on guides, then configure the frame.
            [self.categoryTabBarViewController.detailGridViewController setCategory:nil];
            self.categoryTabBarViewController.selectedIndex = 0;
            [self.categoryTabBarViewController configureSubViewFrame:0];
        }
    } else {
        [self.categoryTabBarViewController updateTabBar:[self.topViewController categoryMetaData]];
    }
    
    return viewController;
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
    self.navigationBar.tintColor = [Config currentConfig].toolbarColor;
    
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
    // Create Favorites button and add to navigation controller
    UIBarButtonItem *favoritesButton = [[UIBarButtonItem alloc]
                                        initWithTitle:NSLocalizedString(@"Favorites", nil)
                                        style:UIBarButtonItemStyleBordered
                                        target:self action:@selector(favoritesButtonPushed)];
    
    [viewController navigationItem].rightBarButtonItem = favoritesButton;
    [favoritesButton release];
}

- (void)favoritesButtonPushed {
    BookmarksViewController *bvc = [[BookmarksViewController alloc] initWithNibName:@"BookmarksView" bundle:nil];
    
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
        
        [self presentModalViewController:nvc animated:YES];
        [nvc release];
    }
        
    [bvc release];
}

@end
