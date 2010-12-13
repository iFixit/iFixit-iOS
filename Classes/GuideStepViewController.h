//
//  GuideStepViewController.h
//  iFixit
//
//  Created by David Patierno on 8/7/10.
//  Copyright 2010 iFixit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CachedImageLoader.h"

@class GuideImageViewController;
@class GuideStep;

@interface GuideStepViewController : UIViewController <UIWebViewDelegate, ImageConsumer> {
	id delegate;
	GuideStep *step;
	
	UILabel *titleLabel;
	UIButton *mainImage;
	UIActivityIndicatorView *imageSpinner;
	UIActivityIndicatorView *textSpinner;
	UIWebView *webView;
	GuideImageViewController *imageVC;
    UIImage *image;
    
    UIButton *image1;
    UIButton *image2;
    UIButton *image3;
    NSInteger numImagesLoaded;
    NSMutableArray *bigImages;
}

@property (nonatomic, retain) id delegate;
@property (nonatomic, retain) GuideStep *step;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UIButton *mainImage;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *imageSpinner;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *textSpinner;
@property (nonatomic, retain) IBOutlet UIWebView *webView;

@property (nonatomic, retain) IBOutlet UIButton *image1;
@property (nonatomic, retain) IBOutlet UIButton *image2;
@property (nonatomic, retain) IBOutlet UIButton *image3;
@property (nonatomic) NSInteger numImagesLoaded;
@property (nonatomic, retain) NSMutableArray *bigImages;

@property (nonatomic, retain) GuideImageViewController *imageVC;
@property (nonatomic, retain) UIImage *image;

+ (id)initWithStep:(GuideStep *)step;
- (IBAction)zoomImage:(id)sender;
- (IBAction)changeImage:(UIButton *)button;
- (void)startImageDownloads;

@end
