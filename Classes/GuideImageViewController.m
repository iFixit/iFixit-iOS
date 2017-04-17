    //
//  GuideImageViewController.m
//  iFixit
//
//  Created by David Patierno on 8/14/10.
//  Copyright 2010 iFixit. All rights reserved.
//

#import "GuideImageViewController.h"
#import "Config.h"

@interface GuideImageViewController (UtilityMethods)
- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center;
@end


@implementation GuideImageViewController

@synthesize delegate, image, imageScrollView, imageView, delay;

static CGRect frameView;

- (void)detectOrientation {
    if ([delegate view].frame.size.width > 400.0)
        frameView = CGRectMake(0.0f, 0.0f, 480.0f, 320.0f);
    else
        frameView = CGRectMake(0.0f, 0.0f, 320.0f, 480.0f);

    self.view.frame = frameView;
}

- (id)initWithUIImage:(UIImage *)i delegate:(id)d {
    if ((self = [super init])) {
        self.image = i;
        self.delegate = d;
    }
    return self;
}

+ (id)zoomWithUIImage:(UIImage *)image delegate:(id)delegate {
	GuideImageViewController *vc = [[GuideImageViewController alloc] initWithUIImage:image delegate:delegate];
    vc.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;

    [vc setWantsFullScreenLayout:YES];

    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        frameView = CGRectMake(0.0f, 0.0f, 1024.0f, 748.0f);
        vc.view.frame = frameView;        
    }
    else {
        [vc detectOrientation];
    }
    
    return [vc autorelease];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // iPad.
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        return YES;
    
    // iPhone Portrait+Landscape.
    return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [[delegate delegate] willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [imageScrollView setZoomScale:1.0 animated:YES];
    imageView.frame = imageScrollView.frame;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [imageScrollView setZoomScale:1.0 animated:YES];
}

- (void)loadView {
    [super loadView];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];

    // set up main scroll view
	self.imageScrollView = [[[UIScrollView alloc] initWithFrame:self.view.bounds] autorelease];
    imageScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [imageScrollView setBackgroundColor:[Config currentConfig].backgroundColor];
    [imageScrollView setDelegate:self];
    [imageScrollView setBouncesZoom:YES];
    [imageScrollView setMaximumZoomScale:2.0];
    [self.view addSubview:imageScrollView];
	[self.view sendSubviewToBack:imageScrollView];

    // add touch-sensitive image view to the scroll view
	self.imageView = [[[UIImageView alloc] initWithFrame:imageScrollView.bounds] autorelease];
    imageView.image = self.image;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [imageView setUserInteractionEnabled:YES];
	[imageScrollView addSubview:imageView];
   
    [self setupTouchEvents];
    
    self.delay = [NSDate date];
    
    // Show the x icon.
    CGRect backFrame = CGRectMake(5, 5, 50, 50);
    UIImage *x = [UIImage imageNamed:@"x-icon.png"];
    UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
    back.alpha = 0.4;
    [back setBackgroundImage:x forState:UIControlStateNormal];
    back.userInteractionEnabled = NO;
    //[back addTarget:delegate action:@selector(hideGuideImage:) forControlEvents:UIControlEventTouchUpInside];
    back.frame = backFrame;
    [self.view addSubview:back];
       
}
- (void)setupTouchEvents {
   
   // add gesture recognizers to the image view
   UITapGestureRecognizer *singleTapG = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
   UITapGestureRecognizer *doubleTapG = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
   UITapGestureRecognizer *twoFingerTapG = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoFingerTap:)];
   
   [doubleTapG setNumberOfTapsRequired:2];
   [twoFingerTapG setNumberOfTouchesRequired:2];
   
   [imageView addGestureRecognizer:singleTapG];
   [imageView addGestureRecognizer:doubleTapG];
   [imageView addGestureRecognizer:twoFingerTapG];
   
   [singleTapG release];
   [doubleTapG release];
   [twoFingerTapG release];
   
}

- (void)dealloc {
    [image release];
    [imageScrollView release];
    [imageView release];
    [delay release];
    
    [super dealloc];
}

#pragma mark UIScrollViewDelegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return imageView;
}

#pragma mark TapDetectingImageViewDelegate methods

- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer {

   if ([delay timeIntervalSinceNow] > -0.5)
      return;
   
	doubleTap = NO;
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[NSThread sleepForTimeInterval:0.25];

		if (!doubleTap) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] setStatusBarHidden:NO];
                [[delegate delegate] dismissModalViewControllerAnimated:YES];
            });
        }
		
	});
}

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer {
	doubleTap = YES;
	
    // double tap zooms in and out
	float newScale;
	if ([imageScrollView zoomScale] == [imageScrollView minimumZoomScale]) {
		newScale = 2.0;
	} else {
		newScale = [imageScrollView minimumZoomScale];
	}
	
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
    [imageScrollView zoomToRect:zoomRect animated:YES];
}

- (void)handleTwoFingerTap:(UIGestureRecognizer *)gestureRecognizer {
    // two-finger tap zooms out
    float newScale = [imageScrollView minimumZoomScale];
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
    [imageScrollView zoomToRect:zoomRect animated:YES];
}

#pragma mark Utility methods

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    // the zoom rect is in the content view's coordinates. 
    //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = [imageScrollView frame].size.height / scale;
    zoomRect.size.width  = [imageScrollView frame].size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

@end
