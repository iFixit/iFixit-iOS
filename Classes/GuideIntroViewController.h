//
//  GuideIntroViewController.h
//  iFixit
//
//  Created by David Patierno on 8/9/10.
//  Copyright 2010 iFixit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CachedImageLoader.h"

@class Guide;
@class GuideImageViewController;

@interface GuideIntroViewController : UIViewController <UIWebViewDelegate, ImageConsumer> {
	id delegate;
	Guide *guide;
	UILabel *device;
	UIButton *mainImage;
	UIWebView *webView;
	UIActivityIndicatorView *textSpinner;
	UIActivityIndicatorView *imageSpinner;
	GuideImageViewController *imageVC;
    UIImage *huge;
}

@property (nonatomic, retain) id delegate;
@property (nonatomic, retain) Guide *guide;
@property (nonatomic, retain) IBOutlet UILabel *device;
@property (nonatomic, retain) IBOutlet UIButton *mainImage;
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *textSpinner;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *imageSpinner;
@property (nonatomic, retain) GuideImageViewController *imageVC;
@property (nonatomic, retain) UIImage *huge;

+ (id)initWithGuide:(Guide *)guide;

@end
