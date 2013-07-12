//
//  GuideViewController.h
//  iFixit
//
//  Created by David Patierno on 8/9/10.
//  Copyright 2010 iFixit. All rights reserved.
//

@class Guide;
@class GuideBookmarker;

@interface GuideViewController : UIViewController <UIScrollViewDelegate> {
    // To be used when scrolls originate from the UIPageControl
    BOOL pageControlUsed;	
}

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, retain) IBOutlet UINavigationBar *navBar;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIPageControl *pageControl;
@property (nonatomic, retain) GuideBookmarker *bookmarker;
@property (nonatomic, retain) NSMutableArray *viewControllers;
@property (nonatomic, retain) Guide *guide;
@property (nonatomic) NSInteger guideid;
@property (nonatomic) NSInteger shouldLoadPage;
@property (nonatomic, retain) NSCache *memoryCache;

- (id)initWithGuide:(Guide *)guide;
- (id)initWithGuideid:(NSInteger)guideid;
- (id)initWithGuideid:(NSInteger)guideid guide:(Guide *)guide;
- (void)gotGuide:(Guide *)theGuide;
- (void)loadScrollViewWithPage:(int)page;
- (void)preloadForCurrentPage:(NSNumber *)pageNumber;
- (IBAction)changePage:(id)sender;
- (void)showPage:(NSInteger)page;

@end
