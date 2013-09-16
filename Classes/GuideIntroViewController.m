    //
//  GuideIntroViewController.m
//  iFixit
//
//  Created by David Patierno on 8/9/10.
//  Copyright 2010 iFixit. All rights reserved.
//

#import "GuideIntroViewController.h"
#import "GuideCatchingWebView.h"
#import "Guide.h"
#import "UIImageView+WebCache.h"
#import "Config.h"
#import "SVWebViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation GuideIntroViewController
@synthesize headerTextDozuki;

@synthesize delegate, headerImageLogo, swipeLabel;
@synthesize overlayView;
@synthesize guide=_guide;
@synthesize device, mainImage, webView, huge, html;

// Load the view nib and initialize the guide.
- (id)initWithGuide:(Guide *)guide {
    if ((self = [super initWithNibName:nil bundle:nil])) {
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

- (void)configureIntroTitleLogo {
    NSDictionary *siteInfo = [Config currentConfig].siteInfo;
    
    if (siteInfo[@"logo"] == [NSNull null] || !siteInfo[@"logo"][@"image"][@"large"]) {
        headerImageLogo.hidden = YES;
        headerTextDozuki.font = [UIFont fontWithName:@"Helvetica-Bold" size:75.0];
        headerTextDozuki.text = [[Config currentConfig].siteData valueForKey:@"title"];
        headerTextDozuki.hidden = NO;
    } else if (siteInfo[@"logo"][@"image"][@"large"]){
        headerImageLogo.contentMode = UIViewContentModeScaleAspectFit;
        [headerImageLogo setImageWithURL:[NSURL URLWithString:siteInfo[@"logo"][@"image"][@"large"]]];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    

    // Set the appropriate header image.
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        UIImage *image;
        switch ([Config currentConfig].site) {
            case ConfigMake:
                image = [UIImage imageNamed:@"logo_make.png"];
                headerImageLogo.frame = CGRectMake(headerImageLogo.frame.origin.x, headerImageLogo.frame.origin.y, image.size.width, image.size.height);
                headerImageLogo.image = image;
                break;
            case ConfigZeal:
                image = [UIImage imageNamed:@"logo_zeal@2x.png"];
                headerImageLogo.frame = CGRectMake(headerImageLogo.frame.origin.x, headerImageLogo.frame.origin.y, image.size.width, image.size.height);
                headerImageLogo.image = image;
                break;
            /*EAOGuideIntro*/
            case ConfigDozuki:
                [self configureIntroTitleLogo];
                break;
        }

    }
    
    // Hide the swipe label if there are no steps.
    if (![self.guide.steps count])
        swipeLabel.hidden = YES;
    
    UIColor *bgColor = [UIColor clearColor];
    
    if ([[Config currentConfig].backgroundColor isEqual:[UIColor whiteColor]]) {
        overlayView.backgroundColor = [UIColor whiteColor];
        overlayView.alpha = 0.3;
    }

    self.view.backgroundColor = bgColor;
    webView.modalDelegate = delegate;
    webView.backgroundColor = bgColor;
    webView.opaque = NO;
	
    // Load the intro contents as HTML.
    NSString *header = [NSString stringWithFormat:@"<html><head><style type=\"text/css\"> %@ </style></head><body class=\"%@\">",
                          [Config currentConfig].introCSS,
                          ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) ? @"big" : @"small"];
    NSString *footer = @"</body></html>";

    NSString *body = self.guide.introduction_rendered;
   //NSString *body = guide.introduction;
	
    self.html = [NSString stringWithFormat:@"%@%@%@", header, body, footer];
    [webView loadHTMLString:html baseURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@", [Config host]]]];
    
    [self removeWebViewShadows];
    
    [device setText:self.guide.category];
    
    // Add a shadow to the image
    [self addViewShadow:mainImage];

    [mainImage setImageWithURL:[self.guide.image URLForSize:@"standard"] placeholderImage:nil];
    
    swipeLabel.adjustsFontSizeToFitWidth = YES;
    swipeLabel.text = [NSString stringWithFormat:@" ←%@ ", NSLocalizedString(@"Swipe to Begin", nil)];
}

// Because the web view has a white background, it starts hidden.
// After the content is loaded, we wait a small amount of time before showing it to prevent flicker.
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self performSelector:@selector(showWebView:) withObject:nil afterDelay:0.2];
    [self.webView enableScrollingIfNeeded];
}
- (void)showWebView:(id)sender {
    [UIView transitionWithView:webView
                      duration:0.5f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        webView.hidden = NO;
                    } completion:nil];
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
    // iPad
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        swipeLabel.frame = CGRectMake(600.0, 563.0, 375.0, 84.0);
        webView.frame = CGRectMake(20.0, 160.0, 984.0, 395.0);
    }
    // iPhone
    else {
        CGRect frame = webView.frame;
        frame.size.height = 180;
        webView.frame = frame;
    }
}
- (void)layoutPortrait {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;

    // iPad
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        swipeLabel.frame = CGRectMake(340.0, 790.0, 375.0, 84.0);
        webView.frame = CGRectMake(20.0, 160.0, 728.0, 605.0);
    }
    // iPhone
    else {
        CGRect frame = webView.frame;
        frame.size.height = screenSize.height - 175;// 305;
        webView.frame = frame;
        swipeLabel.frame = CGRectMake(0.0, 0.0, 320.0, 45.0);
    }
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

- (void)viewDidUnload {
    [self setOverlayView:nil];
    [self setHeaderTextDozuki:nil];
    [self setSwipeLabel:nil];
    [super viewDidUnload];
    self.headerImageLogo = nil;
    self.swipeLabel = nil;
    self.device = nil;
    self.mainImage = nil;
    self.webView = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    webView.delegate = nil;
    
    [_guide release];
    [huge release];
    [html release];

    [headerImageLogo release];
    [swipeLabel release];
    [device release];
    [mainImage release];
    [webView release];
    
    [overlayView release];
    [headerTextDozuki release];
    [super dealloc];
}


@end
