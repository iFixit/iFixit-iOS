//
//  FeaturedViewController.h
//  iFixit
//
//  Created by David Patierno on 11/7/11.
//  Copyright (c) 2011 iFixit. All rights reserved.
//

#import "PastFeaturesViewDelegate.h"

@class DMPGridViewController;
@class PastFeaturesViewController;
@class DMPGridViewController;
@class WBProgressHUD;

@protocol DMPGridViewDelegate <UITableViewDelegate>

- (NSString *)gridViewController:(DMPGridViewController *)gridViewController titleForCellAtIndex:(NSInteger)index;
- (NSInteger)numberOfCellsForGridViewController:(DMPGridViewController *)gridViewController;
- (void)gridViewController:(DMPGridViewController *)gridViewController tappedCellAtIndex:(NSInteger)index;

@optional
- (NSURL *)gridViewController:(DMPGridViewController *)gridViewController imageURLForCellAtIndex:(NSInteger)index;
- (UIImage *)gridViewController:(DMPGridViewController *)gridViewController imageForCellAtIndex:(NSInteger)index;
    
@end

@interface FeaturedViewController : UINavigationController <UIAlertViewDelegate, DMPGridViewDelegate, PastFeaturesViewDelegate>

@property (retain, nonatomic) UIPopoverController *poc;
@property (retain, nonatomic) PastFeaturesViewController *pvc;
@property (retain, nonatomic) DMPGridViewController *gvc;
@property (retain, nonatomic) NSDictionary *collection;
@property (retain, nonatomic) NSArray *guides;
@property (retain, nonatomic) WBProgressHUD *loading;

- (void)showPastFeatures:(id)sender;

@end
