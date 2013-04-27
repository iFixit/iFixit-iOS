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
#import "iFixitAPI.h"
#import "Config.h"
#import "GuideViewController.h"
#import "ImageGalleryViewController.h"

@implementation BookmarksViewController

@synthesize bookmarks, lvc, devices;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {    
        self.title = @"Favorites";

        LoginViewController *vc = [[LoginViewController alloc] init];
        vc.delegate = self;
        self.lvc = vc;
        self.devices = [NSMutableArray array];
        [vc release];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(refresh)
                                                     name:GuideBookmarksUpdatedNotification
                                                   object:nil];
        
        [[GuideBookmarks sharedBookmarks] update];
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
        NSMutableArray *guides = [b objectForKey:guide.topic];
        
        if (guides) {
            [guides addObject:guide];
        }
        else {
            guides = [NSMutableArray arrayWithObject:guide];
            [b setObject:guides forKey:guide.topic];
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
        }
        else {
            // If there are no bookmarks, display a brief message.
            UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 280, 100)];
            label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            label.textAlignment = UITextAlignmentCenter;
            label.numberOfLines = 3;
            label.textColor = [UIColor darkGrayColor];
            label.shadowOffset = CGSizeMake(0.0f, -1.0f);
            label.shadowColor = [UIColor whiteColor];
            label.backgroundColor = [UIColor clearColor];
            label.text = @"You haven't saved any guides for offline view yet. When you do, they'll appear here.";
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
    
    b.backgroundColor = [UIColor colorWithRed:0.20 green:0.38 blue:0.68 alpha:1.0];
    if ([Config currentConfig].site == ConfigZeal)
        b.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];

    b.titleLabel.font = [UIFont italicSystemFontOfSize:14];
    b.titleLabel.textColor = [UIColor whiteColor];
    b.titleLabel.shadowColor = [UIColor blackColor];
    b.titleLabel.shadowOffset = CGSizeMake(0, 1);
    b.titleLabel.backgroundColor = [UIColor clearColor];
    [b setTitle:[NSString stringWithFormat:@"Logged in as %@", [iFixitAPI sharedInstance].user.username] forState:UIControlStateNormal];

    [b addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
    
    return [b autorelease];
}

- (void)applyPaddedFooter {
	UIView *footer = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 45)] autorelease];
	footer.backgroundColor = [UIColor clearColor];
	self.tableView.tableFooterView = footer;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
        [self applyPaddedFooter];

    self.navigationItem.rightBarButtonItem = [iFixitAPI sharedInstance].user ?
        self.editButtonItem : nil;
    
    self.tableView.tableHeaderView = [self headerView];
    
    // Make room for the toolbar
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 44, 0);
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 44, 0);
    }
    else {
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 32, 0);
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 32, 0);
    }
    
    // Show the Dozuki sites select button if needed.
    if ([Config currentConfig].dozuki) {
        UIImage *icon = [UIImage imageNamed:@"backtosites.png"];
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithImage:icon style:UIBarButtonItemStyleBordered
                                                                  target:[[UIApplication sharedApplication] delegate]
                                                                  action:@selector(showDozukiSplash)];
        self.navigationItem.leftBarButtonItem = button;
        [button release];
    }
    
    UIBarButtonItem *imageGalleryButton = [[UIBarButtonItem alloc] initWithTitle:@"Image Gallery"
                                                                           style:UIBarButtonItemStyleDone
                                                                          target:self
                                                                          action:@selector(presentImageGallery)
    ];
    
    self.navigationItem.leftBarButtonItem = imageGalleryButton;
}

- (void)presentImageGallery {
    ImageGalleryViewController *igvc = [[ImageGalleryViewController alloc] initWithNibName:@"ImageGalleryViewController" bundle:nil];
    [self presentModalViewController:igvc animated:YES];
    
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {    
    [TestFlight passCheckpoint:@"Bookmarks View"];

    // Show login view if needed.
    if (![iFixitAPI sharedInstance].user) {
        lvc.view.frame = self.view.frame;
        [self.view addSubview:lvc.view];
    }
    else {
        if ([[self.view subviews] containsObject:lvc.view])
            [lvc.view removeFromSuperview];

        [[GuideBookmarks sharedBookmarks] update];
        //[self performSelectorInBackground:@selector(refreshHierarchy) withObject:nil];
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
    //[(iFixitAppDelegate *)[[UIApplication sharedApplication] delegate] showGuide:guide];
    
    GuideViewController *vc = [[GuideViewController alloc] initWithGuide:guide];
    [self.navigationController presentModalViewController:vc animated:YES];
    [vc release];
    
    // Refresh any changes.
    [[GuideBookmarks sharedBookmarks] addGuideid:[NSNumber numberWithInt:guide.guideid]];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)showLogin {
    // Show login screen again.
    lvc.view.frame = self.view.frame;
    [UIView beginAnimations:@"curldown" context:nil];
    [UIView setAnimationDuration:1];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:self.view cache:YES];
    [self.view addSubview:lvc.view];
    [UIView commitAnimations];  
}
- (void)hideLogin {
    [UIView beginAnimations:@"curlup" context:nil];
    [UIView setAnimationDuration:1];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.view cache:YES];
    [lvc.view removeFromSuperview];
    [UIView commitAnimations];
}

- (void)refresh {
    self.tableView.tableHeaderView = [self headerView];
    
    // Show or hide login as needed.
    if (![iFixitAPI sharedInstance].user)
        [self showLogin];  
    else if ([[self.view subviews] containsObject:lvc.view]) {
        [self hideLogin];
        
        [[GuideBookmarks sharedBookmarks] update];
    }
    
    self.navigationItem.rightBarButtonItem = [iFixitAPI sharedInstance].user ?
        self.editButtonItem : nil;
    
    [self performSelectorInBackground:@selector(refreshHierarchy) withObject:nil];
}

- (void)logout {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:@"Logout"
                                              otherButtonTitles:nil];
    [sheet showFromRect:self.tableView.tableHeaderView.frame inView:self.view animated:YES];
    [sheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex)
        return;
    
    [[iFixitAPI sharedInstance] logout];

    // Remove the edit button.
    self.navigationItem.rightBarButtonItem = nil;

    if ([Config currentConfig].private) {
        [(iFixitAppDelegate*)[[UIApplication sharedApplication] delegate] showDozukiSplash];
    }
    else {
        [self showLogin]; 
    }
}

@end
