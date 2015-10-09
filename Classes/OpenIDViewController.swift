//
//  OpenIDViewController.m
//  iFixit
//
//  Created by David Patierno on 2/4/12.
//  Copyright (c) 2012 iFixit. All rights reserved.
//


class OpenIDViewController : SVWebViewController, UIAlertViewDelegate {
    
    var delegate: LoginViewControllerDelegate?

    class func viewControllerForHost(host: String, delegate:LoginViewControllerDelegate) -> SVWebViewController {
        let config = Config.currentConfig()
        
        // First clear all cookies.
        let storage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        if let cookies = storage.cookies {
            for cookie in cookies {
                storage.deleteCookie(cookie)
            }
        }
    
        let url = "\(config.baseURL)/login/openid?host=\(host)"
        let vc = OpenIDViewController(address:url)
        vc.delegate = delegate
        return vc
    }

    override func webViewDidFinishLoad(webView: UIWebView) {
        super.webViewDidFinishLoad(webView)
        
        let body = webView.stringByEvaluatingJavaScriptFromString("document.documentElement.innerHTML")
        if (body?.containsString("loggedIn") != nil) {
            // Extract the sessionid.
            var sessionid: String? = nil
                if let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies {
                for cookie in cookies {
                    if cookie.name == "session" {
                        sessionid = cookie.value
                        break
                    }
                }
            }
            
            // Validate and obtain user data.
            //        [[iFixitAPI sharedInstance] loginWithSessionId:sessionid forObject:self withSelector:@selector(loginResults:)];
            iFixitAPI.sharedInstance.login(sessionId: sessionid!, handler:{ (results) in
                self.loginResults(results)
            })
        }
    }

    func loginResults(results:[String:AnyObject]?) {
        
        if results == nil {
            iFixitAPI.displayConnectionErrorAlert()
            return
        }
        
        if (results!["error"] != nil) {
            let alert = UIAlertView(title: NSLocalizedString("Error", comment: ""), message: results![
                "msg"] as! String, delegate: self, cancelButtonTitle: nil, otherButtonTitles: NSLocalizedString("Okay", comment: ""))
            alert.show()
        } else {
            self.dismissViewControllerAnimated(true, completion: {
                // The delegate is responsible for removing the login view.
                self.delegate!.refresh()
            })
        }
    }

    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        self.dismissViewControllerAnimated(true, completion: {})
    }

}
