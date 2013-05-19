    //
//  GuideStepViewController.m
//  iFixit
//
//  Created by David Patierno on 8/7/10.
//  Copyright 2010 iFixit. All rights reserved.
//

#import "GuideStepViewController.h"

#import <QuartzCore/QuartzCore.h>

#import "ASIHTTPRequest.h"
#import "JSON.h"
#import "GuideImageViewController.h"
#import "GuideCatchingWebView.h"
#import "GuideStep.h"
#import "GuideImage.h"
#import "Config.h"
#import "SDWebImageDownloader.h"
#import "UIButton+WebCache.h"
#import "SVWebViewController.h"

@implementation GuideStepViewController

@synthesize delegate, step=_step, titleLabel, mainImage, webView, moviePlayer, embedView;
@synthesize image1, image2, image3, numImagesLoaded, bigImages, html;

// Load the view nib and initialize the pageNumber ivar.
- (id)initWithStep:(GuideStep *)step {
    if ((self = [super initWithNibName:nil bundle:nil])) {
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
    webView.modalDelegate = delegate;
    webView.backgroundColor = bgColor;    
    webView.opaque = NO;

    NSString *stepTitle = [NSString stringWithFormat:@"Step %d", self.step.number];
    if (![self.step.title isEqual:@""])
      stepTitle = [NSString stringWithFormat:@"%@ - %@", stepTitle, self.step.title];
	
    [titleLabel setText:stepTitle];
    titleLabel.textColor = [Config currentConfig].textColor;

    // Load the step contents as HTML.
    NSString *bodyClass = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) ? @"big" : @"small";
    if ([UIScreen mainScreen].scale == 2.0)
        bodyClass = [bodyClass stringByAppendingString:@" retina"];
    NSString *header = [NSString stringWithFormat:@"<html><head><style type=\"text/css\"> %@ </style></head><body class=\"%@\"><ul>",
                        [Config currentConfig].stepCSS,
                        bodyClass];
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
  
    // Images
    if (self.step.images) {
        // Add a shadow to the images
        [self addViewShadow:mainImage];
        [self addViewShadow:image1];
        [self addViewShadow:image2];
        [self addViewShadow:image3];
      
        [self startImageDownloads];
    }
    // Videos
    else if (self.step.video) {
        CGRect frame = mainImage.frame;
        frame.origin.x = 10.0;

        NSURL *url = [NSURL URLWithString:self.step.video.url];
        self.moviePlayer = [[[MPMoviePlayerController alloc] init] autorelease];
        moviePlayer.shouldAutoplay = NO;
        moviePlayer.contentURL = url;
        moviePlayer.controlStyle = MPMovieControlStyleEmbedded;
        moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
        // Play full screen on iPhones and iPods.
        moviePlayer.fullscreen = [UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad;
        [moviePlayer.view setFrame:frame];
        [moviePlayer prepareToPlay];
        [self.view addSubview:moviePlayer.view];
    }
    // Embeds
    else if (self.step.embed) {
        CGRect frame = mainImage.frame;
        frame.origin.x = 10.0;

        self.embedView = [[[UIWebView alloc] initWithFrame:frame] autorelease];
        self.embedView.backgroundColor = [UIColor clearColor];
        self.embedView.opaque = NO;
        [self.view addSubview:embedView];

        NSString *oembedURL = [NSString stringWithFormat:@"%@&maxwidth=%d&maxheight=%d",
                               self.step.embed.url,
                               (int)self.embedView.frame.size.width,
                               (int)self.embedView.frame.size.height];
        NSURL *url = [NSURL URLWithString:oembedURL];
        [ASIHTTPRequest requestWithURL:url];

        __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
        [request setCompletionBlock:^{
            NSDictionary *json = [[request responseString] JSONValue];
            NSString *embedHtml = [json objectForKey:@"html"];
            NSString *header = [NSString stringWithFormat:@"<html><head><style type=\"text/css\"> %@ </style></head><body>",
                                [Config currentConfig].stepCSS, nil];
            NSString *htmlString = [NSString stringWithFormat:@"%@ %@", header, embedHtml, nil];

            [embedView loadHTMLString:htmlString
                              baseURL:[NSURL URLWithString:[json objectForKey:@"provider_url"]]];
        }];
        [request startAsynchronous];
    }

    // Fix for rotation while playing video.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_moviePlayerWillExitFullscreen:)
                                                 name:MPMoviePlayerWillExitFullscreenNotification
                                               object:nil];

}

- (void)_moviePlayerWillExitFullscreen:(NSNotification *)notification {
  [self.delegate willRotateToInterfaceOrientation:self.interfaceOrientation duration:0];
}


- (void)viewWillDisappear:(BOOL)animated {
  [moviePlayer stop];
}

- (void)startImageDownloads {
    
    if ([self.step.images count] > 0) {
        [mainImage setImageWithURL:[[self.step.images objectAtIndex:0] URLForSize:@"large"] placeholderImage:[UIImage imageNamed:@"collectionsImagePlaceholder.png"]];
        
        if ([self.step.images count] > 1) {
            [image1 setImageWithURL:[[self.step.images objectAtIndex:0] URLForSize:@"thumbnail"] placeholderImage:[UIImage imageNamed:@"collectionsImagePlaceholder.png"]];
            image1.hidden = NO;
        }
    }
    
    if ([self.step.images count] > 1) {
        [image2 setImageWithURL:[[self.step.images objectAtIndex:1] URLForSize:@"thumbnail"] placeholderImage:[UIImage imageNamed:@"collectionsImagePlaceholder.png"]];
        image2.hidden = NO;
    }
    
    if ([self.step.images count] > 2) {
        [image3 setImageWithURL:[[self.step.images objectAtIndex:2] URLForSize:@"thumbnail"] placeholderImage:[UIImage imageNamed:@"collectionsImagePlaceholder.png"]];
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
    [mainImage setImageWithURL:[guideImage URLForSize:@"large"] placeholderImage:[UIImage imageNamed:@"collectionsImagePlaceholder.png"]];
}

// Because the web view has a white background, it starts hidden.
// After the content is loaded, we wait a small amount of time before showing it to prevent flicker.
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self performSelector:@selector(showWebView:) withObject:nil afterDelay:0.2];
    [self.webView enableScrollingIfNeeded];
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
    // iPad
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        mainImage.frame = CGRectMake(20.0, 103.0, 592.0, 444.0);
        webView.frame = CGRectMake(620.0, 103.0, 404.0, 562.0);
        titleLabel.frame = CGRectMake(30.0, 30.0, 975.0, 65.0);
        titleLabel.textAlignment = UITextAlignmentRight;

        CGRect frame = mainImage.frame;
        frame.origin.x = 10.0;
        moviePlayer.view.frame = frame;
        embedView.frame = frame;
      
        frame = image1.frame;
        frame.origin.y = 560.0;
        
        frame.origin.x = 20.0;
        image1.frame = frame;
        
        frame.origin.x = 173.0;
        image2.frame = frame;
        
        frame.origin.x = 326.0;
        image3.frame = frame;
    }
    // iPhone
    else {
        CGSize screenSize = [UIScreen mainScreen].bounds.size;

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
        
        webView.frame = CGRectMake(230, 0, screenSize.height - 230, 236);
    }
}
- (void)layoutPortrait {
    // iPad
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        mainImage.frame = CGRectMake(20.0, 30.0, 592.0, 444.0);
        webView.frame = CGRectMake(20.0, 554.0, 615.0, 380.0);
        titleLabel.frame = CGRectMake(30.0, 489.0, 708.0, 65.0);
        titleLabel.textAlignment = UITextAlignmentLeft;

        CGRect frame = mainImage.frame;
        frame.origin.x = 10.0;
        moviePlayer.view.frame = frame;
        embedView.frame = frame;

        frame = image1.frame;
        frame.origin.x = 626.0;
        
        frame.origin.y = 30.0;
        image1.frame = frame;
        
        frame.origin.y = 150.0;
        image2.frame = frame;
        
        frame.origin.y = 270.0;
        image3.frame = frame;
    }
    // iPhone
    else {
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
  
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
        
        webView.frame = CGRectMake(0, 168, 320, screenSize.height - 255);
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
    [super viewDidUnload];
    self.titleLabel = nil;
    self.mainImage = nil;
    self.webView = nil;
    self.moviePlayer = nil;
    self.embedView = nil;
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
    [webView release];
    [image1 release];
    [image2 release];
    [image3 release];
    [moviePlayer release];
    [embedView release];
  
    [[NSNotificationCenter defaultCenter] removeObserver:self];
  
    [super dealloc];
}


@end
