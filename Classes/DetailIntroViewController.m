//
//  DetailIntroViewController.m
//  iFixit
//
//  Created by David Patierno on 11/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DetailIntroViewController.h"

@implementation DetailIntroViewController
@synthesize text;
@synthesize image, orientationOverride;

- (id)init {
    if ((self = [super initWithNibName:nil bundle:nil])) {
        // Custom initialization
    }
    return self;
}

- (void)positionImages {
    CGRect frame = image.frame;
    
    if (UIInterfaceOrientationIsLandscape(orientationOverride)) {
        text.alpha = 0.0;
        frame.origin.y = -60.0;
    }
    else {
        text.alpha = 1.0;
        frame.origin.y = 192.0;
    }
        
    image.frame = frame;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setImage:nil];
    [self setText:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)dealloc {
    [image release];
    [text release];
    [super dealloc];
}
@end
