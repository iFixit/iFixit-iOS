//
//  DozukiSelectSiteViewController.h
//  iFixit
//
//  Created by David Patierno on 8/16/11.
//  Copyright (c) 2011 iFixit. All rights reserved.
//

@interface DozukiSelectSiteViewController : UITableViewController <UIAlertViewDelegate> {
    NSMutableArray *sites;
    BOOL loading;
    BOOL hasMoreSites;
}

@property (nonatomic, retain) NSMutableArray *sites;

- (void)showLoading;

@end
