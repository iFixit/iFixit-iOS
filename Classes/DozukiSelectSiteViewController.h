//
//  DozukiSelectSiteViewController.h
//  iFixit
//
//  Created by David Patierno on 8/16/11.
//  Copyright (c) 2011 iFixit. All rights reserved.
//

@interface DozukiSelectSiteViewController : UITableViewController <UIAlertViewDelegate, UISearchBarDelegate> {
    BOOL loading;
    BOOL hasMoreSites;
    BOOL searching;
    BOOL noResults;
}

@property (retain, nonatomic) UISearchBar *searchBar;
@property (nonatomic, retain) NSMutableArray *searchResults;
@property (nonatomic) BOOL simple;

- (id)initWithSimple:(BOOL)simple_;
- (void)showLoading;

@end
