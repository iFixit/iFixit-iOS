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
#import "GuideBookmarker.h"
#import "Config.h"
#import "UIImage+Coder.m"
#import "Guide.h"
#import "GANTracker.h"

@implementation GuideViewController

@synthesize navBar, scrollView, pageControl, viewControllers, spinner, bookmarker;
@synthesize guide=_guide;
@synthesize guideid=_guideid;
@synthesize shouldLoadPage;

- (id)initWithGuide:(Guide *)guide {
    return [self initWithGuideid:0 guide:guide];
}
- (id)initWithGuideid:(NSInteger)guideid {
    return [self initWithGuideid:guideid guide:nil];
}
- (id)initWithGuideid:(NSInteger)guideid guide:(Guide *)guide {
    if ((self = [super initWithNibName:@"GuideView" bundle:nil])) {
        self.guide = guide;
        self.guideid = guide ? guide.guideid : guideid;
        self.shouldLoadPage = 0;
        self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        
        GuideBookmarker *b = [[GuideBookmarker alloc] init];
        b.delegate = self;
        self.bookmarker = b;
        [b release];
        
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        
        [TestFlight passCheckpoint:@"Guide View"];
        [[GANTracker sharedTracker] trackPageview:[NSString stringWithFormat:@"/guide/view/%d", self.guideid] withError:NULL];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Replace black with concrete.
    UIColor *bgColor = [Config currentConfig].backgroundColor;
    if ([bgColor isEqual:[UIColor whiteColor]])
        bgColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"concreteBackgroundWhite.png"]];
    else
        bgColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"concreteBackground.png"]];
    
    self.view.backgroundColor = bgColor;

    navBar.tintColor = [Config currentConfig].toolbarColor;
    
    if (self.guide) {
        [self gotGuide:self.guide];
    }
    else {
        // Load the data
        [[iFixitAPI sharedInstance] getGuide:self.guideid forObject:self withSelector:@selector(gotGuide:)];
    }
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        
        // Landscape        
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            spinner.frame = CGRectMake(494.0, 333.0, 37.0, 37.0);
        }
        // Portrait
        else {
            spinner.frame = CGRectMake(365.0, 450.0, 37.0, 37.0);
        }
        
    }
    
    // TODO: Show step that was in view before memory warning
}

- (void)closeGuide {
    if (bookmarker.poc.isPopoverVisible)
        [bookmarker.poc dismissPopoverAnimated:YES];
    
    // Hide the guide.
    [self dismissModalViewControllerAnimated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // Try Again
    if (buttonIndex) {
        [[iFixitAPI sharedInstance] getGuide:self.guideid forObject:self withSelector:@selector(gotGuide:)];
    }
    // Cancel
    else {
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (void)adjustScrollViewContentSizeForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	NSInteger numPages = [self.guide.steps count] + 1;
    CGRect frame;

    // iPad
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        // Landscape
        if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
            spinner.frame = CGRectMake(494.0, 333.0, 37.0, 37.0);
            frame = CGRectMake(0, 44, 1024, 768 - 44);
        }
        // Portrait
        else {
            spinner.frame = CGRectMake(365.0, 450.0, 37.0, 37.0);
            frame = CGRectMake(0, 44, 768, 1024 - 44);
        }        
    }
    // iPhone
    else {        
        // Landscape
        if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
            frame = CGRectMake(0, 44, 480, 320 - 44);
        }
        // Portrait
        else {
            frame = CGRectMake(0, 44, 320, 480 - 64);
        }
    }

    scrollView.frame = frame;
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * numPages, scrollView.frame.size.height);
}

- (void)gotGuide:(Guide *)guide {
	[spinner stopAnimating];

    if (!guide) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Network Error"
                                                            message:@"Failed loading guide."
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Try Again", nil];
        [alertView show];
        [alertView release];
        return;
    }
    
	self.guide = guide;

	// Steps plus one for intro
	NSInteger numPages = [self.guide.steps count] + 1;
	
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
    [self adjustScrollViewContentSizeForInterfaceOrientation:self.interfaceOrientation];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    scrollView.delegate = self;
	
	// Steps plus one for intro
    pageControl.numberOfPages = numPages;
    pageControl.currentPage = 0;
    
    // Hide page control on iPhone.
    //pageControl.hidden = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) ? NO : YES;
	
    // Setup the navigation items to show back arrow and bookmarks button
    NSString *title = guide.title;
    if ([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad && [guide.subject length] > 0)
        title = self.guide.subject;
    
	UINavigationItem *thisItem = [[UINavigationItem alloc] initWithTitle:title];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self action:@selector(closeGuide)];
    thisItem.leftBarButtonItem = doneButton;
    [doneButton release];
    [bookmarker setNavItem:thisItem andGuideid:self.guide.guideid];
    
	NSArray *navItems = [NSArray arrayWithObjects:thisItem, nil];
	[navBar setItems:navItems animated:NO];
	[thisItem release];
   
    if (shouldLoadPage) {
      
       [self showPage:shouldLoadPage];
      
    } else {
      
       [self loadScrollViewWithPage:0];
       [self loadScrollViewWithPage:1];

    }
    
}

- (void)showPage:(NSInteger)page {
    if (self.guide) {
        pageControl.currentPage = page;
        [self changePage:nil];
    } else {
        shouldLoadPage = page;
    }
}

- (void)loadScrollViewWithPage:(int)page {

    if (page < 0 || page >= pageControl.numberOfPages)
       return;
	
	NSInteger stepNumber = page - 1;
	
    // replace the placeholder if necessary
    UIViewController *controller = [viewControllers objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null]) {
		if (stepNumber == -1) {
			controller = [[GuideIntroViewController alloc] initWithGuide:self.guide];
            ((GuideIntroViewController *)controller).delegate = self;
		} else {
			controller = [[GuideStepViewController alloc] initWithStep:[self.guide.steps objectAtIndex:stepNumber]];
            ((GuideStepViewController *)controller).delegate = self;
		}

        [viewControllers replaceObjectAtIndex:page withObject:controller];
        [controller release];
    }
	
    // add the controller's view to the scroll view
    if (nil == controller.view.superview) {
        CGRect frame = scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        [controller willRotateToInterfaceOrientation:self.interfaceOrientation duration:0];
        [scrollView addSubview:controller.view];
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
}

- (void)preloadForCurrentPage:(NSNumber *)pageNumber {
	int page = [pageNumber integerValue];
	
	[self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // iPad any orientation.
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        return YES;
    
    // iPhone Portrait+Landscape.
    return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self adjustScrollViewContentSizeForInterfaceOrientation:toInterfaceOrientation];
    
    for (int i=0; i<[viewControllers count]; i++) {
        UIViewController *vc = [viewControllers objectAtIndex:i];
        
        if ((NSNull *)vc != [NSNull null]) {
            CGRect frame = scrollView.frame;
            frame.origin.x = frame.size.width * i;
            frame.origin.y = 0;
            
            vc.view.frame = frame;
            [vc willRotateToInterfaceOrientation:toInterfaceOrientation duration:0];
        }
    }
    
    [self showPage:pageControl.currentPage];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    self.spinner = nil;
    self.navBar = nil;
    self.scrollView = nil;
    self.pageControl = nil;
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    self.spinner = nil;
    self.navBar = nil;
    self.scrollView = nil;
    self.pageControl = nil;

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [_guide release];
    
    [spinner release];
    [navBar release];
    [scrollView release];
    [pageControl release];
    [bookmarker release];
    // TODO: Figure out why this crashes.
    //[viewControllers release];
     
    [UIApplication sharedApplication].idleTimerDisabled = NO;
     
    [super dealloc];
}


@end
