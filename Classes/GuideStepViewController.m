    //
//  GuideStepViewController.m
//  iFixit
//
//  Created by David Patierno on 8/7/10.
//  Copyright 2010 iFixit. All rights reserved.
//

#import "GuideStepViewController.h"
#import "GuideImageViewController.h"
#import "GuideStep.h"
#import "GuideImage.h"
#import "Config.h"
#import "SDWebImageDownloader.h"
#import "UIButton+WebCache.h"
#import "SVWebViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation GuideStepViewController

@synthesize delegate, step=_step, titleLabel, mainImage, imageSpinner, webView;
@synthesize image1, image2, image3, numImagesLoaded, bigImages, html;

// Load the view nib and initialize the pageNumber ivar.
- (id)initWithStep:(GuideStep *)step {
    if ((self = [super initWithNibName:@"GuideStepView" bundle:nil])) {
        self.step = step;
        self.numImagesLoaded = 0;
        self.bigImages = [NSMutableArray array];
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
    view.layer.masksToBounds = NO;
    view.layer.shadowOffset = CGSizeMake(0.0, 1.0);
    view.layer.shadowRadius = 3.0;
    view.layer.shadowOpacity = 0.8;
    view.layer.shadowPath = [UIBezierPath bezierPathWithRect:view.bounds].CGPath;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ? 
        [self layoutLandscape] : [self layoutPortrait];

    UIColor *bgColor = [UIColor clearColor];
    
    self.view.backgroundColor = bgColor;
	webView.backgroundColor = bgColor;    
    webView.opaque = NO;

	NSString *stepTitle = [NSString stringWithFormat:@"Step %d", self.step.number];
	if (![self.step.title isEqual:@""])
		stepTitle = [NSString stringWithFormat:@"%@ - %@", stepTitle, self.step.title];
	
	[titleLabel setText:stepTitle];
    titleLabel.textColor = [Config currentConfig].textColor;

    // Load the step contents as HTML.
    NSString *header = [NSString stringWithFormat:@"<html><head><style type=\"text/css\"> %@ </style></head><body class=\"%@\"><ul>",
                        [Config currentConfig].stepCSS,
                        (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? @"big" : @"small"];
    NSString *footer = @"</ul></body></html>";
   
    NSMutableString *body = [NSMutableString stringWithString:@""];
    for (GuideStepLine *line in self.step.lines) {
        NSString *icon = @"";
        
        if ([line.bullet isEqual:@"icon_note"] || [line.bullet isEqual:@"icon_reminder"] || [line.bullet isEqual:@"icon_caution"]) {
            icon = [NSString stringWithFormat:@"<div class=\"bulletIcon bullet_%@\"></div>", line.bullet];
            line.bullet = @"black";
        }
        
       [body appendFormat:@"<li class=\"l_%d\"><div class=\"bullet bullet_%@\"></div>%@<p>%@</p><div style=\"clear: both\"></div></li>\n", line.level, line.bullet, icon, line.text];
    }
       
    self.html = [NSString stringWithFormat:@"%@%@%@", header, body, footer];
    [webView loadHTMLString:html baseURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@", [Config host]]]];
    
    [self removeWebViewShadows];
    
    // Add a shadow to the images
    [self addViewShadow:mainImage];
    [self addViewShadow:image1];
    [self addViewShadow:image2];
    [self addViewShadow:image3];
    
    [self startImageDownloads];
}

- (void)startImageDownloads {
    
    if ([self.step.images count] > 0) {
        [mainImage setImageWithURL:[[self.step.images objectAtIndex:0] URLForSize:@"large"]];
        
        if ([self.step.images count] > 1) {
            [image1 setImageWithURL:[[self.step.images objectAtIndex:0] URLForSize:@"thumbnail"]];
            image1.hidden = NO;
        }
    }
    
    if ([self.step.images count] > 1) {
        [image2 setImageWithURL:[[self.step.images objectAtIndex:1] URLForSize:@"thumbnail"]];
        image2.hidden = NO;
    }
    
    if ([self.step.images count] > 2) {
        [image3 setImageWithURL:[[self.step.images objectAtIndex:2] URLForSize:@"thumbnail"]];
        image3.hidden = NO;
    }
}

- (IBAction)changeImage:(UIButton *)button {
    GuideImage *guideImage = nil;
    
    if ([button isEqual:image1])
        guideImage = [self.step.images objectAtIndex:0];
    else if ([button isEqual:image2])
        guideImage = [self.step.images objectAtIndex:1];
    else if ([button isEqual:image3])
        guideImage = [self.step.images objectAtIndex:2];

    // Switch to the new image, but delay the spinner for a short time.
    imageSpinner.hidden = YES;
    [mainImage setImageWithURL:[guideImage URLForSize:@"large"]];
    [self performSelector:@selector(showImageSpinner) withObject:nil afterDelay:0.2];
}
- (void)showImageSpinner {
    imageSpinner.hidden = NO;
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
   	UIImage *image = [mainImage backgroundImageForState:UIControlStateNormal];
    if (!image)
        return;

    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
	// Create the image view controller and add it to the view hierarchy.
	GuideImageViewController *imageVC = [GuideImageViewController zoomWithUIImage:image delegate:self];
    [delegate presentModalViewController:imageVC animated:YES];
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
    CGRect frame = image1.frame;
    frame.origin.y = 170;
    
    frame.origin.x = 20;
    image1.frame = frame;
    
    frame.origin.x = 90;
    image2.frame = frame;
    
    frame.origin.x = 160;
    image3.frame = frame;
    
    webView.frame = CGRectMake(230, 0, 250, 245);
}
- (void)layoutPortrait {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return;
    
    // These dimensions represent the object's position BEFORE rotation,
    // and are automatically tweaked during animation with respect to their resize masks.
    CGRect frame = image1.frame;
    frame.origin.x = 238;
    
    frame.origin.y = 10;
    image1.frame = frame;
    
    frame.origin.y = 62;
    image2.frame = frame;
    
    frame.origin.y = 115;
    image3.frame = frame;
    
    webView.frame = CGRectMake(0, 168, 320, 225);
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
    self.titleLabel = nil;
    self.mainImage = nil;
    self.imageSpinner = nil;
    self.webView = nil;
    self.image1 = nil;
    self.image2 = nil;
    self.image3 = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [_step release];
    // TODO: Figure out why this crashes.
    //[bigImages release];
    [html release];
   
    webView.delegate = nil;
    
    [titleLabel release];
    [mainImage release];
    [imageSpinner release];
    [webView release];
    [image1 release];
    [image2 release];
    [image3 release];
   
    [super dealloc];
}


@end
