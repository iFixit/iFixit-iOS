//
//  CategoriesViewController.h
//  iFixit
//
//  Created by David Patierno on 8/6/10.
//  Copyright iFixit 2010. All rights reserved.
//

#import "ListViewController.h"
#import "CategoryTabBarViewController.h"

@class DetailViewController;
@class ListViewController;

enum {
    DEVICE,
    CATEGORY,
    GUIDE
};

#define TOPICS @"TOPICS"
#define CATEGORIES @"categories"
#define DEVICES @"devices"

@interface CategoriesViewController : UITableViewController <UISearchBarDelegate, UIAlertViewDelegate, UITextFieldDelegate>

@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property BOOL searching;
@property (nonatomic, retain) NSArray *searchResults;
@property (nonatomic) BOOL noResults;

@property (nonatomic, retain) NSMutableDictionary *categories;
@property (nonatomic, retain) NSMutableArray *categoryTypes;
@property (nonatomic, retain) NSDictionary *categoryResults;
@property (nonatomic, retain) ListViewController *listViewController;
@property (nonatomic, retain) NSDictionary *categoryMetaData;

- (void)getAreas;
- (void)showLoading;
- (void)setData:(NSDictionary *)dict;
- (void)addGuidesToTableView:(NSArray*)guides;

@end
