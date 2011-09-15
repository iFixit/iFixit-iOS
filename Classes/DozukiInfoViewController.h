//
//  DozukiInfoViewController.h
//  iFixit
//
//  Created by David Patierno on 8/16/11.
//  Copyright (c) 2011 iFixit. All rights reserved.
//

@class DozukiSelectSiteViewController;

@interface DozukiInfoViewController : UIViewController  {
    DozukiSelectSiteViewController *dssvc;
    IBOutlet UILabel *titleLabel;
    IBOutlet UILabel *textLabel;
    IBOutlet UIButton *getStartedButton;
}

@property (nonatomic, retain) DozukiSelectSiteViewController *dssvc;

- (IBAction)getStarted:(id)sender;
- (void)showList;

@end
