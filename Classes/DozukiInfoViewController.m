//
//  DozukiInfoViewController.m
//  iFixit
//
//  Created by David Patierno on 8/16/11.
//  Copyright (c) 2011 iFixit. All rights reserved.
//

#import "iFixit-Swift.h"
#import "DozukiInfoViewController.h"

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


@end
