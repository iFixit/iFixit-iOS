//
//  PastFeaturesViewController.m
//  iFixit
//
//  Created by David Patierno on 11/7/11.
//  Copyright (c) 2011 iFixit. All rights reserved.
//

#import "PastFeaturesViewController.h"
#import "PastFeaturesViewDelegate.h"

@implementation PastFeaturesViewController

@synthesize collections = _collections, dateFormat, delegate = _delegate;

- (id)init {
    if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
        self.title = NSLocalizedString(@"Past Features", nil);
        self.collections = [NSMutableArray array];
        
        self.dateFormat = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormat setDateFormat:@"MM/dd"];
    }
    return self;
}

- (void)setCollections:(NSMutableArray *)collections {
    [_collections release];
    _collections = [collections retain];
    [self.tableView reloadData];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.collections count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    NSDictionary *collection = [self.collections objectAtIndex:indexPath.row];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[collection valueForKey:@"date"] intValue]];
    NSString *title = [collection valueForKey:@"title"];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@",
                           [dateFormat stringFromDate:date], title];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _delegate.collection = [_collections objectAtIndex:indexPath.row];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)dealloc {
    [_collections release];
    [super dealloc];
}

@end
