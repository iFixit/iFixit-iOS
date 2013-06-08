//
//  ListViewController.h
//  iFixit
//
//  Created by David Patierno on 3/24/11.
//  Copyright 2011. All rights reserved.
//

#import "CategoryWebViewController.h"
#import "CategoriesViewController.h"

@interface ListViewController : UINavigationController <UINavigationControllerDelegate, UINavigationBarDelegate>

@property (nonatomic, retain) UIViewController *bookmarksTVC;
@property (nonatomic, retain) UISegmentedControl *segmentedControl;
@property (nonatomic, retain) CategoryWebViewController *categoryInfoViewController;
@property (nonatomic, retain) CategoryWebViewController *categoryAnswersViewController;
@property (nonatomic, retain) id currentCategoryViewController;

@property int GUIDES;
@property int ANSWERS;
@property int MORE_INFO;

- (void)showFavoritesButton:(id)viewController;
- (void)favoritesButtonPushed;
- (void)buildSegmentedControl;

@end