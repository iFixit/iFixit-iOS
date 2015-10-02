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

@property (nonatomic, retain) CategoryTabBarViewController *categoryTabBarViewController;
@property (nonatomic, retain) UIBarButtonItem *favoritesButton;

- (void)showFavoritesButton:(id)viewController;
- (void)favoritesButtonPushed;

- (void)configureProperties;

@end