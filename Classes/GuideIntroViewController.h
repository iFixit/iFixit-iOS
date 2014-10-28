//
//  GuideIntroViewController.h
//  iFixit
//
//  Created by David Patierno on 8/9/10.
//  Copyright 2010 iFixit. All rights reserved.
//

#import "GuideViewController.h"

@class Guide;
@class GuideCatchingWebView;

@interface GuideIntroViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) IBOutlet UIImageView *headerImageLogo;
@property (retain, nonatomic) IBOutlet UILabel *headerTextDozuki;
@property (retain, nonatomic) IBOutlet UIView *overlayView;
@property (retain, nonatomic) IBOutlet UILabel *swipeLabel;

@property (nonatomic, retain) Guide *guide;
@property (nonatomic, retain) IBOutlet UILabel *device;
@property (nonatomic, retain) IBOutlet UIImageView *mainImage;
@property (nonatomic, retain) IBOutlet GuideCatchingWebView *webView;
@property (nonatomic, retain) UIImage *huge;
@property (nonatomic, retain) NSString *html;

- (id)initWithGuide:(Guide *)guide;

- (void)layoutPortrait;
- (void)layoutLandscape;

@end
