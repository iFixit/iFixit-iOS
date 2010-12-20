//
//  SplashViewController.m
//  iFixit
//
//  Created by David Patierno on 12/19/10.
//  Copyright 2010 iFixit. All rights reserved.
//

#import "iFixitAppDelegate.h"
#import "SplashViewController.h"

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

@synthesize guides, numImagesLoaded;
@synthesize button1, button2, button3, button4, button5, button6;
@synthesize label1, label2, label3, label4, label5, label6;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[iFixitAPI sharedInstance] getFeaturedGuides:nil forObject:self withSelector:@selector(gotFeaturedGuides:)];
}

- (void)gotFeaturedGuides:(NSArray *)guidesArray {
    self.guides = guidesArray;
    numImagesLoaded = 0;
    [self startImageDownloads];
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
    
    int guideid = [[[guides objectAtIndex:guide] valueForKey:@"guideid"] integerValue];
    [(iFixitAppDelegate *)[[UIApplication sharedApplication] delegate] showGuide:guideid];
}

- (IBAction)browseAll:(UIButton *)button {
    [(iFixitAppDelegate *)[[UIApplication sharedApplication] delegate] showBrowser];
}


- (void)startImageDownloads {
    if ([guides count] > numImagesLoaded)
        [[CachedImageLoader sharedImageLoader] addClientToDownloadQueue:self];
}
- (NSURLRequest *)request {
    if (numImagesLoaded >= [guides count])
        return nil;
    
    GuideImage *image = [[GuideImage alloc] init];
    image.url = [[guides objectAtIndex:numImagesLoaded] valueForKey:@"image_url"];
    
    return [NSURLRequest requestWithURL:[image URLForSize:@"standard"]];
}
- (void)renderImage:(UIImage *)theImage {
    numImagesLoaded++;
    
    // Use this instead of dispatch_async() for iOS 3.2 compatibility.
    [self performSelectorOnMainThread:@selector(setImageAndLoadNext:) withObject:theImage waitUntilDone:YES];
}

- (void)setImageAndLoadNext:(UIImage *)theImage {
    UIButton *button;
    UILabel *label;
    
    if (numImagesLoaded == 1) {
        button = button1;
        label = label1;
    }
    else if (numImagesLoaded == 2) {
        button = button2;
        label = label2;
    }
    else if (numImagesLoaded == 3) {
        button = button3;
        label = label3;
    }
    else if (numImagesLoaded == 4) {
        button = button4;
        label = label4;
    }
    else if (numImagesLoaded == 5) {
        button = button5;
        label = label5;
    }
    else if (numImagesLoaded == 6) {
        button = button6;
        label = label6;
    }
    
    NSDictionary *guide = [guides objectAtIndex:numImagesLoaded-1];
    [label setText:[NSString stringWithFormat:@"%@ %@", 
                    [guide valueForKey:@"device"],
                    [guide valueForKey:@"thing"]]];
    [label alignTop];
    [button setBackgroundImage:theImage forState:UIControlStateNormal];
    
    // Load the next image.
    if ([guides count] > numImagesLoaded)
        [[CachedImageLoader sharedImageLoader] addClientToDownloadQueue:self];
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
