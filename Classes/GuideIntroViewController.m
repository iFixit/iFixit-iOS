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
#import "iFixitAppDelegate.h"
#import "iFixitAPI.h"
#import "User.h"

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
            case ConfigMjtrim:
                image = [UIImage imageNamed:@"mjtrim_logo_transparent.png"];
                headerImageLogo.frame = CGRectMake(headerImageLogo.frame.origin.x, headerImageLogo.frame.origin.y, image.size.width, image.size.height);
                headerImageLogo.image = image;
                break;
            case ConfigAccustream:
                headerImageLogo.image = [UIImage imageNamed:@"accustream_logo_transparent.png"];
                break;
            case ConfigMagnolia:
                image = [UIImage imageNamed:@"magnoliamedical_logo_transparent.png"];
                headerImageLogo.frame = CGRectMake(headerImageLogo.frame.origin.x, headerImageLogo.frame.origin.y, image.size.width/1.5, image.size.height/1.5);
                headerImageLogo.image = image;
                break;
            case ConfigComcast:
                image = [UIImage imageNamed:@"comcast_logo_transparent.png"];
                headerImageLogo.frame = CGRectMake(headerImageLogo.frame.origin.x, headerImageLogo.frame.origin.y - 30, image.size.width/2, image.size.height/2);
                headerImageLogo.image = image;
                break;
            case ConfigDripAssist:
                image = [UIImage imageNamed:@"dripassist_logo_transparent.png"];
                headerImageLogo.frame = CGRectMake(headerImageLogo.frame.origin.x, headerImageLogo.frame.origin.y, image.size.width/2, image.size.height/2);
                headerImageLogo.image = image;
                break;
            case ConfigPva:
                image = [UIImage imageNamed:@"pva_logo_transparent.png"];
                headerImageLogo.frame = CGRectMake(headerImageLogo.frame.origin.x, headerImageLogo.frame.origin.y, image.size.width/2, image.size.height/2);
                headerImageLogo.image = image;
                break;
            case ConfigOscaro:
                image = [UIImage imageNamed:@"oscaro_logo_transparent.png"];
                headerImageLogo.frame = CGRectMake(headerImageLogo.frame.origin.x, headerImageLogo.frame.origin.y, image.size.width/2, image.size.height/2);
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
    
    if ([Config currentConfig].buttonColor) {
        self.navigationItem.rightBarButtonItem.tintColor = self.navigationItem.leftBarButtonItem.tintColor = [Config currentConfig].buttonColor;
    }
    
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

    NSString *docsHtml = [self buildHtmlForDocs:self.guide.documents];
    NSString *partsHtml = [self buildHtmlForItems:self.guide.parts fromType:@"part"];
    NSString *toolsHtml = [self buildHtmlForItems:self.guide.tools fromType:@"tool"];
    
    NSString *body = [NSString stringWithFormat:@"%@%@%@%@", self.guide.introduction_rendered, docsHtml, partsHtml, toolsHtml];
	
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

- (NSString*)buildHtmlForDocs:(NSMutableArray*)docs {
    // Return an empty string if no docs are found
    if (![docs count]) {
        return @"";
    }
    
    NSString *html = [NSString stringWithFormat:@"<div class=\"files\"><strong>Files</strong><ul>"];
    
    for (id doc in docs) {
        // We cannot display offline pdfs in our current
        // Guide Intro view because it's full of Webviews. When we make a
        // pretty native view, we can enable offline documents.
        NSString *docUrl = [NSString stringWithFormat:@"%@", doc[@"download_url"]];
        html = [html stringByAppendingString:[NSString stringWithFormat:@"<li><a href=\"%@\">%@</a></li>",
                                              docUrl, doc[@"text"]]];
    }
    
    return [html stringByAppendingString:[NSString stringWithFormat:@"</ul></div>"]];
}

// Temporary method to build html for parts/tools, remove when we implement a native view
- (NSString*)buildHtmlForItems:(NSMutableArray*)items fromType:(NSString*)itemType {
    
    // Return an empty string if we have no items
    if (![items count]) {
        return @"";
    }
    
    NSString *html = [NSString stringWithFormat:@"<div class=\"%@s\"><strong>%@s</strong><ul>", itemType, [itemType capitalizedString]];
    
    for (id item in items) {
        html = [html stringByAppendingString:[NSString stringWithFormat:@"<li><a href=\"%@\">%@ x %@</a></li>",
                                              item[@"url"], item[@"quantity"], item[@"text"]]];
    }
    
    return [html stringByAppendingString:[NSString stringWithFormat:@"</ul></div>"]];
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
        webView.frame = CGRectMake(0.0, 20, webView.frame.size.width, screenSize.height - 175); // 305
        swipeLabel.frame = CGRectMake(0.0, 0.0, 320.0, 45.0);
    }
}

- (NSString*)getOfflineDocumentPath:(NSMutableDictionary*) guideDocument {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDirectory = paths[0];
    
    NSString *filePath = [docDirectory stringByAppendingPathComponent:
                          [NSString stringWithFormat:@"/Documents/%@_%@_%@.pdf", [iFixitAPI sharedInstance].user.iUserid, self.guide.iGuideid, guideDocument[@"documentid"]]];
    return [[NSURL fileURLWithPath:filePath] absoluteString];
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
}


@end
