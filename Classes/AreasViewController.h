//
//  AreasViewController.h
//  iFixit
//
//  Created by David Patierno on 8/6/10.
//  Copyright iFixit 2010. All rights reserved.
//

@class DetailViewController;

@interface AreasViewController : UITableViewController <UISearchBarDelegate, UIAlertViewDelegate, UITextFieldDelegate>

@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property BOOL searching;
@property (nonatomic, retain) NSArray *searchResults;

@property (nonatomic, retain) IBOutlet DetailViewController *detailViewController;
@property (nonatomic, retain) NSDictionary *data;
@property (nonatomic, retain) NSMutableDictionary *tree;
@property (nonatomic, retain) NSArray *keys;
@property (nonatomic, retain) NSArray *leafs;

- (void)getAreas;
- (void)showLoading;
- (void)setData:(NSDictionary *)dict;

@end
