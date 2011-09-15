//
//  ThinDeviceViewController.m
//  iFixit
//
//  Created by David Patierno on 4/20/11.
//  Copyright 2011 iFixit. All rights reserved.
//

#import "ThinDeviceViewController.h"
#import "GuideCatchingWebView.h"
#import "iFixitAppDelegate.h"
#import "WBProgressHUD.h"

@implementation ThinDeviceViewController
@synthesize webView, loading, startURL;

- (id)initWithURL:(NSURL *)url {
    if ((self = [super initWithNibName:@"ThinDeviceView" bundle:nil])) {
        // Custom initialization
        self.startURL = url;
    }
    return self;
}

- (void)dealloc
{
    [webView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.loading = [[[WBProgressHUD alloc] init] autorelease];
    
    // Make room for the iPhone toolbar
    CGRect frame = webView.frame;
    frame.size.height -= 44;
    webView.frame = frame;

    if (startURL)
        [webView loadRequest:[NSURLRequest requestWithURL:startURL]];
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

- (void)webViewDidFinishLoad:(UIWebView *)theWebView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    [loading removeFromSuperview];
    theWebView.hidden = NO;
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

@end
