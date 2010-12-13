//
//  GuideViewController.h
//  iFixit
//
//  Created by David Patierno on 8/9/10.
//  Copyright 2010 iFixit. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Guide;

@interface GuideViewController : UIViewController <UIScrollViewDelegate> {
	UINavigationBar *navBar;
	UIScrollView *scrollView;
	UIPageControl *pageControl;
    NSMutableArray *viewControllers;
	UIActivityIndicatorView *spinner;
	
    // To be used when scrolls originate from the UIPageControl
    BOOL pageControlUsed;
    
    // Rate limit image loading.
    NSDate *lastScroll;
	
	Guide *guide;
    NSInteger guideid;
    NSInteger shouldLoadPage;
}

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, retain) IBOutlet UINavigationBar *navBar;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIPageControl *pageControl;
@property (nonatomic, retain) NSMutableArray *viewControllers;
@property (nonatomic, retain) Guide *guide;
@property (nonatomic, retain) NSDate *lastScroll;
@property (nonatomic) NSInteger guideid;
@property (nonatomic) NSInteger shouldLoadPage;

+ (GuideViewController *)initWithGuideid:(NSInteger)guideid;
- (void)loadScrollViewWithPage:(int)page;
- (void)preloadForCurrentPage:(NSNumber *)pageNumber;
- (IBAction)changePage:(id)sender;
- (void)showPage:(NSInteger)page;

@end
