//
//  DetailIntroViewController.m
//  iFixit
//
//  Created by David Patierno on 11/18/11.
//  Copyright (c) 2011 iFixit. All rights reserved.
//

#import "DetailIntroViewController.h"
#import "Config.h"

@implementation DetailIntroViewController
@synthesize text;
@synthesize siteLabel;
@synthesize image, orientationOverride;

- (id)init {
    if ((self = [super initWithNibName:nil bundle:nil])) {
        // Custom initialization
    }
    return self;
}

- (void)positionImages {
    CGRect frame;
    
    if (UIInterfaceOrientationIsLandscape(orientationOverride)) {
        text.alpha = 0.0;
        siteLabel.frame = CGRectMake(45.0, 260.0, 603.0, 150.0);
        
        frame = image.frame;

        switch ([Config currentConfig].site) {
            case ConfigMake:
                frame.origin.y = 270.0;
                frame.origin.x = 126.0;
                break;
            case ConfigZeal:
                frame.origin.y = -110.0;
                frame.origin.x = -30.0;
                break;
            case ConfigHaas2:
                frame.origin.y = 260.0;
                frame.origin.x = 270.0;
                break;
            /*EAOLandscape*/
            default:
                frame.origin.y = -60.0;
                break;
        }
    }
    else {
        text.alpha = 1.0;
        siteLabel.frame = CGRectMake(40.0, 200.0, 688.0, 150.0);

        frame = image.frame;

        switch ([Config currentConfig].site) {
            case ConfigMake:
                frame.origin.y = 210.0;
                frame.origin.x = 156.0;
                break;
            case ConfigZeal:
                frame.origin.y = 0.0;
                frame.origin.x = 0.0;
                break;
            case ConfigHaas2:
                frame.origin.y = 350.0;
                frame.origin.x = 300.0;
                break;
            /*EAOPortrait*/
            default:
                frame.origin.y = 192.0;
        }

    }

    image.frame = frame;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    switch ([Config currentConfig].site) {
        case ConfigIFixit:
            break;
        case ConfigMake:
            image.image = [UIImage imageNamed:@"make_logo_transparent.png"];
            image.frame = CGRectMake(image.frame.origin.x, image.frame.origin.y, 455.0, 97.0);
            image.center = self.view.center;
            text.image = [UIImage imageNamed:@"detailViewArrowLight.png"];
            text.frame = CGRectMake(text.frame.origin.x, text.frame.origin.y, 313.0, 174.0);
            break;
        case ConfigZeal:
            image.image = [UIImage imageNamed:@"zeal_logo_transparent.png"];
            image.frame = CGRectMake(image.frame.origin.x, image.frame.origin.y, 768.0, 768.0);
            image.center = self.view.center;
            text.image = [UIImage imageNamed:@"detailViewTextZeal.png"];
            break;
        case ConfigHaas2:
            image.image = [UIImage imageNamed:@"haas2_logo_transparent.png"];
            image.frame = CGRectMake(image.frame.origin.x, image.frame.origin.y, image.image.size.width, image.image.size.height);
            image.center = self.view.center;
            text.image = [UIImage imageNamed:@"detailViewTextHaas2.png"];
            break;
        /*EAOiPadLogo*/
        // Dozuki
        default:
            text.image = [UIImage imageNamed:@"detailViewArrowDark.png"];
            text.frame = CGRectMake(text.frame.origin.x, text.frame.origin.y, 313.0, 174.0);
            siteLabel.font = [UIFont fontWithName:@"Lobster" size:120.0];
            siteLabel.text = [[Config currentConfig].siteData valueForKey:@"title"];
            siteLabel.hidden = NO;
            image.hidden = YES;
            break;
    }
}

- (void)viewDidUnload {
    [self setImage:nil];
    [self setText:nil];
    [self setSiteLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return YES;
}

- (void)dealloc {
    [image release];
    [text release];
    [siteLabel release];
    [super dealloc];
}

@end
