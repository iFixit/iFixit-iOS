//
//  GuideIntroViewController.h
//  iFixit
//
//  Created by David Patierno on 8/9/10.
//  Copyright 2010 iFixit. All rights reserved.
//

@class Guide;

@interface GuideIntroViewController : UIViewController <UIWebViewDelegate> {
	id delegate;
    UIImageView *headerImageIFixit;
    UIImageView *headerImageMake;
    UILabel *swipeLabel;
    
	Guide *guide;
	UILabel *device;
	UIButton *mainImage;
	UIWebView *webView;
	UIActivityIndicatorView *imageSpinner;
    UIImage *huge;
    NSString *html;
}

@property (nonatomic, retain) id delegate;
@property (nonatomic, retain) IBOutlet UIImageView *headerImageIFixit;
@property (nonatomic, retain) IBOutlet UIImageView *headerImageMake;
@property (nonatomic, retain) IBOutlet UILabel *swipeLabel;

@property (nonatomic, retain) Guide *guide;
@property (nonatomic, retain) IBOutlet UILabel *device;
@property (nonatomic, retain) IBOutlet UIButton *mainImage;
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *imageSpinner;
@property (nonatomic, retain) UIImage *huge;
@property (nonatomic, retain) NSString *html;

+ (id)initWithGuide:(Guide *)guide;

- (void)layoutPortrait;
- (void)layoutLandscape;

@end
