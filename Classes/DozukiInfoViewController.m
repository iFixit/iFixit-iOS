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
        self.dssvc = [[DozukiSelectSiteViewController alloc] initWithNibName:@"DozukiSelectSiteView" bundle:nil];
    }
    return self;
}

- (void)showList {
    [self.navigationController pushViewController:dssvc animated:NO];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"How It Works";
    
    // Align vertically.
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        textLabel.text = [textLabel.text stringByAppendingString:@"\n\n\n\n"];
    }
    else {
        //self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.61 green:0.61 blue:0.07 alpha:1.0];
        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.95 green:0.46 blue:0.09 alpha:1.0];
    }
    
    [self willRotateToInterfaceOrientation:self.interfaceOrientation duration:0];
}

- (void)viewDidUnload
{
    [textLabel release];
    textLabel = nil;
    [getStartedButton release];
    getStartedButton = nil;
    [titleLabel release];
    titleLabel = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        return YES;
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        return;
    
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        CGRect frame = titleLabel.frame;
        frame.origin.y = 20;
        titleLabel.frame = frame;
        
        frame = textLabel.frame;
        frame.origin.y = 60;
        textLabel.frame = frame;
        
        frame = getStartedButton.frame;
        frame.origin.y = 275;
        getStartedButton.frame = frame;
    }
    else {
        CGRect frame = titleLabel.frame;
        frame.origin.y = 10;
        titleLabel.frame = frame;
        
        frame = textLabel.frame;
        frame.origin.y = 25;
        textLabel.frame = frame;   
        
        frame = getStartedButton.frame;
        frame.origin.y = 185;
        getStartedButton.frame = frame;
    }
}

- (IBAction)getStarted:(id)sender {
    [self.navigationController pushViewController:dssvc animated:YES];
    [dssvc release];
}

- (void)dealloc {
    self.dssvc = nil;
    [textLabel release];
    [getStartedButton release];
    [titleLabel release];
    [super dealloc];
}
@end
