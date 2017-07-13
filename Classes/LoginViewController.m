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
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "User.h"
#import "ListViewController.h"
#import "iFixitAppDelegate.h"

@implementation LoginViewController

@synthesize delegate, message, loading, showRegister, modal;
@synthesize emailField, passwordField, passwordVerifyField, fullNameField, usernameField;
@synthesize loginButton, registerButton, cancelButton, googleButton, yahooButton;

- (id)init {
     if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
          // Custom initialization
          self.delegate = nil;
          self.loading = nil;
          self.message = NSLocalizedString(@"Favorites are saved offline and synced across devices.", nil);
          showRegister = NO;
          self.emailField = nil;
          self.passwordField = nil;
          self.passwordVerifyField = nil;
          self.fullNameField = nil;
          self.usernameField = nil;
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
         [passwordVerifyField isFirstResponder] || [fullNameField isFirstResponder] || [usernameField isFirstResponder])
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
     else if (showRegister && (!usernameField.text || [usernameField.text isEqual:@""])) {
          [usernameField becomeFirstResponder];
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
     [usernameField release];
     
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
     
     UIButton *lb = [UIButton buttonWithType:UIButtonTypeRoundedRect];
     lb.frame = CGRectMake(10,0,300,45);
     lb.autoresizingMask = UIViewAutoresizingFlexibleWidth;
     lb.titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
     lb.titleLabel.shadowColor = [UIColor blackColor];
     lb.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
     [lb setBackgroundImage:[[UIImage imageNamed:@"login.png"] stretchableImageWithLeftCapWidth:150 topCapHeight:22] forState:UIControlStateNormal];
     [lb setTitle:NSLocalizedString(@"Login", nil) forState:UIControlStateNormal];
     [lb setContentMode:UIViewContentModeScaleToFill];
     [lb addTarget:self action:@selector(sendLogin) forControlEvents:UIControlEventTouchUpInside];
     [lb setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
     [lb setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
     
     // Adjust the frame for modal sheet presentation.
     if ([[[[UIApplication sharedApplication].delegate window] rootViewController] isKindOfClass:[LoginBackgroundViewController class]]) {
          lb.frame = CGRectMake(30, 0, 260, 45);
     }
     
     // Register
     UIButton *rb = [UIButton buttonWithType:UIButtonTypeRoundedRect];
     rb.frame = CGRectMake(10, 55, 300, 45);
     rb.autoresizingMask = UIViewAutoresizingFlexibleWidth;
     rb.titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
     rb.titleLabel.shadowColor = [UIColor blackColor];
     rb.titleLabel.shadowOffset = CGSizeMake(0.0, -1.0);
     [rb setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
     [rb setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
     [rb setBackgroundImage:[[UIImage imageNamed:@"register.png"] stretchableImageWithLeftCapWidth:150 topCapHeight:22] forState:UIControlStateNormal];
     
     [rb setTitle:NSLocalizedString(@"Create an Account", nil) forState:UIControlStateNormal];
     [lb setContentMode:UIViewContentModeScaleToFill];
     [rb addTarget:self action:@selector(toggleRegister) forControlEvents:UIControlEventTouchUpInside];
     
     // Update buttons for iOS 7 only, remove this when we come up with a more permanent button design.
     if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
          rb.backgroundColor = [UIColor whiteColor];
          [rb setBackgroundImage:nil forState:UIControlStateNormal];
          [rb setBackgroundImage:nil forState:UIControlStateHighlighted];
          [rb setTitleColor:[Config currentConfig].buttonColor forState:UIControlStateNormal];
          [rb setTitleColor:[Config currentConfig].buttonColor forState:UIControlStateHighlighted];
          
          lb.backgroundColor = [UIColor whiteColor];
          lb.titleLabel.textColor = nil;
          [lb setBackgroundImage:nil forState:UIControlStateNormal];
          [lb setBackgroundImage:nil forState:UIControlStateHighlighted];
          [lb setTitleColor:[Config currentConfig].buttonColor forState:UIControlStateNormal];
          [lb setTitleColor:[Config currentConfig].buttonColor forState:UIControlStateHighlighted];
          
          // Special colors for MJTrimming
          if ([Config currentConfig].site == ConfigMjtrim) {
               [lb setTitleColor:[Config currentConfig].toolbarColor forState:UIControlStateNormal];
               [lb setTitleColor:[Config currentConfig].toolbarColor forState:UIControlStateHighlighted];
               [rb setTitleColor:[Config currentConfig].toolbarColor forState:UIControlStateNormal];
               [rb setTitleColor:[Config currentConfig].toolbarColor forState:UIControlStateHighlighted];
          }
     }
     
     // Cancel
     UIButton *cb = [[UIButton alloc] initWithFrame:CGRectMake(10, 55, 300, 35)];
     cb.autoresizingMask = UIViewAutoresizingFlexibleWidth;
     cb.titleLabel.font = [UIFont systemFontOfSize:16.0];
     cb.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
     
     [cb setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
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
     [cb release];
     [gb release];
     [yb release];
     
     [container addSubview:loginButton];
     
     if (![Config currentConfig].sso && ![Config currentConfig].private) {
          [container addSubview:registerButton];
          [container addSubview:cancelButton];
          
          // This is horrible, we should be respecting the feature switch instead of hardcoding this.
          if ([Config currentConfig].site != ConfigDripAssist) {
               [container addSubview:googleButton];
               [container addSubview:yahooButton];
          }
     }
     
     return [container autorelease];
}

- (void)tapGoogle {
     OpenIDViewController *openIdViewController = [OpenIDViewController viewControllerForHost:@"google" delegate:delegate];
     
     [self presentOpenIdViewController:openIdViewController];
}
- (void)presentOpenIdViewController:(OpenIDViewController *)openIdViewController {
     if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
          // Special case if our delegate is a list due to being on an iPad
          if ([delegate isKindOfClass:[ListViewController class]]) {
               iFixitAppDelegate *appDelegate = (iFixitAppDelegate*)[UIApplication sharedApplication].delegate;
               [appDelegate presentModalViewController:openIdViewController animated:YES];
          } else {
               [delegate presentModalViewController:openIdViewController animated:YES];
          }
     } else {
          openIdViewController.delegate = self;
          UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:openIdViewController];
          [self presentModalViewController:nvc animated:YES];
     }
     
}
- (void)tapYahoo {
     OpenIDViewController *openIdViewController = [OpenIDViewController viewControllerForHost:@"yahoo" delegate:delegate];
     
     [self presentOpenIdViewController:openIdViewController];
}

- (void)toggleRegister {
     showRegister = !showRegister;
     
     NSArray *indexPaths = [NSArray arrayWithObjects:
                            [NSIndexPath indexPathForRow:2 inSection:0],
                            [NSIndexPath indexPathForRow:3 inSection:0],
                            [NSIndexPath indexPathForRow:4 inSection:0], nil];
     
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
          [registerButton setTitle:NSLocalizedString(@"Register", nil) forState:UIControlStateNormal];
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
          [registerButton setTitle:NSLocalizedString(@"Create an Account", nil) forState:UIControlStateNormal];
          [registerButton removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
          [registerButton addTarget:self action:@selector(toggleRegister) forControlEvents:UIControlEventTouchUpInside];
          
          // Hide Cancel
          cancelButton.alpha = 0.0;
          
          [UIView commitAnimations];
     }
     
     // Change the password action item from "Done" to "Next" or back again.
     passwordField.returnKeyType = showRegister ? UIReturnKeyNext : UIReturnKeyDone;
}

- (void)viewDidLoad {
     [super viewDidLoad];
     
     self.title = NSLocalizedString(@"Login", nil);
     self.tableView.backgroundView = nil;
     self.view.backgroundColor = [UIColor colorWithRed:0.86 green:0.86 blue:0.86 alpha:1.0];
     
     self.tableView.tableHeaderView = [self createMessage];
     self.tableView.tableFooterView = [self createActionButtons];
     
     self.tableView.contentInset = UIEdgeInsetsMake(5, 0, 0, 0);
     self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
     
     // Adds ability to check when a user touches UITableView only
     UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]
                                           initWithTarget:self
                                           action:@selector(tableViewTapped:)];
     
     tapGesture.delegate = self;
     [[self tableView] addGestureRecognizer:tapGesture];
     [tapGesture release];
     
     [self configureAppearance];
     [self configureLeftBarButtonItem];
}

- (void)configureLeftBarButtonItem {
     UIBarButtonItem *button;
     
     if (([Config currentConfig].site == ConfigDozuki && modal) || ([Config currentConfig].site == ConfigDozuki && [delegate isKindOfClass:[iFixitAppDelegate class]])) {
          UIImage *icon = [UIImage imageNamed:@"backtosites.png"];
          button = [[UIBarButtonItem alloc] initWithImage:icon style:UIBarButtonItemStyleBordered
                                                   target:delegate
                                                   action:@selector(showDozukiSplash)];
          
     } else {
          button = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil)
                                                    style:UIBarButtonItemStyleDone
                                                   target:self
                                                   action:@selector(doneButtonPushed)];
     }
     
     self.navigationItem.leftBarButtonItem = button;
     [button release];
}

- (void)doneButtonPushed {
     // Create the animation ourselves to mimic a modal presentation
     if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
          [UIView animateWithDuration:0.7
                           animations:^{
                                [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:self.navigationController.view cache:YES];
                           }];
          [self.navigationController popViewControllerAnimated:NO];
     } else {
          [self dismissModalViewControllerAnimated:YES];
     }
}

- (void)configureAppearance {
     self.navigationController.navigationBar.translucent = NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
     // If the user is trying to select a button on the tableview, don't return the touch event
     return ![touch.view isKindOfClass:[UIButton class]];
}

- (void)tableViewTapped:(UITapGestureRecognizer *)tapGesture {
     // Remove keyboard
     [self.view endEditing:YES];
}

- (void)viewDidUnload {
     [super viewDidUnload];
     // Release any retained subviews of the main view.
     // e.g. self.myOutlet = nil;
     self.emailField = nil;
     self.passwordField = nil;
     self.passwordVerifyField = nil;
     self.fullNameField = nil;
     self.usernameField = nil;
     
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
     
     return NSLocalizedString(@"Login", nil);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
     if ([Config currentConfig].sso)
          return 0;
     
     // Return the number of rows in the section.
     return showRegister ? 5 : 2;
}

- (UITextField *)inputFieldForRow:(NSInteger)row {
     
     UITextField *inputField = [[UITextField alloc] init];
     inputField.font = [UIFont systemFontOfSize:16.0];
     inputField.adjustsFontSizeToFitWidth = YES;
     inputField.textColor = [UIColor darkGrayColor];
     inputField.autocapitalizationType = UITextAutocapitalizationTypeWords;
     CGRect rect = CGRectMake(120, 12, 175, 30);
     
     if (row == 0) {
          if (emailField) {
               [inputField release];
               return emailField;
          }
          
          self.emailField = inputField;
          
          NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
          NSString *email = [defaults objectForKey:@"email"];
          if (email != nil) {
               [self.emailField setText:email];
          }
          rect.origin.y += 1;
          inputField.frame = rect;
          inputField.placeholder = NSLocalizedString(@"email@example.com", nil);
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
          inputField.placeholder = NSLocalizedString(@"Required", nil);
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
          inputField.placeholder = [NSString stringWithFormat:@"(%@)", NSLocalizedString(@"again", nil)];
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
     else if (row == 4) {
          if (usernameField) {
               [inputField release];
               return usernameField;
          }
          
          self.usernameField = inputField;
          inputField.frame = rect;
          inputField.placeholder = @"johnny1990";
          inputField.keyboardType = UIKeyboardTypeDefault;
          inputField.autocapitalizationType = UITextAutocapitalizationTypeNone;
          inputField.returnKeyType = UIReturnKeyDone;
     }
     inputField.backgroundColor = [UIColor clearColor];
     inputField.autocorrectionType = UITextAutocorrectionTypeNo;
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
          cell.textLabel.text = NSLocalizedString(@"Email", nil);
     else if (indexPath.row == 1)
          cell.textLabel.text = NSLocalizedString(@"Password", nil);
     else if (indexPath.row == 2)
          cell.textLabel.text = NSLocalizedString(@"Password", nil);
     else if (indexPath.row == 3)
          cell.textLabel.text = NSLocalizedString(@"Your Name", nil);
     else if (indexPath.row == 4)
          cell.textLabel.text = NSLocalizedString(@"Username", nil);
     
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
          SSOViewController *vc = [SSOViewController viewControllerForURL:[Config currentConfig].sso delegate:self];
          UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
          [self presentModalViewController:nvc animated:YES];
          
          [nvc release];
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

- (void)refresh {
     [self dismissViewAndRefreshDelegate];
}

- (void)sendRegister {
     if (!emailField.text || !passwordField.text || !passwordVerifyField.text || !fullNameField.text || !usernameField.text) {
          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"More information needed", nil)
                                                          message:NSLocalizedString(@"Please fill out all the information.", nil)
                                                         delegate:nil
                                                cancelButtonTitle:nil
                                                otherButtonTitles:NSLocalizedString(@"Okay", nil), nil];
          [alert show];
          [alert release];
     }
     else if (![passwordVerifyField.text isEqual:passwordField.text]) {
          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                          message:NSLocalizedString(@"Passwords don't match", nil)
                                                         delegate:nil
                                                cancelButtonTitle:nil
                                                otherButtonTitles:NSLocalizedString(@"Okay", nil), nil];
          [alert show];
          [alert release];
     }
     else {
          [self showLoading];
          [[iFixitAPI sharedInstance] registerWithLogin:emailField.text
                                            andPassword:passwordField.text
                                                andName:fullNameField.text
                                            andUsername:usernameField.text
                                              forObject:self
                                           withSelector:@selector(loginResults:)];
     }
}

- (void)loginResults:(NSDictionary *)results {
     [self hideLoading];
     
     if (!results) {
          [iFixitAPI displayConnectionErrorAlert];
          return;
     }
     
     if (![results objectForKey:@"authToken"]) {
          
          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                          message:results[@"message"]
                                                         delegate:nil
                                                cancelButtonTitle:nil
                                                otherButtonTitles:NSLocalizedString(@"Okay", nil), nil];
          [alert show];
          [alert release];
     }
     else {
          // Analytics
          [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"User"
                                                                                              action:@"Login"
                                                                                               label:@"User logged in"
                                                                                               value:[iFixitAPI sharedInstance].user.iUserid] build]];
          
          [emailField resignFirstResponder];
          [passwordField resignFirstResponder];
          [passwordVerifyField resignFirstResponder];
          [fullNameField resignFirstResponder];
          
          NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
          [defaults setObject:emailField.text forKey:@"email"];
          [defaults synchronize];
          
          [self dismissViewAndRefreshDelegate];
     }
}

- (void)dismissViewAndRefreshDelegate {
     // If we are dealing with the app delegate, we don't dismiss anything, just refresh it
     if ([delegate isKindOfClass:[iFixitAppDelegate class]]) {
          [delegate refresh];
     } else if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
          [self.listViewController popViewControllerAnimated:YES];
          [delegate refresh];
     } else {
          [self dismissViewControllerAnimated:YES completion:^(void){
               [delegate refresh];
          }];
     }
}

@end
