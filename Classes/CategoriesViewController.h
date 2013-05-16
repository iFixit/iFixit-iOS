//
//  CategoriesViewController.h
//  iFixit
//
//  Created by David Patierno on 8/6/10.
//  Copyright iFixit 2010. All rights reserved.
//

@class DetailViewController;

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

- (void)getAreas;
- (void)showLoading;
- (void)setData:(NSDictionary *)dict;

@end
