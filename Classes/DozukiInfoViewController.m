//
//  DozukiInfoViewController.m
//  iFixit
//
//  Created by David Patierno on 8/16/11.
//  Copyright (c) 2011 iFixit. All rights reserved.
//

#import "DozukiInfoViewController.h"
#import "DozukiSelectSiteViewController.h"
#import "iFixitAPI.h"

@implementation DozukiInfoViewController

@synthesize dssvc;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.dssvc = [[DozukiSelectSiteViewController alloc] initWithSimple:YES];
        self.title = NSLocalizedString(@"Back", nil);
    }
    return self;
}

- (void)showList {
    [self.navigationController pushViewController:dssvc animated:NO];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self willRotateToInterfaceOrientation:self.interfaceOrientation duration:0];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        return YES;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
