//
//  GuideBookmarker.m
//  iFixit
//
//  Created by David Patierno on 4/6/11.
//  Copyright 2011 iFixit. All rights reserved.
//

#import "GuideBookmarker.h"
#import "GuideBookmarks.h"
#import "Guide.h"
#import "GuideImage.h"
#import "Config.h"
#import "iFixitAPI.h"
#import "User.h"
#import "LoginViewController.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GuideViewController.h"

@implementation GuideBookmarker

@synthesize delegate, iGuideid, poc, progress, lvc;

- (id)init {
    if ((self = [super init])) {
        LoginViewController *vc = [[LoginViewController alloc] init];
        vc.delegate = self;
        self.lvc = vc;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            UIPopoverController *pc = [[UIPopoverController alloc] initWithContentViewController:vc];
            self.poc = pc;
            [pc release];
        }
        else {
            self.poc = nil;
        }

        [vc release];
    }
    return self;
}

- (void)setNewGuideId:(NSNumber *)newGuideid {
    self.iGuideid = newGuideid;
    
    BOOL guideExists = [[GuideBookmarks sharedBookmarks] guideForGuideid:newGuideid] ? YES : NO;
    
    if ([delegate isKindOfClass:[GuideViewController class]]) {
        [delegate setOfflineGuide:guideExists];
    }
    
    if (![[GuideBookmarks sharedBookmarks] guideForGuideid:newGuideid]) {
        UIBarButtonItem *bookmarkButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Favorite", nil)
                                                                           style:UIBarButtonItemStyleBordered 
                                                                          target:self 
                                                                          action:@selector(bookmark:)];
        self.delegate.navigationItem.rightBarButtonItem = bookmarkButton;
        [bookmarkButton release];
    }
    else {
        [self bookmarked];
    }
}

- (void)bookmark:(UIBarButtonItem *)button {
    // Require a login
    if (![iFixitAPI sharedInstance].user) {
        // iPad is easy, just show the popover.
        if (poc) {
            if (poc.isPopoverVisible) {
                [poc dismissPopoverAnimated:YES];
            }
            else {
                [self resizePopoverViewControllerContents];
                [poc presentPopoverFromBarButtonItem:button permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            }
        }
        // On the iPhone, we need to first wrap the login view in a nav controller
        else {
            [iFixitAPI checkCredentialsForViewController:self];
        }
        
        return;
    }
    else {
        if (poc) {
            [poc dismissPopoverAnimated:YES];
            [lvc dismissModalViewControllerAnimated:YES];
        }
    }
    
    // Show a spinner
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    UIBarButtonItem *b = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    [spinner startAnimating];
    self.delegate.navigationItem.rightBarButtonItem = b;
    [b release];
    [spinner release];
    
    // Save online
    [[iFixitAPI sharedInstance] like:iGuideid forObject:self withSelector:@selector(liked:)];
}

// Resize the popover view controller contents
- (void)resizePopoverViewControllerContents {
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    poc.popoverContentSize = (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) ? CGSizeMake(320, screenSize.width / 2) : CGSizeMake(320, screenSize.height / 2);
}

- (void)liked:(NSDictionary *)result {
    if (![result[@"statusCode"] isEqualToNumber:@(204)]) {
        [iFixitAPI displayConnectionErrorAlert];
        [self setNewGuideId:iGuideid];
        [self bookmark:self.delegate.navigationItem.rightBarButtonItem];
        return;
    }
    
    // Show a progress bar
    UIView *progressContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 90, 40)];
    
    UILabel *progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, 90, 20)];
    progressLabel.textAlignment = UITextAlignmentCenter;
    progressLabel.font = [UIFont italicSystemFontOfSize:12.0f];
    progressLabel.backgroundColor = [UIColor clearColor];
    
    if ([Config currentConfig].site == ConfigMake || [Config currentConfig].site == ConfigMakeDev) {
        progressLabel.textColor = [UIColor darkGrayColor];
        progressLabel.shadowColor = [UIColor whiteColor];
    }
    else {
        progressLabel.textColor = [UIColor whiteColor];
        progressLabel.shadowColor = [UIColor darkGrayColor];
    }
    
    progressLabel.shadowOffset = CGSizeMake(0.0f, -1.0f);
    progressLabel.text = NSLocalizedString(@"Downloading...", nil);
    [progressContainer addSubview:progressLabel];
    [progressLabel release];
    
    UIProgressView *p = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 25, 85, 10)];
    [progressContainer addSubview:p];
    self.progress = p;
    [p release];
    
    UIBarButtonItem *progressItem = [[UIBarButtonItem alloc] initWithCustomView:progressContainer];
    self.delegate.navigationItem.rightBarButtonItem = progressItem;
    [progressItem release];
    [progressContainer release];
    
    // Save the guide in the bookmarks list.
    [[GuideBookmarks sharedBookmarks] addGuideid:iGuideid forBookmarker:self];
    
    // Analytics
    [[[GAI sharedInstance] defaultTracker] send:[[GAIDictionaryBuilder createEventWithCategory:@"Guide"
                                                                                        action:@"download"
                                                                                         label:@"Guide downloaded"
                                                                                         value:iGuideid] build]];
    
    
}

- (void)refresh {
    [self bookmark:nil];
}

- (void)bookmarked {
    // Change the button to a label.
    UILabel *bookmarkedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 40)];
    bookmarkedLabel.textAlignment = UITextAlignmentCenter;
    bookmarkedLabel.font = [UIFont italicSystemFontOfSize:14.0f];
    bookmarkedLabel.backgroundColor = [UIColor clearColor];
    
    if (([Config currentConfig].site == ConfigMake || [Config currentConfig].site == ConfigMakeDev) &&
     [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        bookmarkedLabel.textColor = [UIColor darkGrayColor];
        bookmarkedLabel.shadowColor = [UIColor whiteColor];
    }
    else {
        bookmarkedLabel.textColor = [UIColor whiteColor];
        bookmarkedLabel.shadowColor = [UIColor darkGrayColor];
    }
    
    bookmarkedLabel.shadowOffset = CGSizeMake(0.0f, -1.0f);
    bookmarkedLabel.text = [NSString stringWithFormat:@" %@", NSLocalizedString(@"Saved", nil)];
    
    UIBarButtonItem *bookmarkedItem = [[UIBarButtonItem alloc] initWithCustomView:bookmarkedLabel];
    self.delegate.navigationItem.rightBarButtonItem = bookmarkedItem;
    [bookmarkedItem release];
    [bookmarkedLabel release];
}

- (void)presentModalViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [delegate presentModalViewController:viewController animated:animated];
    [poc dismissPopoverAnimated:YES];
}

- (void)dealloc
{
    self.iGuideid = nil;
    self.progress = nil;
    self.poc = nil;
    self.lvc = nil;
    self.delegate = nil;
    
    [super dealloc];
}

@end
