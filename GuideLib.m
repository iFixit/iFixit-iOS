//
//  GuideLib.m
//  iFixit
//
//  Created by Stefan Ayala on 1/27/14.
//
//

#import "iFixit-Swift.h"
#import "GuideLib.h"
#import "GuideViewController.h"
#import "Reachability.h"

@implementation GuideLib

+(void)loadAndPresentGuideForGuideid:(NSNumber*)iGuideid {
    Guide *offlineGuide = [[GuideBookmarks sharedBookmarks] guideForGuideid:iGuideid];
    GuideViewController *vc;
    iFixitAppDelegate *appDelegate = (iFixitAppDelegate*)[UIApplication sharedApplication].delegate;
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    
    // Check to see if we have an offline guide first and load up the viewcontroller with it
    if (offlineGuide) {
        vc = [[GuideViewController alloc] initWithGuide:offlineGuide];
        vc.offlineGuide = YES;
        // No offline guide? Just use the guideid and retrieve info from API
    } else if (!internetStatus == NotReachable) {
        vc = [[GuideViewController alloc] initWithGuideid:iGuideid];
    } else {
        // No internet access or guides, let's display a connection alert and bail
        [iFixitAPI displayConnectionErrorAlert];
        return;
    }
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    [appDelegate.window.rootViewController presentModalViewController:nc animated:YES];
}
@end
