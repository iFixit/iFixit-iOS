//
//  DozukiInfoViewController.h
//  iFixit
//
//  Created by David Patierno on 8/16/11.
//  Copyright (c) 2011 iFixit. All rights reserved.
//

@class DozukiSelectSiteViewController;

@interface DozukiInfoViewController : UIViewController

@property (nonatomic, retain) DozukiSelectSiteViewController *dssvc;

- (void)showList;

@end
