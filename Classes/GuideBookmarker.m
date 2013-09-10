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
#import "GANTracker.h"

@implementation GuideBookmarker

@synthesize delegate, navItem, guideid, poc, progress, lvc;

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

- (void)setNavItem:(UINavigationItem *)newNavItem andGuideid:(NSInteger)newGuideid {
    self.navItem = newNavItem;
    self.guideid = [NSNumber numberWithInt:newGuideid];
    
    if (![[GuideBookmarks sharedBookmarks] guideForGuideid:guideid]) {
        UIBarButtonItem *bookmarkButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Favorite", nil)
                                                                           style:UIBarButtonItemStyleBordered 
                                                                          target:self 
                                                                          action:@selector(bookmark:)];
        if ([Config currentConfig].buttonColor) {
            bookmarkButton.tintColor = [Config currentConfig].buttonColor;
        }
        navItem.rightBarButtonItem = bookmarkButton;
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
            UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:lvc];
            nvc.navigationBar.tintColor = [UIColor blackColor];
            nvc.title = NSLocalizedString(@"Login", nil);
            
            lvc.modal = YES;
            [delegate presentModalViewController:nvc animated:YES];
            
            // Add a Cancel button
            UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(hideLogin)];
            lvc.navigationItem.leftBarButtonItem = cancelButton;
            [cancelButton release];
            
            [nvc release];
        }
        return;
    }
    else {
        if (poc) {
            [poc dismissPopoverAnimated:YES];
            [lvc dismissModalViewControllerAnimated:YES];
        }
        else {
            [lvc dismissModalViewControllerAnimated:YES];
            [self performSelector:@selector(hideLogin) withObject:nil afterDelay:0.5];
        }
    }
    
    // Show a spinner
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    UIBarButtonItem *b = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    [spinner startAnimating];
    navItem.rightBarButtonItem = b;
    [b release];
    [spinner release];
    
    // Save online
    [[iFixitAPI sharedInstance] like:guideid forObject:self withSelector:@selector(liked:)];
}

// Resize the popover view controller contents
- (void)resizePopoverViewControllerContents {
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    poc.popoverContentSize = (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) ? CGSizeMake(320, screenSize.width / 2) : CGSizeMake(320, screenSize.height / 2);
}
- (void)hideLogin {
    [lvc dismissModalViewControllerAnimated:YES];
}

- (void)liked:(NSDictionary *)result {
    if (!result) {
        [iFixitAPI displayConnectionErrorAlert];
        return;
    }
    
    // Session error. Retry.
    if ([result valueForKey:@"error"]) {
        [self setNavItem:navItem andGuideid:[guideid intValue]];
        [self bookmark:navItem.rightBarButtonItem];
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
    navItem.rightBarButtonItem = progressItem;
    [progressItem release];
    [progressContainer release];
    
    // Save the guide in the bookmarks list.
    [[GuideBookmarks sharedBookmarks] addGuideid:guideid forBookmarker:self];
    
    // Analytics
    [[GANTracker sharedTracker] trackPageview:[NSString stringWithFormat:@"/guide/download/%@", guideid] withError:NULL];
    [[GANTracker sharedTracker] trackPageview:@"/guide/download" withError:NULL];
}

- (void)refresh {
    [self bookmark:nil];
}

- (void)bookmarked {
    // Just hide.
    //navItem.rightBarButtonItem = nil;
    //return;

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
    navItem.rightBarButtonItem = bookmarkedItem;
    [bookmarkedItem release];
    [bookmarkedLabel release];
}

- (void)presentModalViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [delegate presentModalViewController:viewController animated:animated];
    [poc dismissPopoverAnimated:YES];
}

- (void)dealloc
{
    self.navItem = nil;
    self.guideid = nil;
    self.progress = nil;
    self.poc = nil;
    self.lvc = nil;
    self.delegate = nil;
    
    [super dealloc];
}

@end
