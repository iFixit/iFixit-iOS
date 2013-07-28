//
//  GuideStepViewController.h
//  iFixit
//
//  Created by David Patierno on 8/7/10.
//  Copyright 2010 iFixit. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "GuideViewController.h"
#import "SDWebImageManager.h"

@class GuideStep;
@class GuideCatchingWebView;

@interface GuideStepViewController : UIViewController <UIWebViewDelegate, SDWebImageManagerDelegate>

@property (nonatomic, retain) id delegate;
@property (nonatomic, retain) GuideStep *step;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UIButton *mainImage;
@property (nonatomic, retain) IBOutlet GuideCatchingWebView *webView;
@property (nonatomic, retain) MPMoviePlayerController *moviePlayer;
@property (nonatomic, retain) UIWebView *embedView;
@property (nonatomic, retain) GuideViewController *guideViewController;

@property (nonatomic, retain) IBOutlet UIButton *image1;
@property (nonatomic, retain) IBOutlet UIButton *image2;
@property (nonatomic, retain) IBOutlet UIButton *image3;
@property (nonatomic) NSInteger numImagesLoaded;
@property (nonatomic, retain) NSString *html;

@property (nonatomic, retain) NSMutableDictionary *largeImages;

- (id)initWithStep:(GuideStep *)step;
- (IBAction)zoomImage:(id)sender;
- (IBAction)changeImage:(UIButton *)button;
- (void)startImageDownloads;
- (void)loadSecondaryImages;

- (void)layoutPortrait;
- (void)layoutLandscape;

@end
