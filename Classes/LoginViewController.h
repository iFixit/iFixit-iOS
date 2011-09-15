//
//  LoginViewController.h
//  iFixit
//
//  Created by David Patierno on 5/4/11.
//  Copyright 2011 iFixit. All rights reserved.
//

@class WBProgressHUD;
#import "LoginViewControllerDelegate.h"

@interface LoginViewController : UITableViewController <UITextFieldDelegate> {
    id<LoginViewControllerDelegate> delegate;
    NSString *message;
    WBProgressHUD *loading;
    BOOL showRegister;
    
    UITextField *emailField;
    UITextField *passwordField;
    UITextField *passwordVerifyField;
    UITextField *fullNameField;
    
    UIButton *loginButton;
    UIButton *registerButton;
    UIButton *cancelButton;
}

@property (nonatomic, assign) id<LoginViewControllerDelegate> delegate;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, retain) WBProgressHUD *loading;
@property (nonatomic) BOOL showRegister;

@property (nonatomic, retain) UITextField *emailField;
@property (nonatomic, retain) UITextField *passwordField;
@property (nonatomic, retain) UITextField *passwordVerifyField;
@property (nonatomic, retain) UITextField *fullNameField;

@property (nonatomic, retain) UIButton *loginButton;
@property (nonatomic, retain) UIButton *registerButton;
@property (nonatomic, retain) UIButton *cancelButton;

- (void)showLoading;
- (void)sendLogin;
- (void)sendRegister;

@end
