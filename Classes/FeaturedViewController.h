//
//  FeaturedViewController.h
//  iFixit
//
//  Created by David Patierno on 11/7/11.
//  Copyright (c) 2011 iFixit. All rights reserved.
//

#import "DMPGridViewDelegate.h"
#import "PastFeaturesViewDelegate.h"

@class PastFeaturesViewController;
@class DMPGridViewController;
@class WBProgressHUD;

@interface FeaturedViewController : UINavigationController <UIAlertViewDelegate, DMPGridViewDelegate, PastFeaturesViewDelegate>

@property (retain, nonatomic) UIPopoverController *poc;
@property (retain, nonatomic) PastFeaturesViewController *pvc;
@property (retain, nonatomic) DMPGridViewController *gvc;
@property (retain, nonatomic) NSDictionary *collection;
@property (retain, nonatomic) NSArray *guides;
@property (retain, nonatomic) WBProgressHUD *loading;

- (void)showPastFeatures:(id)sender;

@end
