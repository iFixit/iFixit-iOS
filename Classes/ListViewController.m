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
#import "Utils.h"
#import "CategoriesViewController.h"

@implementation ListViewController

@synthesize bookmarksTVC, segmentedControl, categoryInfoViewController, categoryAnswersViewController, currentCategoryViewController;

int lastSelectedSegmentedControlIndex = 0;
BOOL segmentedControlTouched = NO;

- (id)initWithRootViewController:(UIViewController *)rvc {
    if ((self = [super initWithRootViewController:rvc])) {
        // Create the bookmarks view controller
        BookmarksViewController *bvc = [[BookmarksViewController alloc] initWithNibName:@"BookmarksView" bundle:nil];
        self.bookmarksTVC = bvc;
        [bvc release];
        
        // Create the Category WebView Info Viewcontroller
        CategoryWebViewController *civc = [[CategoryWebViewController alloc] initWithNibName:@"CategoryWebViewController" bundle:nil];
        civc.webViewType = @"info";
        self.categoryInfoViewController = civc;
        [self.categoryInfoViewController loadView];
        [civc release];
        
        CategoryWebViewController *cavc = [[CategoryWebViewController alloc] initWithNibName:@"CategoryWebViewController" bundle:nil];
        cavc.webViewType = @"answers";
        self.categoryAnswersViewController = cavc;
        [self.categoryAnswersViewController loadView];
        [cavc release];
        
        self.delegate = self;
    }
    
    return self;
}
- (void)dealloc {
    [bookmarksTVC release];
    [segmentedControl release];
    [categoryInfoViewController release];
    [categoryAnswersViewController release];
    [currentCategoryViewController release];
    
    [super dealloc];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    if (![viewController isKindOfClass:[CategoryWebViewController class]]) {
        
        currentCategoryViewController = viewController;
        // Only query if we need to, otherwise just update the segmented control options
        if (navigationController.viewControllers.count > 1 && ![currentCategoryViewController categoryMetaData]) {
            [[iFixitAPI sharedInstance] getTopic:[currentCategoryViewController currentCategory] forObject:self withSelector:@selector(gotTopic:)];
        } else {
            [self enableOrDisableSegmentedControlOptions];
        }
    }
}

// Override parent method, this allows us to do custom things with our view controller
- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    // Basically find out if a touch event was called
    if (self.segmentedControl.selectedSegmentIndex == self.GUIDES || segmentedControlTouched) {
        return [super popViewControllerAnimated:animated];
    } else {
        [self popToViewController:self.viewControllers[self.viewControllers.count - 3] animated:YES];
        self.segmentedControl.selectedSegmentIndex = lastSelectedSegmentedControlIndex = self.GUIDES;
    }
    
    return nil;
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
    
    
    // Add the toolbar with bookmarks toggle.
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        int diff = 20 + 44;
        // Adjust for the tab bar.
        iFixitAppDelegate *appDelegate = (iFixitAppDelegate*)[UIApplication sharedApplication].delegate;
        if (appDelegate.showsTabBar)
            diff += 49;
        toolbar.frame = CGRectMake(0, screenSize.width - diff, 320, 44);
    }
    else {
        toolbar.frame = CGRectMake(0, screenSize.height - 43, screenSize.width, 44);
        toolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    
    NSMutableArray *toggleItems = [NSMutableArray arrayWithObject:NSLocalizedString(@"Guides", nil)];
    
    // If answers are enabled, lets add it to the tab and set up our "Constants"
    // A lame attempt at dynamic constants.
    if ([Config currentConfig].answersEnabled) {
        self.GUIDES = 0;
        self.ANSWERS = 1;
        self.MORE_INFO = 2;
        [toggleItems addObject:NSLocalizedString(@"Answers", nil)];
    } else {
        self.GUIDES = 0;
        self.MORE_INFO = 1;
    }
    [toggleItems addObject:NSLocalizedString(@"More Info", nil)];
    
    segmentedControl = [[UISegmentedControl alloc] initWithItems:toggleItems];
    segmentedControl.selectedSegmentIndex = bookmarksTVC && self.topViewController == bookmarksTVC ? 1 : 0;
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    [segmentedControl addTarget:self action:@selector(toggleViews:) forControlEvents:UIControlEventValueChanged];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        toolbar.tintColor = [UIColor lightGrayColor];
        segmentedControl.tintColor = [UIColor lightGrayColor];
    }
    else {
        toolbar.tintColor = [Config currentConfig].toolbarColor;
        segmentedControl.tintColor = [[Config currentConfig].toolbarColor isEqual:[UIColor blackColor]] ? [UIColor darkGrayColor] : [Config currentConfig].toolbarColor;
    }
    
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                            target:nil
                                                                            action:nil];
    UIBarButtonItem *toggleItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
    NSArray *toolbarItems = [NSArray arrayWithObjects:spacer, toggleItem, spacer, nil];
    
    [toolbar setItems:toolbarItems];
    [spacer release];
    [toggleItem release];
    
    [self.view addSubview:toolbar];
    [toolbar release];
}

- (void)gotTopic:(NSDictionary *)results {
    [currentCategoryViewController setCategoryMetaData:results];
    [currentCategoryViewController setShowAnswers:([Config currentConfig].answersEnabled && [results[@"solutions"][@"count"] integerValue] > 0)];
    
    if ([results[@"contents"] length]) {
        [currentCategoryViewController setMoreInfoHTML:results[@"contents"]];
    }
    
    [self enableOrDisableSegmentedControlOptions];
}

- (void)enableOrDisableSegmentedControlOptions {
    [UIView transitionWithView:self.segmentedControl
                       duration:0.3f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        if ([currentCategoryViewController showAnswers])
                            [segmentedControl setEnabled:YES forSegmentAtIndex:self.ANSWERS];
                        else
                            [segmentedControl setEnabled:NO forSegmentAtIndex:self.ANSWERS];
                        
                        if ([[currentCategoryViewController moreInfoHTML] length])
                            [segmentedControl setEnabled:YES forSegmentAtIndex:self.MORE_INFO];
                        else 
                            [segmentedControl setEnabled:NO forSegmentAtIndex:self.MORE_INFO];
    } completion:nil];
}

- (void)toggleViews:(UISegmentedControl *)toggle {
    segmentedControlTouched = YES;
    
    // Guides
    if (toggle.selectedSegmentIndex == self.GUIDES) {
        [self popViewControllerAnimated:NO];
    // More Info
    } else if (toggle.selectedSegmentIndex == self.MORE_INFO) {
        if (!lastSelectedSegmentedControlIndex == self.GUIDES)
            [self popViewControllerAnimated:NO];
        
        [self configureAndPushViewController:categoryInfoViewController];
    // Answers
    } else {
        if (!lastSelectedSegmentedControlIndex == self.GUIDES)
            [self popViewControllerAnimated:NO];
        
        [self configureAndPushViewController:categoryAnswersViewController];
    }
    
    lastSelectedSegmentedControlIndex = toggle.selectedSegmentIndex;
    segmentedControlTouched = NO;
}

// Configure the view we want and push it on our navigational stack
- (void)configureAndPushViewController:(id)viewController {
    NSString *currentCategory = [currentCategoryViewController currentCategory];
    NSString *previousCategory = self.navigationBar.backItem.title;
    
    // Only load the URL if we haven't seen it before
    if (![[viewController category] isEqualToString:currentCategory]) {
        [viewController setTitle:currentCategory];
        [viewController setCategory:currentCategory];
        
        // Clear the view before diplaying a new one
        if ([[viewController webViewType] isEqualToString:@"info"]) {
            [[viewController webView] loadHTMLString:[Utils configureHtmlForWebview:[currentCategoryViewController categoryMetaData]] baseURL:nil];
        } else {
            [[viewController webView] loadRequest:[Utils buildCategoryWebViewURL:currentCategory webViewType:[viewController webViewType]]];
        }
        
        // Pass a reference to the view controller
        [viewController setListViewController:self];
    }
    
    [self pushViewController:viewController animated:NO];
    self.navigationBar.backItem.title = previousCategory;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [categoryAnswersViewController release];
    [categoryInfoViewController release];
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
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:bvc];
    
    // Use deprecated method on purpose to preserve iOS 4.3
    [self presentModalViewController:nvc animated:YES];
    
    [bvc release];
    [nvc release];
}

@end
