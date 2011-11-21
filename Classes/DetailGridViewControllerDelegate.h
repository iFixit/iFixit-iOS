//
//  DetailGridViewControllerDelegate.h
//  iFixit
//
//  Created by David Patierno on 11/21/11.
//  Copyright (c) 2011 iFixit. All rights reserved.
//

@class DetailGridViewController;

@protocol DetailGridViewControllerDelegate <NSObject>

// Talk back to our container so it can hide this view if no guides exist.
- (void)detailGrid:(DetailGridViewController *)detailGrid gotGuideCount:(NSInteger)count;

@end
