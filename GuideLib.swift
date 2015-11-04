//
//  GuideLib.m
//  iFixit
//
//  Created by Stefan Ayala on 1/27/14.
//
//

class GuideLib: NSObject {

    class func loadAndPresentGuideForGuideid(iGuideid: Int) {
        let offlineGuide = GuideBookmarks.sharedBookmarks()?.guideForGuideid(iGuideid)
        let vc: GuideViewController!
        let appDelegate = UIApplication.sharedApplication().delegate as! iFixitAppDelegate
        
        let reachability = Reachability.reachabilityForInternetConnection()
        let internetStatus = reachability.currentReachabilityStatus()
        
        // Check to see if we have an offline guide first and load up the viewcontroller with it
        if (offlineGuide != nil) {
            vc = GuideViewController(guide:offlineGuide!)
            vc.offlineGuide = true
            // No offline guide? Just use the guideid and retrieve info from API
        } else if (internetStatus != .NotReachable) {
            vc = GuideViewController(guideid:iGuideid)
        } else {
            // No internet access or guides, let's display a connection alert and bail
            iFixitAPI.displayConnectionErrorAlert()
            return
        }
        
        let nc = UINavigationController(rootViewController:vc)
        appDelegate.window!.rootViewController!.presentViewController(nc, animated:true, completion:nil)
    }

}
