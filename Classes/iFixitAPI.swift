//
//  iFixitAPI.swift
//  iFixit
//
//  Created by David Patierno on 8/6/10.
//  Copyright 2010 iFixit. All rights reserved.
//

import Foundation
import Alamofire
import UIKit

class iFixitAPI: NSObject {

    var user:User?
    var appId:String!
    var userAgent:String?
    
    static var openConnections = 0
    
    class var sharedInstance: iFixitAPI {
        struct Static {
            static let instance = iFixitAPI()
        }
        return Static.instance
    }
    
    override init() {
        super.init()
        loadSession()
        loadAppId()
        createAndSetUserAgent()
    }

    // MARK: - Anonymous
    
    func sessionFilePath() -> String {
        let config = Config.currentConfig()
        let filename = "\(config.host!)_session.plist"
        
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let url = urls[urls.count-1]

        return url.URLByAppendingPathComponent(filename).path!
    }
    
    func loadAppId() {
        // look for the iFixit app id by default
        let plistPath = NSBundle.mainBundle().pathForResource("iFixit-App-Id", ofType: "plist")
        let appId = NSDictionary(contentsOfFile:plistPath!)?.valueForKey("ifixit") as? String
        
        self.appId = appId ?? ""
    }
    
    func saveSession() {
        if (self.user != nil) {
            // Write to disk
//            let dict = ["userJson" as NSObject: Utility.serializeDictionary(self.user!.data) as! AnyObject] as? NSDictionary
//            dict.writeToFile(sessionFilePath(), atomically:true)
        } else {
            // Clear the session
            do {
                try NSFileManager.defaultManager().removeItemAtPath(sessionFilePath())
            } catch {
                
            }
        }
    }
    
    func loadSession() {
        // Read from disk
        var data = NSDictionary(contentsOfFile: sessionFilePath()) as? [String:AnyObject]
        
        // Only deserialize json data if we need to
        if let jsonData = data,
            let userJson = jsonData["userJson"] {
            data = Utility.deserializeJsonString(userJson as! String)
        }
        
        self.user = data != nil ? User(dictionary:data!) : nil;
    }
    
    func commonHeaders(secure secure:Bool = false) -> [String:String] {
        var headers:[String:String] = [:]
        
        headers["User-Agent"] = userAgent
        if secure {
            headers["X-App-Id"] = self.appId
            headers["Authorization"] = "api \(self.user?.session)"
        }
        
//        if ([Config currentConfig].site == ConfigIFixitDev) {
//            request.validatesSecureCertificate = NO;
//        }
        
        return headers
    }
    
    func getSites(limit:Int, offset:Int, handler:(([Site]?) -> ())) {
        let config = Config.currentConfig()
        
        let url = "https://\(config.host!)/api/2.0/sites?limit=\(limit)&offset=\(offset)"

        Alamofire.request(.GET, url, headers:commonHeaders()).responseJSON {(req, resp, JSON) in
            if JSON.isSuccess {
                let value = JSON.value as! [[String:AnyObject]]
                let sites = value.map { Site(json:$0) }
                handler(sites)
            } else {
                handler(nil)
            }
        }
    }
    
    func getSiteInfo(handler:(([String:AnyObject]?) -> ())) {
        let config = Config.currentConfig()
        
        let url = "https://\(config.host!)/api/2.0/info"

        Alamofire.request(.GET, url, headers:commonHeaders(secure: true)).responseJSON {(req, resp, JSON) in
            if JSON.isSuccess {
                let value = JSON.value as! [String:AnyObject]
                handler(value)
            } else {
                handler(nil)
            }
        }
    }
    
    func getCollections(limit:Int, offset:Int, handler:(([[String:AnyObject]]?) -> ())) {
        let config = Config.currentConfig()
        
        let url = "https://\(config.host!)/api/2.0/collections?limit=\(limit)&offset=\(offset)"
        
        Alamofire.request(.GET, url, headers:commonHeaders(secure: true)).responseJSON {(req, resp, JSON) in
            if JSON.isSuccess {
                let value = JSON.value as! [[String:AnyObject]]
                handler(value)
            } else {
                handler(nil)
            }
        }
    }

    func getGuide(iGuideid:NSNumber, handler:((Guide?) -> ())) {
        let config = Config.currentConfig()
        
        let url = "https://\(config.host!)/api/2.0/guides/\(iGuideid)"
        
        Alamofire.request(.GET, url, headers:commonHeaders(secure: true)).responseJSON {(req, resp, JSON) in
            if JSON.isSuccess {
                let value = JSON.value as! [String:AnyObject]
                let guide = Guide(json: value)
                handler(guide)
            } else {
                handler(nil)
            }
        }
    }
    
    func getCategories(handler:(([String:AnyObject]?) -> ())) {
        let config = Config.currentConfig()
        // On iPhone and iPod touch, only show leaf nodes with viewable guides.
        let url = "https://\(config.host!)/api/2.0/categories?withDisplayTitles"
        
        Alamofire.request(.GET, url, headers:commonHeaders(secure: true)).responseJSON {(req, resp, JSON) in
            if JSON.isSuccess {
                let value = JSON.value as! [String:AnyObject]
                handler(value)
            } else {
                handler(nil)
            }
        }
    }
    
    func getCategory(category:String, handler:(([String:AnyObject]?) -> ())) {
        let config = Config.currentConfig()
        let language = Utility.getDeviceLanguage()
        
        let escapedCategory = category.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        
        let url = "https://\(config.host!)/api/2.0/wikis/CATEGORY/\(escapedCategory!)?langid=\(language)"
        
        Alamofire.request(.GET, url, encoding:.URLEncodedInURL, headers:commonHeaders(secure: true)).responseJSON {(req, resp, JSON) in
            if JSON.isSuccess {
                // Make writeable.
                let value = JSON.value as! [String:AnyObject]
                handler(value)
            } else {
                handler(nil)
            }
        }
    }
    
    func getGuides(type:String?, handler:(([Guide]?) -> ())) {
        let config = Config.currentConfig()
        let limit = 100;
        
        let url = "https://\(config.host!)/api/2.0/guides?limit=\(limit)"
        
        Alamofire.request(.GET, url, headers:commonHeaders(secure: true)).responseJSON {(req, resp, JSON) in
            if JSON.isSuccess {
                let value = JSON.value as! [[String:AnyObject]]
                let guides = value.map { Guide(json:$0) }
                
                handler(guides)
            } else {
                handler(nil)
            }
        }
    }
    
    func getGuides(ids guideids:[NSNumber], handler:(([String:AnyObject]?) -> ())) {
        let config = Config.currentConfig()
        let guideidsString = guideids.map { $0.description }.joinWithSeparator(",")
        let url = "https://\(config.host!)/api/2.0/guides?guideids=\(guideidsString)"
        
        Alamofire.request(.GET, url, headers:commonHeaders(secure: true)).responseJSON {(req, resp, JSON) in
            if JSON.isSuccess {
                let value = JSON.value as! [String:AnyObject]
                handler(value)
            } else {
                handler(nil)
            }
        }
    }
    
    func getSearchResults(search:String, filter:String, handler:(([String:AnyObject]?) -> ())) {
        let config = Config.currentConfig()
        
        let escapedSearch = search.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        let escapedFilter = filter.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())

        let url = "https://\(config.host!)/api/2.0/search/\(escapedSearch!)?limit=50&filter=\(escapedFilter!)"
        
        Alamofire.request(.GET, url, encoding:.URLEncodedInURL, headers:commonHeaders(secure: true)).responseJSON {(req, resp, JSON) in
            if JSON.isSuccess {
                let value = JSON.value as! [String:AnyObject]
                handler(value)
            } else {
                handler(nil)
            }
        }
    }
    
    // MARK: - Session management
    
    func checkLogin(results:[String:AnyObject]) {
        if let _ = results["authToken"] {
            self.user = User(dictionary:results)
            saveSession()
        }
    }
    
    func checkSession(results:[String:AnyObject]) {
        // Check for invalid sessionid
        if let _ = results["error"],
            let msg = results["msg"] as? String {
                if msg == "Authentication needed" || msg == "Invalid login" {
                    self.user = nil
                    saveSession()
                }
        }
    }
    
    // MARK: - Login, Register and Logout API
    
    func login(sessionId sessionId:String, handler:(([String:AnyObject]?) -> ())) {
        let config = Config.currentConfig()
        
        // .dozuki.com hosts force SSL, so we match that here. Otherwise, for SSO sites with custom domains,
        // SSL doesn't exist so we just use HTTP.
        let url = "https://\(config.host!)/api/2.0/user"

//        request.useCookiePersistence = NO;
        
        Alamofire.request(.GET, url, headers:commonHeaders(secure: true)).responseJSON {(req, resp, JSON) in
            if JSON.isSuccess {
                let value = JSON.value as! [String:AnyObject]
                self.checkLogin(value)
                handler(value)
            } else {
                let error = JSON.error as? NSError
                let value = ["error": 1, "msg": error?.localizedDescription as! AnyObject]
                handler(value)
            }
        }
    }
    
    func login(name login:String, password:String, handler:(([String:AnyObject]?) -> ())) {
        let config = Config.currentConfig()
        
        let url = "https://\(config.host!)/api/2.0/user/token"

        let parameters = ["email": login, "password": password]
        
//        if ([Config currentConfig].site == ConfigIFixitDev || [Config currentConfig].site == ConfigMakeDev)
//        request.useCookiePersistence = NO;
        
        Alamofire.request(.POST, url, encoding:.JSON, parameters:parameters, headers:commonHeaders(secure: true)).responseJSON {(req, resp, JSON) in
            if JSON.isSuccess {
                let value = JSON.value as! [String:AnyObject]
                self.checkLogin(value)
                handler(["type":"login"])
            } else {
//                let value = JSON.value as! [String:AnyObject]
                let error = JSON.error as? NSError
                let value = ["error": 1, "msg": error?.localizedDescription as! AnyObject]
                handler(value)
            }
        }
    }
    
    func register(login login:String, password:String, name:String, handler:(([String:AnyObject]?) -> ())) {
        let config = Config.currentConfig()
        
        let url = "https://\(config.host!)/api/2.0/users"

        let parameters = ["email" : login, "username" : name, "password" : password]
        
//        if ([Config currentConfig].site == ConfigIFixitDev || [Config currentConfig].site == ConfigMakeDev)
//        request.useSessionPersistence = NO;
//        request.useCookiePersistence = NO;

        Alamofire.request(.POST, url, encoding:.JSON, parameters:parameters, headers:commonHeaders(secure: true)).responseJSON {(req, resp, JSON) in
            if JSON.isSuccess {
                let value = JSON.value as! [String:AnyObject]
                self.checkLogin(value)
                handler(["type":"register"])
            } else {
                let error = JSON.error as? NSError
                let value = ["error": 1, "msg": error?.localizedDescription as! AnyObject]
                handler(value)
            }
        }
    }
    
    func logout() {
        let config = Config.currentConfig()
        
        // Clear all cookies.
        let storage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in storage.cookies! {
            storage.deleteCookie(cookie)
        }
        
        let url = "https://\(config.host!)/api/2.0/user/token"
        
        Alamofire.request(.DELETE, url, headers:commonHeaders(secure: true))
        
        self.user = nil
        saveSession()
        
        // Reset GuideBookmarks static object.
        GuideBookmarks.reset()
    }
    
    // MARK: - Authenticated
    
    func getUserFavorites(handler:(([[String:AnyObject]]?) -> ())) {
        let config = Config.currentConfig()
        
        let url = "https://\(config.host!)/api/2.0/user/favorites/guides"
        
//        request.useCookiePersistence = NO;

        Alamofire.request(.GET, url, headers:commonHeaders(secure: true)).responseJSON {(req, resp, JSON) in
            if JSON.isSuccess {
                let value = JSON.value as! [[String:AnyObject]]
                self.checkSession(value[0])
                handler(value)
            } else {
                let error = JSON.error as? NSError
                let value = [["error": 1, "msg": error?.localizedDescription as! AnyObject]]
                handler(value)
            }
        }
    }
    
    func like(iGuideid:NSNumber, handler:(([String:AnyObject]?) -> ())) {
        let config = Config.currentConfig()
        
        let url = "https://\(config.host!)/api/2.0/user/favorites/guides/\(iGuideid)"
        
        //        request.useCookiePersistence = NO;

        Alamofire.request(.PUT, url, headers:commonHeaders(secure: true)).responseJSON {(req, resp, JSON) in
            if JSON.isSuccess {
                let value = ["statusCode": resp?.statusCode as! AnyObject]
                self.checkSession(value)
                handler(value)
            } else {
                let error = JSON.error as? NSError
                let value = ["error": 1, "msg": error?.localizedDescription as! AnyObject]
                handler(value)
            }
        }
    }
    
    func unlike(iGuideid:NSNumber, handler:(([String:AnyObject]?) -> ())) {
        let config = Config.currentConfig()
        
        let url = "https://\(config.host!)/api/2.0/user/favorites/guides/\(iGuideid)"
        
        Alamofire.request(.DELETE, url, headers:commonHeaders(secure: true)).responseJSON {(req, resp, JSON) in
            if JSON.isSuccess {
                let value = ["statusCode": resp?.statusCode as! AnyObject]
                self.checkSession(value)
                handler(value)
            } else {
                let error = JSON.error as? NSError
                let value = ["error": 1, "msg": error?.localizedDescription as! AnyObject]
                handler(value)
            }
        }
    }
    
    // MARK: - Error handling
    
    // Display an alert that allows the user to retry the connection
    class func displayConnectionErrorAlert() {
        let alert = UIAlertView(title:NSLocalizedString("Error", comment:""),
            message:NSLocalizedString("Unable to connect. Check your Internet connection and try again.", comment:""),
            delegate:self,
            cancelButtonTitle:NSLocalizedString("OK", comment:""))
        alert.show()
    }
    
    // MARK: - Authentication Handling
    
    class func checkCredentialsForViewController(viewController:LoginViewControllerDelegate) {
        let viewControllerToPresent:UIViewController!
        
        if (iFixitAPI.sharedInstance.user != nil) {
            viewControllerToPresent = BookmarksViewController(nibName:"BookmarksView", bundle:nil)
        } else {
            viewControllerToPresent = LoginViewController()
            (viewControllerToPresent as! LoginViewController).delegate = viewController as! LoginViewControllerDelegate
        }
        
        // Create the animation ourselves to mimic a modal presentation
        // On iPad we must push the view onto a stack, instead of presenting
        // it modally or else undesired side effects occur
        if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
            // TODO viewController.popViewControllerAnimated(false)
            UIView.animateWithDuration(0.7, animations: { () -> Void in
                // TODO viewController.pushViewController(viewControllerToPresent, animated:false)
// TODO                 UIView.setAnimationTransition(.CurlUp, forView: viewController.view, cache: true)
            })
        } else {
            // Wrap this in a navigation controller to avoid side effects from new status bar in iOS7
            let nvc = UINavigationController(rootViewController:viewControllerToPresent)
            viewController.presentViewController(nvc, animated: true, completion:{})
        }
    }
    
    // Build our own custom user agent and set it
    func createAndSetUserAgent() {
        let bundle = NSBundle(forClass:self.dynamicType)
        let appName = bundle.objectForInfoDictionaryKey("CFBundleDisplayName")
        let marketingVersionNumber = bundle.objectForInfoDictionaryKey("CFBundleShortVersionString")
        let developmentVersionNumber = bundle.objectForInfoDictionaryKey("CFBundleVersion")
        
        let device = UIDevice.currentDevice()
        let locale = NSLocale.currentLocale().localeIdentifier
        
        // iFixitiOS/1.4 (43) | iPad; Mac OS X 10.5.7; en_GB
        self.userAgent = "\(appName!)iOS/\(developmentVersionNumber!) (\(marketingVersionNumber!)) | \(device.model); \(device.systemName) \(device.systemVersion); \(locale)"
    }
    
}
