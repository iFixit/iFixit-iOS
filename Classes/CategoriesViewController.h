//
//  CategoriesViewController.h
//  iFixit
//
//  Created by David Patierno on 8/6/10.
//  Copyright iFixit 2010. All rights reserved.
//

#import "ListViewController.h"

@class DetailViewController;
@class ListViewController;

enum {
    Device,
    Category
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
@property (nonatomic) BOOL inPopover;

@property (nonatomic, retain) IBOutlet DetailViewController *detailViewController;
@property (nonatomic, retain) NSDictionary *categories;
@property (nonatomic, retain) NSArray *categoryTypes;
@property (nonatomic, retain) NSDictionary *categoryResults;
@property (nonatomic, retain) NSString *currentCategory;
@property (nonatomic, retain) ListViewController *listViewController;
@property (nonatomic, retain) NSString *moreInfoHTML;
@property (nonatomic, retain) NSDictionary *categoryMetaData;

@property BOOL showAnswers;

- (void)getAreas;
- (void)showLoading;
- (void)setData:(NSDictionary *)dict;

@end
