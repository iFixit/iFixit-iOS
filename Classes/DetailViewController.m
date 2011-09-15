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

@implementation DetailViewController

@synthesize toolbar, popoverController, webView, loading, lastURL, backButton, fwdButton;

#pragma mark -
#pragma mark Managing the detail item

/*
 When setting the detail item, update the view and dismiss the popover controller if it's showing.
 */
//[popoverController dismissPopoverAnimated:YES];

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        self.lastURL = nil;
    }
    return self;
}

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
    
    self.toolbar.tintColor = [Config currentConfig].toolbarColor;
    self.loading = [[[WBProgressHUD alloc] init] autorelease];
    
	webView.delegate = self;
    
    // Restore the last URL if our view unloaded from a memory warning.
    if (lastURL) {
        NSURLRequest *request = [NSURLRequest requestWithURL:lastURL];
        [webView loadRequest:request];
    }
    else {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[Config baseURL]]];
        [webView loadRequest:request]; 
    }
	
	// Setup the back button event.
	backButton.target = webView;
	backButton.action = @selector(goBack);
    fwdButton.target = webView;
	fwdButton.action = @selector(goForward);
    
    // Hide the splash button if on a Dozuki site.
    if ([Config currentConfig].dozuki) {
        NSMutableArray *items = [[toolbar items] mutableCopy];
        [items removeObjectAtIndex:0];
        [toolbar setItems:items animated:YES];
    }
}

- (NSDictionary *)treeMatchInTree:(NSDictionary *)tree forURL:(NSString *)url {
    NSMutableArray *items = [NSMutableArray array];
    
    if ([tree respondsToSelector:@selector(allKeys)]) {
        [items addObjectsFromArray:[tree allKeys]];
        [items addObjectsFromArray:[tree objectForKey:@"DEVICES"]];
    }
    
    NSArray *types = [NSArray arrayWithObjects:@"Browse", @"Area", @"Topic", @"Device", nil];
    
    for (NSString *area in items) {
        for (NSString *type in types) {
            NSString *areaURL = [NSString stringWithFormat:@"http://%@/%@/%@", 
                                 [Config host],
                                 type,
                                 [area stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
            areaURL = [areaURL stringByReplacingOccurrencesOfString:@"%20" withString:@"_"];
            
            // Match.
            if ([areaURL isEqual:url]) {
                // Found an Area. Update the tree and navigate normally.
                NSDictionary *found = [tree objectForKey:area];
                if (found)
                    return [NSDictionary dictionaryWithObjectsAndKeys:areaURL, @"url", found, @"tree", area, @"area", nil];;
                
                // Found a device. Navigate normally.
                return [NSDictionary dictionaryWithObjectsAndKeys:areaURL, @"url", nil];
            }
        }
    }
    
    if ([tree respondsToSelector:@selector(objectForKey:)])
        for (NSString *area in [tree allKeys]) {
            NSDictionary *found = [self treeMatchInTree:[tree objectForKey:area] forURL:url];
            if (found)
                return found;
        }
    
    return nil;
}

- (BOOL)webView:(UIWebView *)theWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    self.lastURL = [request URL];

    // Parse area links.
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        NSString *url = [[request URL] absoluteString];
        ListViewController *lvc = [self.splitViewController.viewControllers objectAtIndex:0];
        if ([lvc.topViewController class] != [AreasViewController class])
            return NO;
        
        AreasViewController *avc = (AreasViewController *)lvc.topViewController;
        
        NSDictionary *found = [self treeMatchInTree:avc.data forURL:url];
        if (found) {
            NSDictionary *tree = [found objectForKey:@"tree"];
            if (tree) {
                AreasViewController *vc = [[AreasViewController alloc] init];
                vc.detailViewController = self;
                [vc setData:tree];
                [vc.tableView reloadData];
                
                vc.title = [found objectForKey:@"area"];
                [avc.navigationController pushViewController:vc animated:YES];
                [vc release];
            }
            
            url = [found objectForKey:@"url"];
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
            [theWebView loadRequest:request];
            return NO;
        }
    }
    
    return YES;
}


- (void)webViewDidFinishLoad:(UIWebView *)theWebView {	
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	backButton.enabled = theWebView.canGoBack;
	fwdButton.enabled = theWebView.canGoForward;

    [loading removeFromSuperview];
    theWebView.hidden = NO;
}
- (void)webViewDidStartLoad:(UIWebView *)theWebView {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    int width = 160;
    int height = 120;
    CGRect wFrame = theWebView.frame;
    loading.frame =  CGRectMake(wFrame.origin.x + wFrame.size.width / 2 - width / 2,
                                wFrame.origin.y + wFrame.size.height / 2 - height / 2 - 44, 
                                width, height);
    [loading showInView:self.view];
    theWebView.hidden = YES;
}

- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.popoverController = nil;
    self.loading = nil;
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
    self.loading = nil;
    [popoverController release];
    [toolbar release];
    
    [super dealloc];
}

@end
