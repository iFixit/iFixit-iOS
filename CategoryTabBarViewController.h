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
#import "MGSplitViewController.h"

@class CategoriesViewController;

@interface CategoryTabBarViewController : UITabBarController <UINavigationBarDelegate, MGSplitViewControllerDelegate, UITabBarControllerDelegate>

// View controllers that our tab bar is going to reference

// iPad
@property (nonatomic, retain, nullable)  DetailGridViewController *detailGridViewController;
@property (nonatomic, retain, nullable) UIPopoverController *popOverController;
@property (nonatomic, retain, nullable) UIButton *browseButton;

// iPhone
@property (nonatomic, retain, nullable) CategoriesViewController *categoriesViewController;
@property (nonatomic, retain, nullable) ListViewController *listViewController;

// Both
@property (nonatomic, retain, nullable) CategoryWebViewController *categoryMoreInfoViewController;
@property (nonatomic, retain, nullable) CategoryWebViewController *categoryAnswersWebViewController;
@property (nonatomic, retain, nullable) NSMutableArray *tabBarViewControllers;

@property (nonatomic, retain, nullable) NSDictionary *categoryMetaData;
@property (nonatomic, retain, nullable) UIImageView *toolBarFillerImage;

// Integers to be used as constants
@property int GUIDES;
@property int ANSWERS;
@property int MORE_INFO;

- (void)updateTabBar:(nonnull NSDictionary *)results;
- (void)enableTabBarItems:(BOOL)option;
- (void)showTabBar:(BOOL)option;
- (void)configureSubViewFrame:(int)viewControllerIndex;
- (void)gotCategoryResult:(nonnull NSDictionary *)results;
- (void)reflowLayout:(UIInterfaceOrientation)orientation;
- (void)hideBrowseInstructions:(BOOL)option;
- (void)gotSiteInfoResults:(nullable NSDictionary *)results;

@end
