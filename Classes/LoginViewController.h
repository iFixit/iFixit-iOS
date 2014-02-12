//
//  LoginViewController.h
//  iFixit
//
//  Created by David Patierno on 5/4/11.
//  Copyright 2011 iFixit. All rights reserved.
//

@class WBProgressHUD;
@class ListViewController;
#import "LoginViewControllerDelegate.h"

@interface LoginViewController : UITableViewController <UITextFieldDelegate, UIGestureRecognizerDelegate, LoginViewControllerDelegate>

@property (nonatomic, assign) id<LoginViewControllerDelegate> delegate;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, retain) WBProgressHUD *loading;
@property (nonatomic) BOOL showRegister;
@property (nonatomic) BOOL modal;

@property (nonatomic, retain) UITextField *emailField;
@property (nonatomic, retain) UITextField *passwordField;
@property (nonatomic, retain) UITextField *passwordVerifyField;
@property (nonatomic, retain) UITextField *fullNameField;
@property (nonatomic, retain) ListViewController *listViewController;

@property (nonatomic, retain) UIButton *loginButton;
@property (nonatomic, retain) UIButton *registerButton;
@property (nonatomic, retain) UIButton *cancelButton;
@property (nonatomic, retain) UIButton *googleButton;
@property (nonatomic, retain) UIButton *yahooButton;

- (void)showLoading;
- (void)sendLogin;
- (void)sendRegister;
- (void)refresh;

@end
