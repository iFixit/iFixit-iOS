    //
//  GuideIntroViewController.m
//  iFixit
//
//  Created by David Patierno on 8/9/10.
//  Copyright 2010 iFixit. All rights reserved.
//

#import "GuideIntroViewController.h"
#import "Guide.h"
#import "GuideImageViewController.h"

@implementation GuideIntroViewController

@synthesize delegate, guide, device, mainImage, webView, textSpinner, imageSpinner, imageVC, huge;

static CGRect frameView;

// Load the view nib and initialize the guide.
+ (id)initWithGuide:(Guide *)guide {
	frameView = CGRectMake(0.0f,    0.0f, 1024.0f, 768.0f);

	GuideIntroViewController *vc = [[GuideIntroViewController alloc] initWithNibName:@"GuideIntroView" bundle:nil];
	
	vc.guide = guide;
   vc.huge = nil;
	
    return [vc autorelease];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	// Load the intro contents as HTML.
	NSString *header = @"<html><head><style type=\"text/css\"> html, body { background-color: black; color: white; font-family: \"Helvetica\", sans-serif; } a, a:visited { color: #aaf; } div.parts { margin-bottom: 20px; } </style></head><body><ul>";
	NSString *footer = @"</ul></body></html>";

	NSString *body = guide.introduction_rendered;
   //NSString *body = guide.introduction;
	
    NSString *html = [NSString stringWithFormat:@"%@%@%@", header, body, footer];
	[webView loadHTMLString:html baseURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@", IFIXIT_HOST]]];
	webView.backgroundColor = [UIColor blackColor];
    
	[device setText:guide.device];

    [[CachedImageLoader sharedImageLoader] addClientToDownloadQueue:self];

    // Disable bounce scrolling.
    for (id subview in webView.subviews)
        if ([[subview class] isSubclassOfClass:[UIScrollView class]])
            ((UIScrollView *)subview).bounces = NO;
}


- (NSURLRequest *)request {
    if (![guide.image.imageid intValue]) {
        [imageSpinner stopAnimating];
        return nil;
    }
    
    return [NSURLRequest requestWithURL:[guide.image URLForSize:@"standard"]];
}
- (void)renderImage:(UIImage *)image {
    // Use this instead of dispatch_async() for iOS 3.2 compatibility.
    [self performSelectorOnMainThread:@selector(renderImageOnMainThread:) withObject:image waitUntilDone:YES];
}

- (void)renderImageOnMainThread:(UIImage *)image {
    [mainImage setImage:image forState:UIControlStateNormal];
    mainImage.hidden = NO;
    [imageSpinner stopAnimating];
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {

   if (navigationType != UIWebViewNavigationTypeLinkClicked)
      return YES;
   
   // Load all URLs in Safari.
   [[UIApplication sharedApplication] openURL:[request URL]];
   return NO;
   
}

// Because the web view has a white background, it starts hidden.
// After the content is loaded, we wait a small amount of time before showing it to prevent flicker.
- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[self performSelector:@selector(showWebView:) withObject:nil afterDelay:0.3];
}
- (void)showWebView:(id)sender {
	[textSpinner stopAnimating];
	webView.hidden = NO;	
}

- (IBAction)zoomImage:(id)sender {
   
    // Disabled on the intro.
    return;

}
- (void)hideGuideImage:(id)object {
	[UIView beginAnimations:@"ImageView" context:nil];
	[UIView setAnimationDuration:0.3];
	mainImage.transform = CGAffineTransformMakeScale(1,1);
	imageVC.view.alpha = 0;
	[UIView commitAnimations];
    
    [self performSelector:@selector(removeImageVC) withObject:nil afterDelay:0.5];
}

- (void)removeImageVC {
    [imageVC.view removeFromSuperview];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    self.guide = nil;
    self.huge = nil;
    webView.delegate = nil;
    self.mainImage = nil;
    [super dealloc];
}


@end
