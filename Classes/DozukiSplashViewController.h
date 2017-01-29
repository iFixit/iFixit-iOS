//
//  DozukiSplashViewController.h
//  iFixit
//
//  Created by David Patierno on 8/16/11.
//  Copyright (c) 2011 iFixit. All rights reserved.
//

@interface DozukiSplashViewController : UIViewController <UINavigationControllerDelegate> {
    BOOL showingList;
}

@property (retain, nonatomic) IBOutlet UIView *introView;
@property (nonatomic, retain) UINavigationController *nextViewController;
@property (retain, nonatomic) IBOutlet UILabel *dozukiSlogan;
@property (retain, nonatomic) IBOutlet UILabel *dozukiDescription;
@property (retain, nonatomic) IBOutlet UILabel *getStarted;

- (IBAction)getStarted:(id)sender;

@end
