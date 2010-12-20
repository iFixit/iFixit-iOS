//
//  DetailViewController.m
//  iFixit
//
//  Created by David Patierno on 8/6/10.
//  Copyright iFixit 2010. All rights reserved.
//

#import "iFixitAppDelegate.h"
#import "DetailViewController.h"
#import "RootViewController.h"

@implementation DetailViewController

@synthesize toolbar, popoverController, webView, backButton, fwdButton;

#pragma mark -
#pragma mark Managing the detail item

/*
 When setting the detail item, update the view and dismiss the popover controller if it's showing.
 */
//[popoverController dismissPopoverAnimated:YES];


#pragma mark -
#pragma mark Split view support

- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc {
    
    barButtonItem.title = @"Browse";
    NSMutableArray *items = [[toolbar items] mutableCopy];
    [items insertObject:barButtonItem atIndex:0];
    [toolbar setItems:items animated:YES];
    [items release];
    self.popoverController = pc;
}


// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    NSMutableArray *items = [[toolbar items] mutableCopy];
    UIBarButtonItem *button = [items objectAtIndex:0];
    if ([button.title isEqual:@"Browse"]) {
        [items removeObjectAtIndex:0];
        [toolbar setItems:items animated:YES];
        [items release];
        self.popoverController = nil;
    }
}

- (void)splitViewController:(UISplitViewController*)svc popoverController:(UIPopoverController*)pc willPresentViewController:(UIViewController *)aViewController{
   if (popoverController != nil) {
      [popoverController dismissPopoverAnimated:YES];
   }
}


#pragma mark -
#pragma mark Rotation support

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


#pragma mark -
#pragma mark View lifecycle

 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	webView.delegate = self;
	
	// Setup the back button event.
	backButton.target = webView;
	backButton.action = @selector(goBack);
   fwdButton.target = webView;
	fwdButton.action = @selector(goForward);
	
	// Restore the last-visited URL.
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSString *last_url = [prefs objectForKey:@"last_url"];
	NSDate *last_launch_date = [prefs objectForKey:@"last_launch_date"];
   
   // Reset to root if it's been more than 1 hour since last launch.
	if (!last_url || (last_launch_date && [last_launch_date timeIntervalSinceNow] < -3600))
		last_url = START_URL;
	
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:last_url]];
	[webView loadRequest:request];
                     
   // Save launch date.
	[prefs setObject:[NSDate date] forKey:@"last_launch_date"];
	[prefs synchronize];
   
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeOther)
        return YES;
    
	NSString *host = [[request URL] host];

	// Open non-iFixit URLs with Safari.
	if (![host isEqual:IFIXIT_HOST]) {
		[[UIApplication sharedApplication] openURL:[request URL]];
		return NO;
	}
	
	// Open guides with the native viewer.
	NSInteger guideid = [self parseGuideURL:[[request URL] absoluteString]];
	if (guideid != -1) {
		[(iFixitAppDelegate *)[[UIApplication sharedApplication] delegate] showGuide:guideid];
		return NO;
	}
	
	// Load iFixit URLs inside the app.
	return YES;
}
- (void)webViewDidFinishLoad:(UIWebView *)wView {
	UIApplication* app = [UIApplication sharedApplication];
	app.networkActivityIndicatorVisible = NO;
	
	// Save our state.
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setObject:[[[wView request] URL] absoluteString] forKey:@"last_url"];
	[prefs synchronize];
	
	backButton.enabled = wView.canGoBack;
	fwdButton.enabled = wView.canGoForward;
}
- (void)webViewDidStartLoad:(UIWebView *)webView {
	UIApplication* app = [UIApplication sharedApplication];
	app.networkActivityIndicatorVisible = YES;
}

- (NSInteger)parseGuideURL:(NSString *)url {
	/*
	 (
	 "http:",
	 "",
	 "www.ifixit.com",
	 Guide,
	 Repair,
	 "Installing-iPhone-4-Speaker-Enclosure",
	 3149,
	 1
	 )
	 */
	int guideidLocation = 6;
	
	NSArray *components = [url componentsSeparatedByString:@"/"];
	
	if ([components count] < 7)
		return -1;
	
	// /Guide or /Teardown only
	NSString *first = [components objectAtIndex:3];
	NSString *second = [components objectAtIndex:4];
	if ([first isEqual:@"Teardown"] || [first isEqual:@"Project"]) {
		guideidLocation--;
	} else if (![first isEqual:@"Guide"] || ![second isEqual:@"Repair"]) {
		return -1;
	}
	
	return [[components objectAtIndex:guideidLocation] integerValue];
}

- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.popoverController = nil;
}

- (IBAction)showSplash:(UIBarButtonItem *)button {
    [(iFixitAppDelegate *)[[UIApplication sharedApplication] delegate] showSplash];   
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

- (void)dealloc {
    [popoverController release];
    [toolbar release];
    
    [super dealloc];
}

@end
