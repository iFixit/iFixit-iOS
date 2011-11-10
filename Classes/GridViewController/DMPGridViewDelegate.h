//
//  DMPGridViewDelegate.h
//  DMPGridViewController
//
//  Created by David Patierno on 11/7/11.
//  Copyright (c) 2011. All rights reserved.
//

@class DMPGridViewController;

@protocol DMPGridViewDelegate <UITableViewDelegate>

- (NSString *)gridViewController:(DMPGridViewController *)gridViewController titleForCellAtIndex:(NSUInteger)index;
- (NSInteger)numberOfCellsForGridViewController:(DMPGridViewController *)gridViewController;
- (void)gridViewController:(DMPGridViewController *)gridViewController tappedCellAtIndex:(NSUInteger)index;

@optional
- (NSString *)gridViewController:(DMPGridViewController *)gridViewController imageURLForCellAtIndex:(NSUInteger)index;
- (UIImage *)gridViewController:(DMPGridViewController *)gridViewController imageForCellAtIndex:(NSUInteger)index;

@end
