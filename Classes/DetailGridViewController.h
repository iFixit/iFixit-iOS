//
//  DetailGridViewController.h
//  iFixit
//
//  Created by David Patierno on 11/15/11.
//  Copyright (c) 2011 iFixit. All rights reserved.
//

#import "DMPGridViewController.h"
#import "DMPGridViewDelegate.h"
#import "DetailGridViewControllerDelegate.h"

@class WBProgressHUD;

@interface DetailGridViewController : DMPGridViewController <DMPGridViewDelegate>

@property (nonatomic, copy) NSString *category;
@property (retain, nonatomic) NSArray *guides;
@property (retain, nonatomic) WBProgressHUD *loading;
@property (nonatomic) UIInterfaceOrientation orientationOverride;
@property (nonatomic, retain) UIImageView *noGuidesImage;
@property (nonatomic, retain) UIImageView *fistImage;
@property (nonatomic, retain) UIImageView *guideArrow;
@property (nonatomic, retain) UIImageView *siteLogo;
@property (nonatomic, retain) UIImageView *backgroundView;

@property (nonatomic, retain) UILabel *browseInstructions;
@property (nonatomic, retain) UILabel *dozukiTitleLabel;

@property (nonatomic, assign) id<DetailGridViewControllerDelegate> gridDelegate;

- (void)showNoGuidesImage:(BOOL)option;
- (void)configureDozukiTitleLabel;
- (void)configureSiteLogoFromURL:(NSString*)url;
    
@end
