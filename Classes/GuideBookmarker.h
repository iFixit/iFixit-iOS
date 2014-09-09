//
//  GuideBookmarker.h
//  iFixit
//
//  Created by David Patierno on 4/6/11.
//  Copyright 2011 iFixit. All rights reserved.
//

#import "LoginViewControllerDelegate.h"

@class Guide;
@class LoginViewController;

@interface GuideBookmarker : NSObject <LoginViewControllerDelegate> {
    UIViewController *delegate;
    NSNumber *guideid;
    
    UIPopoverController *poc;
    LoginViewController *lvc;
    
    UIProgressView *progress;
}

@property (nonatomic, assign) UIViewController *delegate;
@property (nonatomic, retain) NSNumber *guideid;

@property (nonatomic, retain) UIPopoverController *poc;
@property (nonatomic, retain) LoginViewController *lvc;

@property (nonatomic, retain) UIProgressView *progress;

- (void)setNewGuideId:(NSInteger)newGuideid;
- (void)bookmarked;

@end
