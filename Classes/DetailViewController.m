//
//  DetailViewController.m
//  iFixit
//
//  Created by David Patierno on 8/6/10.
//  Copyright iFixit 2010. All rights reserved.
//

#import "iFixitAppDelegate.h"
#import "Config.h"
#import "DetailViewController.h"
#import "AreasViewController.h"
#import "ListViewController.h"
#import "GuideCatchingWebView.h"
#import "WBProgressHUD.h"
#import "SVWebViewController.h"
#import "DetailGridViewController.h"
#import "DetailIntroViewController.h"

@implementation DetailViewController

@synthesize toolbar, popoverController, webView, lastURL, deviceToolbarItems, segmentedControl, browseButton;
@synthesize introViewController, gridViewController;

#pragma mark -
#pragma mark Managing the detail item

- (id)init {
    if ((self = [super initWithNibName:nil bundle:nil])) {
        self.gridViewController = [[[DetailGridViewController alloc] init] autorelease];
        self.introViewController = [[[DetailIntroViewController alloc] init] autorelease];
        gridViewController.gridDelegate = self;

        // Initialize the Browse button.
        AreasViewController *avc = [[AreasViewController alloc] init];
        avc.inPopover = YES;
        ListViewController *lvc = [[ListViewController alloc] initWithRootViewController:avc];
        avc.detailViewController = self;
        [avc getAreas];
        self.popoverController = [[[UIPopoverController alloc] initWithContentViewController:lvc] autorelease];
        [lvc release];
        [avc release];
    }
    return self;
}

- (void)updateOrientation {
    introViewController.orientationOverride = self.interfaceOrientation;
    gridViewController.orientationOverride = self.interfaceOrientation;
    
    [introViewController positionImages];
    [gridViewController.tableView reloadData];
    
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        if (!browseButton)
            self.browseButton = [[[UIBarButtonItem alloc] initWithTitle:@"Browse"
                                                                  style:UIBarButtonItemStyleBordered
                                                                 target:self
                                                                 action:@selector(popupAreas)] autorelease];
        if (![toolbar.items containsObject:browseButton]) {
            NSMutableArray *items = [toolbar.items mutableCopy];
            [items insertObject:browseButton atIndex:0];
            toolbar.items = items;
            [items release];
        }
    }
    else {
        if ([toolbar.items containsObject:browseButton]) {
            NSMutableArray *items = [toolbar.items mutableCopy];
            [items removeObject:browseButton];
            toolbar.items = items;
            [items release];
        }
    }
}

- (void)popupAreas {
    if (popoverController.isPopoverVisible) {
        [popoverController dismissPopoverAnimated:YES];
        return;
    }
    
    [popoverController presentPopoverFromBarButtonItem:browseButton permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [self updateOrientation];
}

#pragma mark -
#pragma mark Rotation support

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark -
#pragma mark View lifecycle

- (void)displayGrid {
    [introViewController.view removeFromSuperview];
    self.introViewController = nil;
    
    webView.hidden = YES;
    gridViewController.view.hidden = NO;
}

- (void)displayWebView {
    [introViewController.view removeFromSuperview];
    self.introViewController = nil;
    
    webView.hidden = NO;
    gridViewController.view.hidden = YES;
}

- (void)toggleView:(id)sender {
    if (!gridViewController.view.hidden) {
        [self displayWebView];
    }
    else {
        [self displayGrid];
    }
}

- (void)setDevice:(NSString *)device {
    if ([self.toolbar.items count] <= 2)
        self.toolbar.items = [self.toolbar.items arrayByAddingObjectsFromArray:self.deviceToolbarItems];    
    
    gridViewController.device = device;
    segmentedControl.selectedSegmentIndex = 0;
    [self displayGrid];
}

- (void)reset {
    [popoverController dismissPopoverAnimated:YES];

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]];        
    [webView loadRequest:request];

    self.toolbar.items = [NSArray array];
    [self updateOrientation];
    
    [self displayWebView];
}

- (void)createFistView {
    CGRect frame = CGRectMake(0.0, 44.0, 768.0, 1004.0 - 44.0 - 49.0);
    introViewController.view.frame = frame;
    
    introViewController.orientationOverride = self.interfaceOrientation;
    [introViewController positionImages];
    
    [self.view addSubview:introViewController.view];
}

 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.toolbar.tintColor = [Config currentConfig].toolbarColor;
    
	webView.delegate = self;
    webView.hidden = YES;
    
    // Restore the last URL if our view unloaded from a memory warning.
    if (lastURL) {
        NSURLRequest *request = [NSURLRequest requestWithURL:lastURL];
        [webView loadRequest:request];
    }
    else {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[Config baseURL]]];
        [webView loadRequest:request]; 
    }

    // Add the segmented control to the navigation bar.
    NSMutableArray *items = [NSMutableArray array];
    self.segmentedControl = [[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Guides", @"More Info", nil]] autorelease];
    segmentedControl.selectedSegmentIndex = 0;
    [segmentedControl addTarget:self action:@selector(toggleView:) forControlEvents:UIControlEventValueChanged];
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    segmentedControl.tintColor = [[Config currentConfig].toolbarColor isEqual:[UIColor blackColor]] ? [UIColor darkGrayColor] : [Config currentConfig].toolbarColor;
    CGRect frame = segmentedControl.frame;
    frame.size.width = 220.0;
    segmentedControl.frame = frame;
    
    UIBarButtonItem *segmentedItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpace.width = 60.0;
    [items addObject:flexibleSpace];
    [items addObject:segmentedItem];
    [items addObject:flexibleSpace];
    [items addObject:fixedSpace]; // Balance out the Browse button.
    [fixedSpace release];
    [segmentedItem release];
    [flexibleSpace release];
    
    self.deviceToolbarItems = items;
        
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"concreteBackground.png"]];

    // Size the grid view appropriately prepare it for display.
    gridViewController.view.frame = webView.frame;
    gridViewController.view.hidden = YES;
    [self.view addSubview:gridViewController.view];

    // Show the fist!
    [self createFistView];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [popoverController dismissPopoverAnimated:YES];
    [self updateOrientation];
}

- (BOOL)webView:(UIWebView *)theWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    // Open all links in a modal browser.
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        NSString *url = [[request URL] absoluteString];
        SVWebViewController *browser = [[SVWebViewController alloc] initWithAddress:url];
        [self presentModalViewController:browser animated:YES];
        [browser release];
        return NO;
    }

    self.lastURL = [request URL];

    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)theWebView {	
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
- (void)webViewDidStartLoad:(UIWebView *)theWebView {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.toolbar = nil;
    self.webView = nil;
    self.segmentedControl = nil;
}

#pragma mark -
#pragma mark Memory management

/*
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
*/

- (void)detailGrid:(DetailGridViewController *)detailGrid gotGuideCount:(NSInteger)count {
    if (!count) {
        segmentedControl.selectedSegmentIndex = 1;
        [self displayWebView];
    }
}

- (void)dealloc {
    webView.delegate = nil;
    
    [toolbar release];
    [webView release];
    [lastURL release];
    [popoverController release];
    [introViewController release];
    [gridViewController release];
    [segmentedControl release];
    [browseButton release];
    
    
    [super dealloc];
}

@end
