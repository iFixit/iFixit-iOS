//
//  SSOViewController.m
//  iFixit
//
//  Created by David Patierno on 2/12/12.
//  Copyright (c) 2012 iFixit. All rights reserved.
//

class SSOViewController: SVWebViewController, UIAlertViewDelegate {
    
    var delegate: LoginViewControllerDelegate?

    func viewControllerForURL(url:String, delegate:LoginViewControllerDelegate) -> SVWebViewController {
        // First clear all cookies.
        let storage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in storage.cookies! {
            storage.deleteCookie(cookie)
        }
        
        // Set a custom cookie for simple success SSO redirect: sso-origin=SHOW_SUCCESS
        if let cookie = NSHTTPCookie(properties:
            [NSHTTPCookieName: "sso-origin",
                NSHTTPCookieValue:"SHOW_SUCCESS",
                NSHTTPCookieDomain: Config.currentConfig().host,
                NSHTTPCookiePath: "/"]) {
                    storage.setCookie(cookie)
        }
        
        let vc = SSOViewController(address:url)
        vc.delegate = delegate
        return vc
    }

    override func viewWillAppear(animated:Bool) {
        // Ensure we have a solid navigation bar
        self.navigationController!.navigationBar.translucent = false
    }

    override func webViewDidFinishLoad(vebView:UIWebView) {
        let config = Config.currentConfig()
        
        super.webViewDidFinishLoad(webView)
        
        let host = webView.request!.URL!.host
        if host == config.host || host == config.custom_domain {
            // Extract the sessionid.
            var sessionid:String? = nil
            let storage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
            for cookie in storage.cookies! {
                if cookie.name == "session" {
                    sessionid = cookie.value
                    break
                }
            }
            
            // Validate and obtain user data.
            iFixitAPI.sharedInstance.login(sessionId:sessionid!, handler:{ (results) in
                self.loginResults(results)
            })
        }
    }

    func loginResults(results:[String:AnyObject]?) {
        
        if results == nil {
            iFixitAPI.displayConnectionErrorAlert()
            return
        }
        
        if results!["error"] != nil {
            let alert = UIAlertView(title:NSLocalizedString("Error", comment:""),
                message:results!["msg"] as! String,
                delegate:self,
                cancelButtonTitle:nil,
                otherButtonTitles:NSLocalizedString("Okay", comment:""))
            alert.show()
        } else {
            self.dismissViewControllerAnimated(false, completion:{
                // The delegate is responsible for removing the login view.
                self.delegate!.refresh()
            })
        }
    }

    func alertView(alertView:UIAlertView, clickedButtonAtIndex buttonIndex:Int) {
        self.dismissViewControllerAnimated(true, completion:{})
    }

}
