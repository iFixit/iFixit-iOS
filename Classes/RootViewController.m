//
//  RootViewController.m
//  iFixit
//
//  Created by David Patierno on 8/6/10.
//  Copyright iFixit 2010. All rights reserved.
//

#import "iFixitAppDelegate.h"
#import "RootViewController.h"
#import "DetailViewController.h"


@implementation RootViewController

@synthesize delegate, detailViewController, tree, keys, leafs;


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
}

- (void)viewDidAppear:(BOOL)animated {
   
   if (animated)
      return;
   
   // Restore the last-viewed guide if necessary.
   NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSNumber *last_guide = [prefs objectForKey:@"last_guide"];
	if (last_guide && (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)) {
      GuideViewController *vc = [GuideViewController initWithGuideid:[last_guide intValue]];
      [self presentModalViewController:vc animated:NO];
      
      NSNumber *last_guide_page = [prefs objectForKey:@"last_guide_page"];
      if (last_guide_page)
         [vc showPage:[last_guide_page intValue]];
      
   }
   
}

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark -
#pragma mark Table view data source

- (void)setData:(NSDictionary *)dict {
	// Separate the leafs.
	self.tree = [NSMutableDictionary dictionaryWithDictionary:dict];
	self.leafs = [[tree objectForKey:@"DEVICES"] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
	[tree removeObjectForKey:@"DEVICES"];
	self.keys = [[tree allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    // Return the number of sections.
    return [keys count] && [leafs count] ? 2 : 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	// Don't show titles if there's only one
	if ([self numberOfSectionsInTableView:nil] == 1 || ![keys count])
		return nil;
	
	return section == 0 ? @"Areas" : @"Devices";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if (section == 0 && [keys count])
		return [keys count];
	return [leafs count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CellIdentifier";
    
    // Dequeue or create a cell of the appropriate type.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    // Configure the cell.
	if (indexPath.section == 0 && [keys count]) {
		cell.textLabel.text = [NSString stringWithFormat:@"%@", [keys objectAtIndex:indexPath.row]];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	} else {
		cell.textLabel.text = [NSString stringWithFormat:@"%@", [leafs objectAtIndex:indexPath.row]];
		cell.accessoryType = UITableViewCellStyleDefault;
	}
	
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	if (indexPath.section == 0 && [keys count]) {
		RootViewController *vc = [[RootViewController alloc] init];
		vc.detailViewController = detailViewController;

		NSString *area = [keys objectAtIndex:indexPath.row];
		[vc setData:[tree valueForKey:area]];
		[vc.tableView reloadData];
		
		[vc.navigationItem setTitle:area];
		[self.navigationController pushViewController:vc animated:YES];
		[vc release];
	} else {
        [(iFixitAppDelegate *)[[UIApplication sharedApplication] delegate] showBrowser];

		// Show the device in detailViewController
		NSString *device = [leafs objectAtIndex:indexPath.row];
		NSString *url = [NSString stringWithFormat:@"http://%@/Guide/Device/%@", 
                         IFIXIT_HOST,
						 [device stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
		NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
		[detailViewController.webView loadRequest:request];

      [detailViewController.popoverController dismissPopoverAnimated:YES];
	}

	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];

}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [detailViewController release];
    [super dealloc];
}


@end

