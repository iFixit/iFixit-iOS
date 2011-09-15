//
//  SplashViewController.m
//  iFixit
//
//  Created by David Patierno on 12/19/10.
//  Copyright 2010 iFixit. All rights reserved.
//

#import "iFixitAppDelegate.h"
#import "SplashViewController.h"
#import "UIButton+WebCache.h"
#import "Config.h"

#pragma mark VerticalAlign
@interface UILabel (VerticalAlign)
- (void)alignTop;
@end

@implementation UILabel (VerticalAlign)
- (void)alignTop {
    CGSize fontSize = [self.text sizeWithFont:self.font];

    double finalHeight = fontSize.height * self.numberOfLines;
    double finalWidth = self.frame.size.width;    //expected width of label

    CGSize theStringSize = [self.text sizeWithFont:self.font constrainedToSize:CGSizeMake(finalWidth, finalHeight) lineBreakMode:self.lineBreakMode];
    
    int newLinesToPad = (finalHeight  - theStringSize.height) / fontSize.height;
    
    for (int i=1; i< newLinesToPad; i++) {
        self.text = [self.text stringByAppendingString:@"\n"];
    }
}
@end



@implementation SplashViewController

@synthesize splashHeaderMake, splashHeaderIFixit, featuredLabelMake, featuredLabelIFixit;
@synthesize guides, numImagesLoaded, lastRow;
@synthesize button1, button2, button3, button4, button5, button6, button7, button8, button9;
@synthesize label1, label2, label3, label4, label5, label6, label7, label8, label9;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set the appropriate header.
    if ([Config currentConfig].site == ConfigMake || [Config currentConfig].site == ConfigMakeDev) {
        featuredLabelMake.hidden = NO;
        splashHeaderMake.hidden = NO;
    }
    else if ([Config currentConfig].site == ConfigIFixit || [Config currentConfig].site == ConfigIFixitDev) {
        featuredLabelIFixit.hidden = NO;
        splashHeaderIFixit.hidden = NO;
    }
    
    // Set the background color.
    self.view.backgroundColor = [Config currentConfig].backgroundColor;

    self.guides = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    lastRow.alpha = (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || 
                     self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) ? 0 : 1;

    if (!guides)
        [[iFixitAPI sharedInstance] getGuides:@"featured" forObject:self withSelector:@selector(gotFeaturedGuides:)];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [UIView beginAnimations:@"fade" context:nil];
     lastRow.alpha = (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || 
                      toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) ? 0 : 1;
    [UIView commitAnimations];
}

- (void)gotFeaturedGuides:(NSArray *)guidesArray {
    self.guides = guidesArray;
    
    NSArray *buttons = [NSArray arrayWithObjects:button1, button2, button3, button4, button5, button6, button7, button8, button9, nil];
    NSArray *labels = [NSArray arrayWithObjects:label1, label2, label3, label4, label5, label6, label7, label8, label9, nil];

    for (int i=0; i<9; i++) {
        UIButton *button = [buttons objectAtIndex:i];
        UILabel *label = [labels objectAtIndex:i];
        
        NSDictionary *guide = nil;
        if ([guides count] > i)
            guide = [guides objectAtIndex:i];
        
        if (guide) {
            // Load the image
            GuideImage *image = [[GuideImage alloc] init];
            image.url = [guide valueForKey:@"image_url"];
            [button setImageWithURL:[image URLForSize:@"standard"]];
            [image release];
            
            // Set the label
            [label setText:[NSString stringWithFormat:@"%@ %@", 
                            [guide valueForKey:@"device"],
                            [guide valueForKey:@"thing"]]];
            [label alignTop];
            
            // Show the labels in case we hid them earlier from a network failure.
            button.backgroundColor = [UIColor clearColor];
            label.hidden = NO;
        }
        else {
            // Hide the labels and spinners.
            button.backgroundColor = [UIColor blackColor];
            label.hidden = YES;
        }
    }
}

- (IBAction)showGuide:(UIButton *)button {
    int guide;
    
    if ([button isEqual:button1])
        guide = 0;
    else if ([button isEqual:button2])
        guide = 1;
    else if ([button isEqual:button3])
        guide = 2;
    else if ([button isEqual:button4])
        guide = 3;
    else if ([button isEqual:button5])
        guide = 4;
    else if ([button isEqual:button6])
        guide = 5;
    else if ([button isEqual:button7])
        guide = 6;
    else if ([button isEqual:button8])
        guide = 7;
    else if ([button isEqual:button9])
        guide = 8;
    
    if (guide < [guides count]) {
        int guideid = [[[guides objectAtIndex:guide] valueForKey:@"guideid"] integerValue];
        [(iFixitAppDelegate *)[[UIApplication sharedApplication] delegate] showGuideid:guideid];
    }
}

- (IBAction)browseAll:(UIButton *)button {
    [(iFixitAppDelegate *)[[UIApplication sharedApplication] delegate] showBrowser];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
