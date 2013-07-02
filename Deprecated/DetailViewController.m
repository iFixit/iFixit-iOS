////
////  DetailViewController.m
////  iFixit
////
////  Created by David Patierno on 8/6/10.
////  Copyright iFixit 2010. All rights reserved.
////
//
//#import "iFixitAppDelegate.h"
//#import "Config.h"
//#import "DetailViewController.h"
//#import "CategoriesViewController.h"
//#import "ListViewController.h"
//#import "GuideCatchingWebView.h"
//#import "WBProgressHUD.h"
//#import "SVWebViewController.h"
//#import "DetailGridViewController.h"
//#import "DetailIntroViewController.h"
//#import "Utils.h"
//
//@implementation DetailViewController
//
//@synthesize popoverController, lastURL, deviceToolbarItems, browseButton;
//@synthesize introViewController, gridViewController;
//
//#pragma mark -
//#pragma mark Managing the detail item
//
//CGRect subViewFrame;
//
//- (id)init {
//    subViewFrame = CGRectMake(0.0, 44.0, 768.0, 1004.0 - 44.0 - 49.0);
//    
//    if ((self = [super initWithNibName:nil bundle:nil])) {
//        self.gridViewController = [[[DetailGridViewController alloc] init] autorelease];
//        self.gridViewController.view.frame = subViewFrame;
//        self.introViewController = [[[DetailIntroViewController alloc] init] autorelease];
//        self.introViewController.view.frame = subViewFrame;
//        
//        
//        gridViewController.gridDelegate = self;
//
//        // Initialize the Browse button.
//        CategoriesViewController *avc = [[CategoriesViewController alloc] init];
//        avc.inPopover = YES;
//        ListViewController *lvc = [[ListViewController alloc] initWithRootViewController:avc];
//        avc.detailViewController = self;
//        [avc getAreas];
//        self.popoverController = [[[UIPopoverController alloc] initWithContentViewController:lvc] autorelease];
//        [lvc release];
//        [avc release];
//        
//        CategoryWebViewController *civc = [[CategoryWebViewController alloc] initWithNibName:@"CategoryWebViewController" bundle:nil];
//        civc.webViewType = @"info";
//        self.categoryInfoViewController = civc;
//        self.categoryInfoViewController.view.frame = subViewFrame;
//        self.categoryInfoViewController.webView.frame = subViewFrame;
//        [self.categoryInfoViewController loadView];
//        [civc release];
//        
//        SVWebViewController *cavc = [[SVWebViewController alloc] initWithAddress:@"http://www.google.com"];
//        self.categoryAnswersViewController = cavc;
//        self.categoryAnswersViewController.view.frame = subViewFrame;
//        [cavc release];
//    }
//    return self;
//}
//
//- (void)updateOrientation {
////    introViewController.orientationOverride = self.interfaceOrientation;
////    gridViewController.orientationOverride = self.interfaceOrientation;
////    
////    [introViewController positionImages];
////    [gridViewController.tableView reloadData];
////    
////    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
////        if (!browseButton)
////            self.browseButton = [[[UIBarButtonItem alloc] initWithTitle:@"Browse"
////                                                                  style:UIBarButtonItemStyleBordered
////                                                                 target:self
////                                                                 action:@selector(popupAreas)] autorelease];
////        if (![toolbar.items containsObject:browseButton]) {
////            NSMutableArray *items = [toolbar.items mutableCopy];
////            [items insertObject:browseButton atIndex:0];
////            toolbar.items = items;
////            [items release];
////        }
////    }
////    else {
////        if ([toolbar.items containsObject:browseButton]) {
////            NSMutableArray *items = [toolbar.items mutableCopy];
////            [items removeObject:browseButton];
////            toolbar.items = items;
////            [items release];
////        }
////    }
//}
//
//- (void)popupAreas {
//    if (popoverController.isPopoverVisible) {
//        [popoverController dismissPopoverAnimated:YES];
//        return;
//    }
//    
//    [popoverController presentPopoverFromBarButtonItem:browseButton permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
//}
//
//- (void)viewWillAppear:(BOOL)animated {
//    [self updateOrientation];
//}
//
//#pragma mark -
//#pragma mark Rotation support
//
//// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
//    return YES;
//}
//
//#pragma mark -
//#pragma mark View lifecycle
//
//- (void)displayGrid {
//    //gridViewController.device = [self.listViewController.currentCategoryViewController currentCategory];
//    //gridViewController.toolbarItems = self.toolbarItems;
//    
//    //[self.view addSubview:gridViewController.view];
//    
//    //self.navigationController.viewControllers = @[gridViewController];
//    //self.navigationBar.backItem = nil;
//    //    gridViewController.navigationItem.titleView = segmentedControl;
//    //    [introViewController.view removeFromSuperview];
////    self.introViewController = nil;
////    
////    wikiWebView.hidden = YES;
////    answersWebView.hidden = YES;
////    gridViewController.view.hidden = NO;
//}
//
//- (void)displayWikiView {
//    [self.categoryInfoViewController.webView loadHTMLString:[Utils configureHtmlForWebview:[self.listViewController.currentCategoryViewController categoryMetaData]] baseURL:nil];
//    [self.view.subviews.lastObject removeFromSuperview];
//    [self.view addSubview:self.categoryInfoViewController.view];
//    
//    
////    [introViewController.view removeFromSuperview];
////    self.introViewController = nil;
////    
////    wikiWebView.hidden = NO;
////    answersWebView.hidden = YES;
////    gridViewController.view.hidden = YES;
//}
//
//- (void)displayAnswersView {
//    [self.view.subviews.lastObject removeFromSuperview];
//    [self.view addSubview:self.categoryAnswersViewController.view];
//    //[self configureAndPushViewController:self.categoryAnswersViewController];
//    //self.categoryAnswersViewController.navigationItem.titleView = segmentedControl;
//    //    [introViewController.view removeFromSuperview];
////    self.introViewController = nil;
////    
////    answersWebView.hidden = NO;
////    wikiWebView.hidden = YES;
////    gridViewController.view.hidden = YES;
//}
//
//- (void)configureAndPushViewController:(id)viewController {
//    NSString *currentCategory = [self.listViewController.currentCategoryViewController currentCategory];
//    
//    // Only load the URL if we haven't seen it before
//    if (![[viewController category] isEqualToString:currentCategory]) {
//        [viewController setTitle:currentCategory];
//        [viewController setCategory:currentCategory];
//        
//        // Clear the webview
//        [[viewController webView] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
//        
//        // Clear the view before diplaying a new one
//        if ([[viewController webViewType] isEqualToString:@"info"]) {
//            [[viewController webView] loadHTMLString:[Utils configureHtmlForWebview:[self.listViewController.currentCategoryViewController categoryMetaData]] baseURL:nil];
//        } else {
//            [[viewController webView] loadRequest:[Utils buildCategoryWebViewURL:currentCategory webViewType:[viewController webViewType]]];
//        }
//    }
//    
//    // Get a nice transition view, or create a new UIWebView each time
////    [UIView beginAnimations:@"animation" context:nil];
//    [self.navigationController pushViewController:viewController animated:NO];
//}
//
//- (void)toggleViews:(id)sender {
//    
//    if (segmentedControl.selectedSegmentIndex == self.listViewController.GUIDES) {
//        [self displayGrid];
//    } else if (segmentedControl.selectedSegmentIndex == self.listViewController.MORE_INFO) {
//        //[self displayWikiView];
//    // This must be answers
//    } else if (segmentedControl.selectedSegmentIndex == self.listViewController.ANSWERS) {
//        //[self displayAnswersView];
//    }
//}
//
//- (void)setDevice:(NSString *)device {
//    //gridViewController.device = device;
//    segmentedControl.selectedSegmentIndex = 0;
//    [self displayGrid];
//}
//
//- (void)reset {
//    [popoverController dismissPopoverAnimated:YES];
//
//    //gridViewController.device = nil;
//
//    //self.toolbar.items = self.deviceToolbarItems;
//    [self updateOrientation];
//    
//    [self displayWikiView];
//}
//
//- (void)createFistView {
//    introViewController.orientationOverride = self.interfaceOrientation;
//    [introViewController positionImages];
//    
//    [self.view addSubview:introViewController.view];
//}
//
//- (void)updateSegmentedControlSelection {
//    // We only care about the first enabled index, once we find it let's break
//    for (int i = 0; i < segmentedControl.numberOfSegments; i++) {
//        if ([segmentedControl isEnabledForSegmentAtIndex:i]) {
//            segmentedControl.selectedSegmentIndex = i;
//            break;
//        }
//    }
//    
//    // Display the view based on segmented control index
//    [self toggleViews:self];
//}
//
// // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    
//    // Create reference to list view controller
//    self.listViewController = self.splitViewController.viewControllers[0];
//    
//    // Color the toolbar, and hide the navigation bar
//    self.toolBar.tintColor = [Config currentConfig].toolbarColor;
//    
//    //
////    wikiWebView.hidden = YES;
////
////    // Restore the last URL if our view unloaded from a memory warning.
////    if (lastURL) {
////        NSURLRequest *request = [NSURLRequest requestWithURL:lastURL];
////        [wikiWebView loadRequest:request];
////    }
////    else {
////        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[Config baseURL]]];
////        [wikiWebView loadRequest:request];
////    }
//
//    // Add the segmented control to the navigation bar.
//    
////    NSString *guidesText = [Config currentConfig].site == ConfigMake ? @"Projects" : @"Guides";
////    NSArray *titleItems = [NSArray arrayWithObjects:guidesText, @"More Info", nil];
////    // Add Answers if it's enabled
////    if ([Config currentConfig].answersEnabled)
////        titleItems = [NSArray arrayWithObjects:guidesText, @"Answers", @"More Info", nil];
//    
//    //self.segmentedControl = [[[UISegmentedControl alloc] initWithItems:titleItems] autorelease];
//   // segmentedControl.selectedSegmentIndex = 0;
////    [segmentedControl addTarget:self action:@selector(toggleView:) forControlEvents:UIControlEventValueChanged];
////    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
////    segmentedControl.tintColor = [[Config currentConfig].toolbarColor isEqual:[UIColor blackColor]] ? [UIColor darkGrayColor] : [Config currentConfig].toolbarColor;
////    CGRect frame = segmentedControl.frame;
////    frame.size.width = [Config currentConfig].answersEnabled ? 300.0 : 250.0;
////    segmentedControl.frame = frame;
//   // segmentedControl.hidden = NO;
//   // segmentedControl.selectedSegmentIndex = 0;
//    
//    NSMutableArray *items = [NSMutableArray array];
//    
//    UIBarButtonItem *segmentedItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
//    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
//    fixedSpace.width = 60.0;
//    [items addObject:flexibleSpace];
//    [items addObject:segmentedItem];
//    [items addObject:flexibleSpace];
//    [items addObject:fixedSpace]; // Balance out the Browse button.
//    
//    
//    self.toolBar.items = items;
//    
//    [fixedSpace release];
//    [segmentedItem release];
//    [flexibleSpace release];
//    
//    if ([[Config currentConfig].backgroundColor isEqual:[UIColor whiteColor]])
//        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"concreteBackgroundWhite.png"]];
//    else
//        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"concreteBackground.png"]];
//
//    // Size the grid view appropriately prepare it for display.
////    gridViewController.view.frame = wikiWebView.frame;
////    gridViewController.view.hidden = YES;
////    [self.view addSubview:gridViewController.view];
//
//    // Show the fist!
//    [self createFistView];
//}
//
//- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
//    [popoverController dismissPopoverAnimated:YES];
//    [self updateOrientation];
//}
//
//- (BOOL)webView:(UIWebView *)theWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
//    // Open all links in a modal browser.
//    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
//        NSString *url = [[request URL] absoluteString];
//        SVWebViewController *browser = [[SVWebViewController alloc] initWithAddress:url];
//        [self presentModalViewController:browser animated:YES];
//        [browser release];
//        return NO;
//    }
//
//    self.lastURL = [request URL];
//
//    return YES;
//}
//
//- (void)webViewDidFinishLoad:(UIWebView *)theWebView {	
//    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//}
//- (void)webViewDidStartLoad:(UIWebView *)theWebView {
//	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
//}
//
//- (void)viewDidUnload {
//    [self setToolBar:nil];
//    [super viewDidUnload];
//    
//    // Release any retained subviews of the main view.
//    // e.g. self.myOutlet = nil;
//    self.segmentedControl = nil;
//}
//
//#pragma mark -
//#pragma mark Memory management
//
///*
//- (void)didReceiveMemoryWarning {
//    // Releases the view if it doesn't have a superview.
//    [super didReceiveMemoryWarning];
//    
//    // Release any cached data, images, etc that aren't in use.
//}
//*/
//
//- (void)detailGrid:(DetailGridViewController *)detailGrid gotGuideCount:(NSInteger)count {
//    if (!count) {
//        // Select the "More Info" tab
//        segmentedControl.selectedSegmentIndex = [Config currentConfig].answersEnabled ? 2 : 1;
//        [self displayWikiView];
//    }
//}
//
//- (void)dealloc {
//    [lastURL release];
//    [popoverController release];
//    [introViewController release];
//    [gridViewController release];
//    [segmentedControl release];
//    [browseButton release];
//    
//    
//    [_toolBar release];
//    [super dealloc];
//}
//
//@end
