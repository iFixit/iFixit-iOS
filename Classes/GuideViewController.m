    //
//  GuideViewController.m
//  iFixit
//
//  Created by David Patierno on 8/9/10.
//  Copyright 2010 iFixit. All rights reserved.
//

#import "iFixitAppDelegate.h"
#import "GuideViewController.h"
#import "iFixitAPI.h"
#import "GuideIntroViewController.h"
#import "GuideStepViewController.h"

@implementation GuideViewController

@synthesize navBar, scrollView, pageControl, viewControllers, spinner;
@synthesize lastScroll, guide, guideid, shouldLoadPage;

+ (GuideViewController *)initWithGuideid:(NSInteger)guideid {
	GuideViewController *vc = [[GuideViewController alloc] initWithNibName:@"GuideView" bundle:nil];

    vc.guideid = guideid;
    vc.shouldLoadPage = 0;
	vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    vc.lastScroll = nil;
	
	// Load the data
	[[iFixitAPI sharedInstance] getGuide:guideid forObject:vc withSelector:@selector(gotGuide:)];

	return [vc autorelease];
}

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
	[(iFixitAppDelegate *)[[UIApplication sharedApplication] delegate] hideGuide];
	return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [alertView release];
    
    // Try Again
    if (buttonIndex) {
        [[iFixitAPI sharedInstance] getGuide:guideid forObject:self withSelector:@selector(gotGuide:)];
    }
    // Cancel
    else {
        [(iFixitAppDelegate *)[[UIApplication sharedApplication] delegate] hideGuide];
    }
}

- (void)gotGuide:(Guide *)theGuide {
	[spinner stopAnimating];

    if (!theGuide) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Network Error"
                                                            message:@"Failed loading guide."
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Try Again", nil];
        [alertView show];
        return;
    }
    
    pageControl.hidden = NO;
	self.guide = theGuide;

	// Steps plus one for intro
	NSInteger numPages = [guide.steps count] + 1;
	
	// view controllers are created lazily
    // in the meantime, load the array with placeholders which will be replaced on demand
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (unsigned i = 0; i < numPages; i++) {
        [controllers addObject:[NSNull null]];
    }
    self.viewControllers = controllers;
    [controllers release];
	
    // a page is the width of the scroll view
    scrollView.pagingEnabled = YES;
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * numPages, scrollView.frame.size.height);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    scrollView.delegate = self;
	
	// Steps plus one for intro
    pageControl.numberOfPages = numPages;
    pageControl.currentPage = 0;
	
	UINavigationItem *topItem = [[UINavigationItem alloc] initWithTitle:@"Back"];
	UINavigationItem *thisItem = [[UINavigationItem alloc] initWithTitle:guide.title];
	NSArray *navItems = [NSArray arrayWithObjects:topItem, thisItem, nil];
	[navBar setItems:navItems animated:NO];
	[topItem release];
	[thisItem release];
   
    if (shouldLoadPage) {
      
       [self showPage:shouldLoadPage];
      
    } else {
      
       [self loadScrollViewWithPage:0];
       [self loadScrollViewWithPage:1];

    }
    
    self.lastScroll = [NSDate date];

}

- (void)showPage:(NSInteger)page {
   
   if (guide) {
      pageControl.currentPage = page;
      [self changePage:nil];
   } else {
      shouldLoadPage = page;
   }

}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
/*
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

- (void)loadScrollViewWithPage:(int)page {
    if (page < 0 || page >= pageControl.numberOfPages)
       return;
	
	NSInteger stepNumber = page - 1;
	
    // replace the placeholder if necessary
    UIViewController *controller = [viewControllers objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null]) {
		if (stepNumber == -1) {
			controller = [GuideIntroViewController initWithGuide:guide];
            ((GuideIntroViewController *)controller).delegate = self;
		} else {
			controller = [GuideStepViewController initWithStep:[guide.steps objectAtIndex:stepNumber]];
            ((GuideStepViewController *)controller).delegate = self;
		}

       [viewControllers replaceObjectAtIndex:page withObject:controller];
    }
	
    // add the controller's view to the scroll view
    if (nil == controller.view.superview) {
        CGRect frame = scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        [scrollView addSubview:controller.view];
    }
    
    // Rate limit image loading.
    if (lastScroll) {
        NSDate *now = [NSDate date];        
        [self performSelector:@selector(checkCalm:) withObject:now afterDelay:0.6];
        self.lastScroll = now;
    }
}

- (void)checkCalm:(NSDate *)date {
    if ([lastScroll isEqualToDate:date]) {
        UIViewController *controller;
        int page = pageControl.currentPage;

        controller = [viewControllers objectAtIndex:page];
        if ([controller respondsToSelector:@selector(startImageDownloads)])
            [(GuideStepViewController *)controller startImageDownloads];
        
        if (page + 1 < [viewControllers count]) {
            controller = [viewControllers objectAtIndex:page+1];
            if ([controller respondsToSelector:@selector(startImageDownloads)])
                [(GuideStepViewController *)controller startImageDownloads];
        }
        if (page > 0) {
            controller = [viewControllers objectAtIndex:page-1];
            if ([controller respondsToSelector:@selector(startImageDownloads)])
                [(GuideStepViewController *)controller startImageDownloads];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
   
    // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
    // which a scroll event generated from the user hitting the page control triggers updates from
    // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
    if (pageControlUsed) {
        // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }
	
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
	
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    //[self performSelector:@selector(preloadForCurrentPage:) withObject:[NSNumber numberWithInt:page] afterDelay:0.1];
	[self preloadForCurrentPage:[NSNumber numberWithInt:page]];
	
    // Unload the views+controllers which are no longer visible
   for (int i = 2; i < pageControl.numberOfPages; i++) {
      float distance = fabs(page - i + 1);
      if (distance > 2.0) {
         UIViewController *vc = [viewControllers objectAtIndex:i];
         if ((NSNull *)vc != [NSNull null]) {
            [vc.view removeFromSuperview];
            vc.view = nil;
            [viewControllers replaceObjectAtIndex:i withObject:[NSNull null]];
         }
      }
   }
   
    // Save our state.
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setObject:[NSNumber numberWithInt:page] forKey:@"last_guide_page"];
	[prefs synchronize];
}

// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    pageControlUsed = NO;
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    pageControlUsed = NO;
}

- (IBAction)changePage:(id)sender {

    int page = pageControl.currentPage;
	
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    //[self performSelector:@selector(preloadForCurrentPage:) withObject:[NSNumber numberWithInt:page] afterDelay:0.1];
    [self preloadForCurrentPage:[NSNumber numberWithInt:page]];
    
	// update the scroll view to the appropriate page
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
   
    [scrollView scrollRectToVisible:frame animated:sender ? YES : NO];
    
	// Set the boolean used when scrolls originate from the UIPageControl. See scrollViewDidScroll: above.
    pageControlUsed = YES;
   
    // Save our state.
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setObject:[NSNumber numberWithInt:page] forKey:@"last_guide_page"];
	[prefs synchronize];
}

- (void)preloadForCurrentPage:(NSNumber *)pageNumber {
	int page = [pageNumber integerValue];
	
	[self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Landscape only until I work out the issues.
    return interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    self.guide = nil;
    [super dealloc];
}


@end
