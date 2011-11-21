    //
//  GuideIntroViewController.m
//  iFixit
//
//  Created by David Patierno on 8/9/10.
//  Copyright 2010 iFixit. All rights reserved.
//

#import "GuideIntroViewController.h"
#import "Guide.h"
#import "UIButton+WebCache.h"
#import "Config.h"
#import "SVWebViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation GuideIntroViewController

@synthesize delegate, headerImageIFixit, headerImageMake, swipeLabel;
@synthesize guide=_guide;
@synthesize device, mainImage, webView, imageSpinner, huge, html;

// Load the view nib and initialize the guide.
- (id)initWithGuide:(Guide *)guide {
    if ((self = [super initWithNibName:@"GuideIntroView" bundle:nil])) {
        self.guide = guide;
        self.huge = nil;
    }	
    return self;
}

- (void)removeWebViewShadows {
    NSArray *subviews = [webView subviews];
    if ([subviews count]) {
        for (UIView *wview in [[subviews objectAtIndex:0] subviews]) { 
            if ([wview isKindOfClass:[UIImageView class]]) {
                wview.hidden = YES;
            }
        }
    }
}

- (void)addViewShadow:(UIView *)view {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        // Apply a blur!
        [view.layer setRasterizationScale:0.25];
        [view.layer setShouldRasterize:YES];
        return;
    }
    
    view.layer.masksToBounds = NO;
    view.layer.shadowOffset = CGSizeMake(0.0, 1.0);
    view.layer.shadowRadius = 3.0;
    view.layer.shadowOpacity = 0.8;
    view.layer.shadowPath = [UIBezierPath bezierPathWithRect:view.bounds].CGPath;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    swipeLabel.font = [UIFont fontWithName:@"Ubuntu-BoldItalic" size:48.0];

    // Set the appropriate header image.
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        if ([Config currentConfig].site == ConfigMake || [Config currentConfig].site == ConfigMakeDev) {
            headerImageMake.hidden = NO;
            swipeLabel.textColor = [UIColor redColor];
        }
        else if ([Config currentConfig].site == ConfigIFixit || [Config currentConfig].site == ConfigIFixitDev) {
            headerImageIFixit.hidden = NO;
        }
        // If this is a Dozuki site, we have no logo, so move the intro up to fill the space.
        else {
            CGRect frame = self.webView.frame;
            frame.origin.y -= 80.0;
            frame.size.height += 80.0;
            self.webView.frame = frame;
        }
    }
    
    // Hide the swipe label if there are no steps.
    if (![self.guide.steps count])
        swipeLabel.hidden = YES;
    
    UIColor *bgColor = [UIColor clearColor];

    self.view.backgroundColor = bgColor;
	webView.backgroundColor = bgColor;
    webView.opaque = NO;
	
	// Load the intro contents as HTML.
	NSString *header = [NSString stringWithFormat:@"<html><head><style type=\"text/css\"> %@ </style></head><body class=\"%@\">",
                        [Config currentConfig].introCSS,
                        (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? @"big" : @"small"];
	NSString *footer = @"</body></html>";

	NSString *body = self.guide.introduction_rendered;
   //NSString *body = guide.introduction;
	
    self.html = [NSString stringWithFormat:@"%@%@%@", header, body, footer];
	[webView loadHTMLString:html baseURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@", [Config host]]]];
    
    [self removeWebViewShadows];
    
	[device setText:self.guide.device];
    
    // Add a shadow to the image
    [self addViewShadow:mainImage];

    [mainImage setImageWithURL:[self.guide.image URLForSize:@"standard"] placeholderImage:nil];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType != UIWebViewNavigationTypeLinkClicked)
       return YES;
   
    // Load all URLs in popup browser.
    SVWebViewController *webViewController = [[SVWebViewController alloc] initWithAddress:[[request URL] absoluteString]];
    [self.delegate presentModalViewController:webViewController animated:YES];   
    [webViewController release];
    
    return NO;
}

// Because the web view has a white background, it starts hidden.
// After the content is loaded, we wait a small amount of time before showing it to prevent flicker.
- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[self performSelector:@selector(showWebView:) withObject:nil afterDelay:0.2];
}
- (void)showWebView:(id)sender {
	webView.hidden = NO;	
}

- (IBAction)zoomImage:(id)sender {
   
    // Disabled on the intro.
    return;

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}
- (void)layoutLandscape {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return;
    
    // These dimensions represent the object's position BEFORE rotation,
    // and are automatically tweaked during animation with respect to their resize masks.
    mainImage.frame = CGRectMake(40, 40, 200, 150);
    webView.frame = CGRectMake(240, 0, 238, 245);
}
- (void)layoutPortrait {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return;
    
    // These dimensions represent the object's position BEFORE rotation,
    // and are automatically tweaked during animation with respect to their resize masks.
    mainImage.frame = CGRectMake(60, 10, 200, 150);
    webView.frame = CGRectMake(0, 168, 320, 228);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        [self layoutLandscape];
    }
    else {
        [self layoutPortrait];
    }
    
    // Re-flow HTML
    [webView loadHTMLString:html baseURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@", [Config host]]]];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    self.headerImageIFixit = nil;
    self.headerImageMake = nil;
    self.swipeLabel = nil;
    self.device = nil;
    self.mainImage = nil;
    self.webView = nil;
    self.imageSpinner = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    webView.delegate = nil;
    
    [_guide release];
    [huge release];
    [html release];

    [headerImageIFixit release];
    [headerImageMake release];
    [swipeLabel release];
    [device release];
    [mainImage release];
    [webView release];
    [imageSpinner release];
    
    [super dealloc];
}


@end
