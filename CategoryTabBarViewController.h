//
//  CategoryTabBarViewController.h
//  iFixit
//
//  Created by Stefan Ayala on 6/20/13.
//
//

#import <UIKit/UIKit.h>
#import "CategoryWebViewController.h"
#import "DetailGridViewController.h"
#import "ListViewController.h"
#import "CategoriesViewController.h"

@class CategoriesViewController;

@interface CategoryTabBarViewController : UITabBarController <UINavigationBarDelegate, UISplitViewControllerDelegate, UITabBarControllerDelegate>

// View controllers that our tab bar is going to reference

// iPad
@property (nonatomic, retain) DetailGridViewController *detailGridViewController;
@property (nonatomic, retain) UIPopoverController *popOverController;
@property (nonatomic, retain) UIButton *browseButton;

// iPhone
@property (nonatomic, retain) CategoriesViewController *categoriesViewController;
@property (nonatomic, retain) ListViewController *listViewController;

// Both
@property (nonatomic, retain) CategoryWebViewController *categoryMoreInfoViewController;
@property (nonatomic, retain) CategoryWebViewController *categoryAnswersWebViewController;
@property (nonatomic, retain) NSMutableArray *tabBarViewControllers;

@property (nonatomic, retain) NSDictionary *categoryMetaData;
@property (nonatomic, retain) UIImageView *toolBarFillerImage;

// Integers to be used as constants
@property int GUIDES;
@property int ANSWERS;
@property int MORE_INFO;

- (void)updateTabBar:(NSDictionary *)results;
- (void)enableTabBarItems:(BOOL)option;
- (void)showTabBar:(BOOL)option;
- (void)configureSubViewFrame:(int)viewControllerIndex;
- (void)gotCategoryResult:(NSDictionary *)results;
- (void)reflowLayout:(UIInterfaceOrientation)orientation;
- (void)hideBrowseInstructions:(BOOL)option;

@end
