//
//  LoginViewController.m
//  iFixit
//
//  Created by David Patierno on 5/4/11.
//  Copyright 2011 iFixit. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginBackgroundViewController.h"
#import "WBProgressHUD.h"
#import "iFixitAPI.h"
#import "BookmarksViewController.h"
#import "Config.h"
#import "OpenIDViewController.h"
#import "SSOViewController.h"

@implementation LoginViewController

@synthesize delegate, message, loading, showRegister, modal;
@synthesize emailField, passwordField, passwordVerifyField, fullNameField;
@synthesize loginButton, registerButton, cancelButton, googleButton, yahooButton;

- (id)init {
    if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
        // Custom initialization
        self.delegate = nil;
        self.loading = nil;
        self.message = @"Favorites are synced across devices and saved locally for offline browsing. Please login or register to access this feature.";
        showRegister = NO;
        self.emailField = nil;
        self.passwordField = nil;
        self.passwordVerifyField = nil;
        self.fullNameField = nil;
        self.loginButton = nil;
        self.registerButton = nil;
        self.cancelButton = nil;
    }
    return self;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [UIView beginAnimations:@"repositionForm" context:nil];
    [UIView setAnimationDuration:0.3];
    self.tableView.contentInset = UIEdgeInsetsMake(-60, 0, 0, 0);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 215, 0);
    [self.tableView scrollRectToVisible:CGRectMake(0.0, 60.0, 320.0, 100.0) animated:YES];
    [UIView commitAnimations];
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self performSelector:@selector(showMessage) withObject:nil afterDelay:0.1];
}
- (void)showMessage {
    if ([emailField isFirstResponder] || [passwordField isFirstResponder] || 
        [passwordVerifyField isFirstResponder] || [fullNameField isFirstResponder])
        return;
    
    [UIView beginAnimations:@"repositionForm" context:nil];
    [UIView setAnimationDuration:0.3];
    self.tableView.contentInset = UIEdgeInsetsMake(5, 0, 0, 0);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 0, 0);
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (!emailField.text || [emailField.text isEqual:@""]) {
        [emailField becomeFirstResponder];
    }
    else if (!passwordField.text || [passwordField.text isEqual:@""]) {
        [passwordField becomeFirstResponder];
    }
    else if (showRegister && (!passwordVerifyField.text || [passwordVerifyField.text isEqual:@""])) {
        [passwordVerifyField becomeFirstResponder];
    }
    else if (showRegister && (!fullNameField.text || [fullNameField.text isEqual:@""])) {
        [fullNameField becomeFirstResponder];
    }
    else if (showRegister) {
        [self sendRegister];
    }
    else {
        [self sendLogin];
    }
    
    return YES;
}

- (void)showLoading {
    if (!loading) {
        self.loading = [[[WBProgressHUD alloc] init] autorelease];
    }
    
    CGFloat width = 160;
    CGFloat height = 120;
    self.loading.frame = CGRectMake((self.view.frame.size.width - width) / 2.0,
                                    (self.view.frame.size.height - height) / 4.0,
                                    width,
                                    height);

    // Hide the keyboard and prevent further editing.
    self.view.userInteractionEnabled = NO;
    [self.view endEditing:YES];
    
    [loading showInView:self.tableView];
}
- (void)hideLoading {
    [loading removeFromSuperview];
    
    // Allow editing again.
    self.view.userInteractionEnabled = YES;
}

- (void)dealloc {
    [message release];
    [loading release];
    
    [emailField release];
    [passwordField release];
    [passwordVerifyField release];
    [fullNameField release];
    
    [loginButton release];
    [registerButton release];
    [cancelButton release];
    [googleButton release];
    [yahooButton release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (UIView *)createMessage {
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 120)];

    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, 280, 30)];
    l.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    l.textAlignment = UITextAlignmentCenter;
    l.backgroundColor = [UIColor clearColor];
    l.font = [UIFont systemFontOfSize:14.0];
    l.textColor = [UIColor darkGrayColor];
    l.shadowColor = [UIColor whiteColor];
    l.shadowOffset = CGSizeMake(0.0, 1.0);
    l.numberOfLines = 0;
    l.text = message;
    
    [container addSubview:l];
    [l sizeToFit];

    // Center and size the frames appropriately.
    CGRect frame = l.frame;
    frame.origin.x = (320 - frame.size.width) / 2;
    container.frame = CGRectMake(0, 0, 320, frame.size.height + 10);
    l.frame = frame;
    [l release];
    
    return [container autorelease];
}

- (UIView *)createActionButtons {
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
    
    // Login
    UIButton *lb = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, 300, 45)];
    lb.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    lb.titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
    lb.titleLabel.shadowColor = [UIColor blackColor];
    lb.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    
    [lb setTitle:@"Login" forState:UIControlStateNormal];
    [lb setBackgroundImage:[[UIImage imageNamed:@"login.png"] stretchableImageWithLeftCapWidth:150 topCapHeight:22] forState:UIControlStateNormal];
    [lb setContentMode:UIViewContentModeScaleToFill];
    [lb addTarget:self action:@selector(sendLogin) forControlEvents:UIControlEventTouchUpInside];

    // Adjust the frame for modal sheet presentation.
    if ([[[[UIApplication sharedApplication].delegate window] rootViewController] isKindOfClass:[LoginBackgroundViewController class]]) {
        lb.frame = CGRectMake(30, 0, 260, 45);
    }
    
    // Register
    UIButton *rb = [[UIButton alloc] initWithFrame:CGRectMake(10, 55, 300, 45)];
    rb.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    rb.titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
    rb.titleLabel.shadowColor = [UIColor blackColor];
    rb.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
    
    [rb setTitle:@"Create an Account" forState:UIControlStateNormal];
    [rb setBackgroundImage:[[UIImage imageNamed:@"register.png"] stretchableImageWithLeftCapWidth:150 topCapHeight:22] forState:UIControlStateNormal];
    [lb setContentMode:UIViewContentModeScaleToFill];
    [rb addTarget:self action:@selector(toggleRegister) forControlEvents:UIControlEventTouchUpInside];
    
    // Cancel
    UIButton *cb = [[UIButton alloc] initWithFrame:CGRectMake(10, 55, 300, 35)];
    cb.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    cb.titleLabel.font = [UIFont systemFontOfSize:16.0];
    cb.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    
    [cb setTitle:@"Cancel" forState:UIControlStateNormal];
    [cb setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [cb setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cb addTarget:self action:@selector(toggleRegister) forControlEvents:UIControlEventTouchUpInside];
    cb.alpha = 0.0;

    // Google
    UIButton *gb = [[UIButton alloc] initWithFrame:CGRectMake(10, 110, 140, 50)];
    [gb setBackgroundImage:[UIImage imageNamed:@"login-google.png"] forState:UIControlStateNormal];
    gb.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    [gb addTarget:self action:@selector(tapGoogle) forControlEvents:UIControlEventTouchUpInside];

    // Yahoo
    UIButton *yb = [[UIButton alloc] initWithFrame:CGRectMake(165, 110, 143, 50)];
    [yb setBackgroundImage:[UIImage imageNamed:@"login-yahoo.png"] forState:UIControlStateNormal];
    yb.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [yb addTarget:self action:@selector(tapYahoo) forControlEvents:UIControlEventTouchUpInside];

    self.loginButton = lb;
    self.registerButton = rb;
    self.cancelButton = cb;
    self.googleButton = gb;
    self.yahooButton = yb;
    [lb release];
    [rb release];
    [cb release];
    [gb release];
    [yb release];
    
    [container addSubview:loginButton];

    if (![Config currentConfig].sso && ![Config currentConfig].private) {
        [container addSubview:registerButton];
        [container addSubview:cancelButton];
        [container addSubview:googleButton];
        [container addSubview:yahooButton];
    }

    return [container autorelease];
}

- (void)tapGoogle {
    OpenIDViewController *vc = [OpenIDViewController viewControllerForHost:@"google" delegate:delegate];
    if (modal) {
        [self presentModalViewController:vc animated:YES];
    }
    else {
        [delegate presentModalViewController:vc animated:YES];
    }
}

- (void)tapYahoo {
    OpenIDViewController *vc = [OpenIDViewController viewControllerForHost:@"yahoo" delegate:delegate];
    if (modal) {
        [self presentModalViewController:vc animated:YES];
    }
    else {
        [delegate presentModalViewController:vc animated:YES];
    }
}

- (void)toggleRegister {
    showRegister = !showRegister;
    
    NSArray *indexPaths = [NSArray arrayWithObjects:
                           [NSIndexPath indexPathForRow:2 inSection:0], 
                           [NSIndexPath indexPathForRow:3 inSection:0], nil];

    if (showRegister) {
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        [UIView beginAnimations:@"showRegister" context:nil];
        [UIView setAnimationDuration:0.3];
        
        // Hide login
        loginButton.alpha = 0.0;
        googleButton.alpha = 0.0;
        yahooButton.alpha = 0.0;
        
        // Move Register up, change text, and change target
        CGRect frame = registerButton.frame;
        frame.origin.y = 0;
        registerButton.frame = frame;
        [registerButton setTitle:@"Register" forState:UIControlStateNormal];
        [registerButton removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
        [registerButton addTarget:self action:@selector(sendRegister) forControlEvents:UIControlEventTouchUpInside];

        // Show Cancel
        cancelButton.alpha = 1.0;
        
        [UIView commitAnimations];
    }
    else {
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        [UIView beginAnimations:@"showRegister" context:nil];
        [UIView setAnimationDuration:0.3];
        
        // Show Login
        loginButton.alpha = 1.0;
        googleButton.alpha = 1.0;
        yahooButton.alpha = 1.0;

        // Move Register down, change text, and change target
        CGRect frame = registerButton.frame;
        frame.origin.y = 55;
        registerButton.frame = frame;
        [registerButton setTitle:@"Create an Account" forState:UIControlStateNormal];
        [registerButton removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
        [registerButton addTarget:self action:@selector(toggleRegister) forControlEvents:UIControlEventTouchUpInside];

        // Hide Cancel
        cancelButton.alpha = 0.0;
        
        [UIView commitAnimations];
    }
    
    // Change the password action item from "Done" to "Next" or back again.
    passwordField.returnKeyType = showRegister ? UIReturnKeyNext : UIReturnKeyDone;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Login";
    self.tableView.backgroundView = nil;
    self.view.backgroundColor = [UIColor colorWithRed:0.86 green:0.86 blue:0.86 alpha:1.0];
    
    self.tableView.tableHeaderView = [self createMessage];
    self.tableView.tableFooterView = [self createActionButtons];
    
    self.tableView.contentInset = UIEdgeInsetsMake(5, 0, 0, 0);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.emailField = nil;
    self.passwordField = nil;
    self.passwordVerifyField = nil;
    self.fullNameField = nil;
    
    self.loginButton = nil;
    self.registerButton = nil;
    self.cancelButton = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        return YES;
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([Config currentConfig].site == ConfigIFixit)
        return @"iFixit Login";
    else if ([Config currentConfig].site == ConfigMake)
        return @"Make: Projects Login";
    return @"Login";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([Config currentConfig].sso)
        return 0;

    // Return the number of rows in the section.
    return showRegister ? 4 : 2;
}

- (UITextField *)inputFieldForRow:(NSInteger)row {
    
    UITextField *inputField = [[UITextField alloc] init];
    inputField.font = [UIFont systemFontOfSize:16.0];
    inputField.adjustsFontSizeToFitWidth = YES;
    inputField.textColor = [UIColor darkGrayColor];
    CGRect rect = CGRectMake(120, 12, 175, 30);
    
    if (row == 0) {
        if (emailField) {
            [inputField release];
            return emailField;
        }
        
        self.emailField = inputField;
        rect.origin.y += 1;
        inputField.frame = rect;
        inputField.placeholder = @"email@example.com";
        inputField.keyboardType = UIKeyboardTypeEmailAddress;
        inputField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        inputField.returnKeyType = UIReturnKeyNext;
    }
    else if (row == 1) {
        if (passwordField) {
            [inputField release];
            passwordField.returnKeyType = showRegister ? UIReturnKeyNext : UIReturnKeyDone;
            return passwordField;
        }
        
        self.passwordField = inputField;
        inputField.frame = rect;
        inputField.placeholder = @"Required";
        inputField.keyboardType = UIKeyboardTypeDefault;
        inputField.returnKeyType = showRegister ? UIReturnKeyNext : UIReturnKeyDone;
        inputField.secureTextEntry = YES;
    }       
    else if (row == 2) {
        if (passwordVerifyField) {
            [inputField release];
            return passwordVerifyField;
        }
        
        self.passwordVerifyField = inputField;
        inputField.frame = rect;
        inputField.placeholder = @"(again)";
        inputField.keyboardType = UIKeyboardTypeDefault;
        inputField.returnKeyType = UIReturnKeyNext;
        inputField.secureTextEntry = YES;
    }   
    else if (row == 3) {
        if (fullNameField) {
            [inputField release];
            return fullNameField;
        }
        
        self.fullNameField = inputField;
        inputField.frame = rect;
        inputField.placeholder = @"John Doe";
        inputField.keyboardType = UIKeyboardTypeDefault;
        inputField.returnKeyType = UIReturnKeyDone;
    }   
    inputField.backgroundColor = [UIColor clearColor];
    inputField.autocorrectionType = UITextAutocorrectionTypeNo;
    inputField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    inputField.textAlignment = UITextAlignmentLeft;
    inputField.delegate = self;
    inputField.tag = 0;
    
    inputField.clearButtonMode = UITextFieldViewModeNever;
    [inputField setEnabled:YES];
    
    return [inputField autorelease];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // Set the label
    if (indexPath.row == 0)
        cell.textLabel.text = @"Email";
    else if (indexPath.row == 1)
        cell.textLabel.text = @"Password";
    else if (indexPath.row == 2)
        cell.textLabel.text = @"Password";
    else if (indexPath.row == 3)
        cell.textLabel.text = @"Your Name";
    
    // Add the text field
    for (UIView *v in cell.subviews) {
        if ([v isKindOfClass:[UITextField class]])
            [v removeFromSuperview];
    }
    
    [cell.contentView addSubview:[self inputFieldForRow:indexPath.row]];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)sendLogin {
    if ([Config currentConfig].sso) {
        SSOViewController *vc = [SSOViewController viewControllerForURL:[Config currentConfig].sso delegate:delegate];
        [delegate presentModalViewController:vc animated:YES];
        return;
    }

    if (!emailField.text || !passwordField.text)
        return;
    
    [self showLoading];
    [[iFixitAPI sharedInstance] loginWithLogin:emailField.text
                                   andPassword:passwordField.text 
                                     forObject:self 
                                  withSelector:@selector(loginResults:)];
}
- (void)sendRegister {
    if (!emailField.text || !passwordField.text || !passwordVerifyField.text || !fullNameField.text) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
                                                        message:@"All fields are required"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"Okay", nil];
        [alert show];
        [alert release];
    } else if ([[passwordField.text stringByTrimmingCharactersInSet:
                 [NSCharacterSet whitespaceAndNewlineCharacterSet]] length] < 6) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Passwords must be at least 6 characters and contain a non-space character."
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"Okay", nil];
        [alert show];
        [alert release];

    } else if (![passwordVerifyField.text isEqual:passwordField.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
                                                        message:@"Passwords don't match"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"Okay", nil];
        [alert show];
        [alert release];
    } else {
        [self showLoading];
        [[iFixitAPI sharedInstance] registerWithLogin:emailField.text
                                          andPassword:passwordField.text 
                                              andName:fullNameField.text 
                                            forObject:self
                                         withSelector:@selector(loginResults:)];
    }
}

- (void)loginResults:(NSDictionary *)results { 
    if ([results objectForKey:@"error"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
                                                        message:[results objectForKey:@"msg"]
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"Okay", nil];
        [alert show];
        [alert release];
    }
    else {
        [emailField resignFirstResponder];
        [passwordField resignFirstResponder];
        [passwordVerifyField resignFirstResponder];
        [fullNameField resignFirstResponder];

        // The delegate is responsible for removing the login view.
        [delegate refresh];
    }
    
    [self hideLoading];
}

@end
