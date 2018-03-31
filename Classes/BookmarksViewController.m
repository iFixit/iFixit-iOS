//
//  BookmarksViewController.m
//  iFixit
//
//  Created by David Patierno on 4/4/11.
//  Copyright 2011 iFixit. All rights reserved.
//

#import "BookmarksViewController.h"
#import "GuideBookmarks.h"
#import "Guide.h"
#import "iFixitAppDelegate.h"
#import "iFixitAPI.h"
#import "SDWebImageManager.h"
#import "LoginViewController.h"
#import "User.h"
#import "Config.h"
#import "GuideViewController.h"
#import "ListViewController.h"
#import "CategoryTabBarViewController.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"

@implementation BookmarksViewController

@synthesize bookmarks, lvc, devices, xframe;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
     if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
          self.title = NSLocalizedString(@"Favorites", nil);
          
          LoginViewController *vc = [[LoginViewController alloc] init];
          vc.delegate = self;
          self.lvc = vc;
          self.devices = [NSMutableArray array];
          [vc release];
          
          [[NSNotificationCenter defaultCenter] addObserver:self
                                                   selector:@selector(refresh)
                                                       name:GuideBookmarksUpdatedNotification
                                                     object:nil];
          
     }
     return self;
}

- (void)refreshHierarchy {
     NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
     
     NSMutableDictionary *b = [NSMutableDictionary dictionary];
     
     // Construct the key-value list by device name.
     NSArray *allBookmarks = [[GuideBookmarks sharedBookmarks].guides allValues];
     
     for (NSDictionary *guideData in allBookmarks) {
          Guide *guide = [Guide guideWithDictionary:guideData];
          NSMutableArray *guides = [b objectForKey:guide.category];
          
          if (guides) {
               [guides addObject:guide];
          } else {
               guides = [NSMutableArray arrayWithObject:guide];
               [b setObject:guides forKey:guide.category];
          }
     }
     
     // Sort everything.
     for (NSMutableArray *guides in [b allValues]) {
          [guides sortUsingComparator:(NSComparator)^(Guide *a, Guide *b) {
               return [a.subject compare:b.subject];
          }];
     }
     
     self.bookmarks = b;
     self.devices = [NSMutableArray arrayWithArray:[[bookmarks allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]];
     
     dispatch_sync(dispatch_get_main_queue(), ^{
          if ([bookmarks count]) {
               self.tableView.tableFooterView = nil;
          } else {
               // If there are no bookmarks, display a brief message.
               UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
               UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 280, 110)];
               label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
               label.textAlignment = UITextAlignmentCenter;
               label.numberOfLines = 5;
               label.textColor = [UIColor darkGrayColor];
               label.shadowOffset = CGSizeMake(0.0f, -1.0f);
               label.shadowColor = [UIColor whiteColor];
               label.backgroundColor = [UIColor clearColor];
               label.text = NSLocalizedString(@"You haven't saved any guides for offline view yet. When you do, they'll appear here.", nil);
               [footer addSubview:label];
               self.tableView.tableFooterView = footer;
               [label release];
               [footer release];
          }
          
          [self.tableView reloadData];
     });
     
     [pool drain];
}

- (void)dealloc {
     [bookmarks release];
     [lvc release];
     [devices release];
     
     [super dealloc];
}

- (void)didReceiveMemoryWarning {
     // Releases the view if it doesn't have a superview.
     [super didReceiveMemoryWarning];
     
     // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (UIView *)headerView {
     UIButton *b = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
     
     b.backgroundColor = [Config currentConfig].toolbarColor;
     
     if ([Config currentConfig].site == ConfigZeal || [Config currentConfig].site == ConfigMagnolia)
          b.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
     
     b.titleLabel.font = [UIFont boldSystemFontOfSize:14];
     b.titleLabel.shadowColor = [UIColor blackColor];
     b.titleLabel.shadowOffset = CGSizeMake(0, 1);
     b.titleLabel.backgroundColor = [UIColor clearColor];
     b.titleLabel.textColor = [UIColor whiteColor];
     
     [b setTitle:[NSString stringWithFormat:NSLocalizedString(@"LOGOUT", nil), [iFixitAPI sharedInstance].user.username] forState:UIControlStateNormal];
     
     [b addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
     
     return [b autorelease];
}

- (void)applyPaddedFooter {
     UIView *footer = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 45)] autorelease];
     footer.backgroundColor = [UIColor clearColor];
     self.tableView.tableFooterView = footer;
}

- (void)configureEditButton {
     UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Edit", nil) style:UIBarButtonItemStylePlain target:self action:@selector(toggleEdit)];
     
     self.editButton = barButtonItem;
     self.navigationItem.rightBarButtonItem = self.editButton;
     
     [barButtonItem release];
}

- (void)toggleEdit {
     [self.tableView setEditing:!self.tableView.editing animated:YES];
     
     self.navigationItem.rightBarButtonItem.title = self.tableView.editing ? NSLocalizedString(@"Done", nil) : NSLocalizedString(@"Edit", nil);
}

- (void)viewWillLayoutSubviews
{
     if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
//          self.view.frame = self.xframe;
     }
}

- (void)viewDidLayoutSubviews
{

}

- (void)viewDidLoad
{
     [super viewDidLoad];
     
     // Uncomment the following line to preserve selection between presentations.
     // self.clearsSelectionOnViewWillAppear = NO;
     
     
     if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
          [self applyPaddedFooter];
     
     [self configureEditButton];
     
     self.navigationItem.rightBarButtonItem = [iFixitAPI sharedInstance].user ?
     self.editButton : nil;
     
     self.tableView.tableHeaderView = [iFixitAPI sharedInstance].user ? [self headerView] : nil;
     
     // Make room for the toolbar
     if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
          self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 44, 0);
          self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 44, 0);
     }
     else {
          self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 32, 0);
          self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 32, 0);
     }
     
     UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil)
                                                                style:UIBarButtonItemStyleBordered
                                                               target:self
                                                               action:@selector(doneButtonPushed)];
     
     self.navigationItem.leftBarButtonItem = button;
     
     [button release];
     
     [self configureAppearance];
}

// iOS 7
- (void)configureAppearance {
     self.navigationController.navigationBar.translucent = NO;
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
     
     [self.listViewController configureProperties];
}

- (void)viewDidUnload
{
     [super viewDidUnload];
     // Release any retained subviews of the main view.
     // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
     // Show login view if needed.
     if (![iFixitAPI sharedInstance].user) {
          lvc.view.frame = self.view.frame;
          [self.view addSubview:lvc.view];
     }
     else {
          if ([[self.view subviews] containsObject:lvc.view])
               [lvc.view removeFromSuperview];
          
          [[GuideBookmarks sharedBookmarks] update];
     }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
     // Return YES for supported orientations
     return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
     // Make room for the toolbar
     if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
          self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 44, 0);
          self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 44, 0);
     }
     else {
          self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 32, 0);
          self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 32, 0);
     }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
     // Return the number of sections.
     return [bookmarks count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
     // Return the number of rows in the section.
     NSString *key = [devices objectAtIndex:section];
     return [[bookmarks objectForKey:key] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
     // Sort by device name.
     return [devices objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     static NSString *CellIdentifier = @"Cell";
     
     UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
     if (cell == nil) {
          cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
     }
     
     // Configure the cell...
     NSString *key = [devices objectAtIndex:indexPath.section];
     Guide *guide = [[bookmarks objectForKey:key] objectAtIndex:indexPath.row];
     
     // Display the "thing" if possible, otherwise fallback to the full title.
     cell.textLabel.text = (guide.subject && ![guide.subject isEqual:@""]) ? guide.subject : guide.title;
     
     return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
     return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
     if (editingStyle == UITableViewCellEditingStyleDelete) {
          NSString *key = [devices objectAtIndex:indexPath.section];
          NSMutableArray *section = [bookmarks objectForKey:key];
          Guide *guide = [section objectAtIndex:indexPath.row];
          
          // Delete from bookmarks file
          [[GuideBookmarks sharedBookmarks] removeGuide:guide];
          
          // Delete the row from the data source
          [section removeObjectAtIndex:indexPath.row];
          [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
          
          // Delete the section if there are no guides left.
          if (![section count]) {
               [devices removeObjectAtIndex:indexPath.section];
               [bookmarks removeObjectForKey:key];
               [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
          }
          
     }
     else if (editingStyle == UITableViewCellEditingStyleInsert) {
          // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
     NSString *key = [devices objectAtIndex:indexPath.section];
     Guide *guide = [[bookmarks objectForKey:key] objectAtIndex:indexPath.row];
     
     GuideViewController *vc = [[GuideViewController alloc] initWithGuide:guide];
     UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
     vc.offlineGuide = YES;
     
     if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
          [self.navigationController presentModalViewController:nvc animated:YES];
     } else {
          UIPopoverController *povc = [self.splitViewController.viewControllers[1] popOverController];
          
          if ([povc isPopoverVisible]) {
               [povc dismissPopoverAnimated:NO];
          }
          
          iFixitAppDelegate *delegate = (iFixitAppDelegate*)[[UIApplication sharedApplication] delegate];
          [delegate.window.rootViewController presentModalViewController:nvc animated:YES];
     }
     
     [vc release];
     [nvc release];
     
     // Refresh any changes.
     [[GuideBookmarks sharedBookmarks] addGuideid:guide.iGuideid];
     
     [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)dismissView {
     if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
          [self.navigationController popViewControllerAnimated:YES];
     } else {
          [self dismissViewControllerAnimated:YES completion:nil];
     }
}

- (void)refresh {
     
     // Show or hide login as needed.
     if (![iFixitAPI sharedInstance].user) {
          [self dismissView];
     } else if ([[self.view subviews] containsObject:lvc.view]) {
          [[GuideBookmarks sharedBookmarks] update];
     }
     
     self.navigationItem.rightBarButtonItem = [iFixitAPI sharedInstance].user ?
     self.editButton : nil;
     
     [self performSelectorInBackground:@selector(refreshHierarchy) withObject:nil];
     
     self.tableView.tableHeaderView = [self headerView];
}

- (void)logout {
     UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                        delegate:self
                                               cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                          destructiveButtonTitle:NSLocalizedString(@"Logout", nil)
                                               otherButtonTitles:nil];
     [sheet showFromRect:self.tableView.tableHeaderView.frame inView:self.view animated:YES];
     [sheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
     if (buttonIndex)
          return;
     
     [[iFixitAPI sharedInstance] logout];
     
     
     // Analytics
     [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"User"
                                                                                         action:@"Logout"
                                                                                          label:@"User logged out"
                                                                                          value:[iFixitAPI sharedInstance].user.iUserid] build]];
     // Set bookmarks to be nil and reload the tableView to release the cells
     bookmarks = nil;
     [self.tableView reloadData];
     
     // Remove the edit button.
     self.navigationItem.rightBarButtonItem = nil;
     
     // On Dozuki App
     if ([Config currentConfig].dozuki && [Config currentConfig].private) {
          [(iFixitAppDelegate*)[[UIApplication sharedApplication] delegate] showDozukiSplash];
          // On a custom private app
     } else if ([Config currentConfig].private) {
          [(iFixitAppDelegate*)[[UIApplication sharedApplication] delegate] showSiteSplash];
          // Everyone else who is public
     } else {
          [self dismissView];
     }
     
     NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
     [defaults removeObjectForKey:@"email"];
     [defaults synchronize];
}

@end
