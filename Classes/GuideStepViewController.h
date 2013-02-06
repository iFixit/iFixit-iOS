//
//  GuideStepViewController.h
//  iFixit
//
//  Created by David Patierno on 8/7/10.
//  Copyright 2010 iFixit. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

@class GuideStep;
@class GuideCatchingWebView;

@interface GuideStepViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) GuideStep *step;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UIButton *mainImage;
@property (nonatomic, retain) IBOutlet GuideCatchingWebView *webView;
@property (nonatomic, retain) MPMoviePlayerController *moviePlayer;
@property (nonatomic, retain) UIWebView *embedView;

@property (nonatomic, retain) IBOutlet UIButton *image1;
@property (nonatomic, retain) IBOutlet UIButton *image2;
@property (nonatomic, retain) IBOutlet UIButton *image3;
@property (nonatomic) NSInteger numImagesLoaded;
@property (nonatomic, retain) NSMutableArray *bigImages;
@property (nonatomic, retain) NSString *html;

- (id)initWithStep:(GuideStep *)step;
- (IBAction)zoomImage:(id)sender;
- (IBAction)changeImage:(UIButton *)button;
- (void)startImageDownloads;

- (void)layoutPortrait;
- (void)layoutLandscape;

@end
