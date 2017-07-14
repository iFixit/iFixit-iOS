//
//  CategoriesViewController.h
//  iFixit
//
//  Created by David Patierno on 8/6/10.
//  Copyright iFixit 2010. All rights reserved.
//

#import "ListViewController.h"
#import "CategoryTabBarViewController.h"
#import <ZBarReaderController.h>

@class ListViewController;

enum {
    DEVICE,
    CATEGORY,
    GUIDE,
    WIKI
};

#define TOPICS @"TOPICS"
#define CATEGORIES @"categories"
#define DEVICES @"devices"

@interface CategoriesViewController : UIViewController <UISearchBarDelegate, UIAlertViewDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, ZBarReaderDelegate>

@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (retain, nonatomic) IBOutlet UIView *scannerBarView;
@property (retain, nonatomic) IBOutlet UIImageView *scannerIcon;
@property (retain, nonatomic) IBOutlet UITableView *tableView;

@property BOOL searching;

@property (nonatomic, retain) NSMutableDictionary *searchResults;
@property (nonatomic) BOOL noResults;
@property (nonatomic, retain) NSString *currentSearchTerm;

@property (nonatomic, retain) NSMutableDictionary *categories;
@property (nonatomic, retain) NSMutableArray *categoryTypes;
@property (nonatomic, retain) NSDictionary *categoryResults;
@property (nonatomic, retain) ListViewController *listViewController;
@property (nonatomic, retain) NSDictionary *categorySearchResult;
@property (nonatomic, retain) NSDictionary *categoryMetaData;

- (void)getAreas;
- (void)showLoading;
- (void)setData:(NSDictionary *)dict;
- (void)addGuidesToTableView:(NSArray*)guides;
- (void)addWikisToTableView:(NSArray*)wikis;
- (void)setTableViewTitle;
- (void)configureTableViewTitleLogoFromURL:(NSString*)URL;
- (void)configureSearchBar;
    
@end
