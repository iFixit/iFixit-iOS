//
//  LoginViewController.m
//  iFixit
//
//  Created by David Patierno on 5/4/11.
//  Copyright 2011 iFixit. All rights reserved.
//

class LoginViewController: UITableViewController, UITextFieldDelegate, UIGestureRecognizerDelegate, LoginViewControllerDelegate {

    var delegate: LoginViewControllerDelegate?
    var message:String!
    var loading: WBProgressHUD?
    var showRegister = false
    var modal = false

    var emailField: UITextField?
    var passwordField: UITextField?
    var passwordVerifyField: UITextField?
    var fullNameField: UITextField?
    var listViewController: ListViewController!

    var loginButton: UIButton?
    var registerButton: UIButton?
    var cancelButton: UIButton?
    var googleButton: UIButton!
    var yahooButton: UIButton!

    init() {
        super.init(style:.Grouped)
        // Custom initialization
        self.message = NSLocalizedString("Favorites are saved offline and synced across devices.", comment:"")
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }

    func textFieldDidBeginEditing(textField:UITextField) {
        UIView.beginAnimations("repositionForm", context:nil)
        UIView.setAnimationDuration(0.3)
        self.tableView.contentInset = UIEdgeInsetsMake(-60, 0, 0, 0)
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 215, 0)
        self.tableView.scrollRectToVisible(CGRectMake(0.0, 60.0, 320.0, 100.0), animated:true)
        UIView.commitAnimations()
    }

    func textFieldDidEndEditing(textField:UITextField) {
        self.performSelector("showMessage", withObject:nil, afterDelay:0.1)
    }

    func showMessage() {
        if (emailField!.isFirstResponder() || passwordField!.isFirstResponder() ||
            passwordVerifyField!.isFirstResponder() || fullNameField!.isFirstResponder()) {
            return
        }
        
        UIView.beginAnimations("repositionForm", context:nil)
        UIView.setAnimationDuration(0.3)
        self.tableView.contentInset = UIEdgeInsetsMake(5, 0, 0, 0)
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 0, 0)
        UIView.commitAnimations()
    }

    func textFieldShouldReturn(textField:UITextField) -> Bool {
        if (emailField?.text?.isEmpty ?? true) {
            emailField?.becomeFirstResponder()
        }
        else if (passwordField?.text?.isEmpty ?? true) {
            passwordField?.becomeFirstResponder()
        }
        else if (showRegister && passwordVerifyField?.text?.isEmpty ?? true) {
            passwordVerifyField?.becomeFirstResponder()
        }
        else if (showRegister && fullNameField?.text?.isEmpty ?? true) {
            fullNameField?.becomeFirstResponder()
        }
        else if (showRegister) {
            sendRegister()
        }
        else {
            sendLogin()
        }
        
        return true
    }

    func showLoading() {
        if (loading == nil) {
            self.loading = WBProgressHUD()
        }
        
        let width = CGFloat(160.0)
        let height = CGFloat(120.0)
        self.loading?.frame = CGRectMake((self.view.frame.size.width - width) / 2.0,
                                        (self.view.frame.size.height - height) / 4.0,
                                        width,
                                        height)
        
        // Hide the keyboard and prevent further editing.
        self.view.userInteractionEnabled = false
        self.view.endEditing(true)
        
        loading?.showInView(self.tableView)
    }

    func hideLoading() {
        loading?.removeFromSuperview()
        
        // Allow editing again.
        self.view.userInteractionEnabled = true
    }

    override func didReceiveMemoryWarning() {
        // Releases the view if it doesn't have a superview.
        super.didReceiveMemoryWarning()
        
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK - View lifecycle

    func createMessage() -> UIView {
        let container = UIView(frame:CGRectMake(0, 0, 320, 120))
        
        let l = UILabel(frame:CGRectMake(20, 5, 280, 30))
        l.autoresizingMask = .FlexibleWidth
        l.textAlignment = .Center
        l.backgroundColor = UIColor.clearColor()
        l.font = UIFont.systemFontOfSize(14.0)
        l.textColor = UIColor.darkGrayColor()
        l.shadowColor = UIColor.whiteColor()
        l.shadowOffset = CGSizeMake(0.0, 1.0)
        l.numberOfLines = 0
        l.text = message
        
        container.addSubview(l)
        l.sizeToFit()
        
        // Center and size the frames appropriately.
        var frame = l.frame
        frame.origin.x = (320 - frame.size.width) / 2
        container.frame = CGRectMake(0, 0, 320, frame.size.height + 10)
        l.frame = frame
        
        return container
    }

    func createActionButtons() -> UIView {
        let config = Config.currentConfig()
        let container = UIView(frame:CGRectMake(0, 0, 320, 200))
        
        // Login
        
        let lb = UIButton(type:.RoundedRect)
        lb.frame = CGRectMake(10,0,300,45)
        lb.autoresizingMask = .FlexibleWidth
        lb.titleLabel?.font = UIFont.boldSystemFontOfSize(18.0)
        lb.titleLabel?.shadowColor = UIColor.blackColor()
        lb.titleLabel?.shadowOffset = CGSizeMake(0.0, -1.0)
        lb.setBackgroundImage(UIImage(named:"login.png")!.stretchableImageWithLeftCapWidth(150, topCapHeight:22), forState:.Normal)
        lb.setTitle(NSLocalizedString("Login", comment:""), forState:.Normal)
        lb.contentMode = .ScaleToFill
        lb.addTarget(self, action:"sendLogin", forControlEvents:.TouchUpInside)
        lb.setTitleColor(UIColor.whiteColor(), forState:[.Normal, .Highlighted])
        
        // Adjust the frame for modal sheet presentation.
        if UIApplication.sharedApplication().delegate?.window??.rootViewController is LoginBackgroundViewController {
            lb.frame = CGRectMake(30, 0, 260, 45)
        }
        
        // Register
        let rb = UIButton(type:.RoundedRect)
        rb.frame = CGRectMake(10, 55, 300, 45)
        rb.autoresizingMask = .FlexibleWidth
        rb.titleLabel?.font = UIFont.boldSystemFontOfSize(18.0)
        rb.titleLabel?.shadowColor = UIColor.blackColor()
        rb.titleLabel?.shadowOffset = CGSizeMake(0.0, -1.0)
        rb.setTitleColor(UIColor.whiteColor(), forState:[.Normal, .Highlighted])
        rb.setBackgroundImage(UIImage(named:"register.png")!.stretchableImageWithLeftCapWidth(150, topCapHeight:22), forState:.Normal)
        
        rb.setTitle(NSLocalizedString("Create an Account", comment:""), forState:.Normal)
        lb.contentMode = .ScaleToFill
        rb.addTarget(self, action:"toggleRegister", forControlEvents:.TouchUpInside)
        
        // Update buttons for iOS 7 only, remove this when we come up with a more permanent button design.
        rb.backgroundColor = UIColor.whiteColor()
        rb.setBackgroundImage(nil, forState:[.Normal, .Highlighted])
        rb.setTitleColor(config.buttonColor, forState:[.Normal, .Highlighted])
        
        lb.backgroundColor = UIColor.whiteColor()
        lb.titleLabel?.textColor = nil
        lb.setBackgroundImage(nil, forState:[.Normal, .Highlighted])
        lb.setTitleColor(config.buttonColor, forState:[.Normal, .Highlighted])
        
        // Special colors for MJTrimming
        if (config.site == .Mjtrim) {
            lb.setTitleColor(config.toolbarColor, forState:[.Normal, .Highlighted])
            rb.setTitleColor(config.toolbarColor, forState:[.Normal, .Highlighted])
        }
        
        // Cancel
        let cb = UIButton(frame:CGRectMake(10, 55, 300, 35))
        cb.autoresizingMask = .FlexibleWidth
        cb.titleLabel?.font = UIFont.systemFontOfSize(16.0)
        cb.titleLabel?.shadowOffset = CGSizeMake(0.0, 1.0)
        
        cb.setTitle(NSLocalizedString("Cancel", comment:""), forState:.Normal)
        cb.setTitleColor(UIColor.grayColor(), forState:.Normal)
        cb.setTitleShadowColor(UIColor.whiteColor(), forState:.Normal)
        cb.addTarget(self, action:"toggleRegister", forControlEvents:.TouchUpInside)
        cb.alpha = 0.0
        
        // Google
        let gb = UIButton(frame:CGRectMake(10, 110, 140, 50))
        gb.setBackgroundImage(UIImage(named:"login-google.png"), forState:.Normal)
        gb.autoresizingMask = .FlexibleRightMargin
        gb.addTarget(self, action:"tapGoogle", forControlEvents:.TouchUpInside)
        
        // Yahoo
        let yb = UIButton(frame:CGRectMake(165, 110, 143, 50))
        yb.setBackgroundImage(UIImage(named:"login-yahoo.png"), forState:.Normal)
        yb.autoresizingMask = .FlexibleLeftMargin
        yb.addTarget(self, action:"tapYahoo", forControlEvents:.TouchUpInside)
        
        self.loginButton = lb
        self.registerButton = rb
        self.cancelButton = cb
        self.googleButton = gb
        self.yahooButton = yb
        
        container.addSubview(loginButton!)
        
        if (config.sso == nil && !config.`private`) {
            container.addSubview(registerButton!)
            container.addSubview(cancelButton!)
            
            // This is horrible, we should be respecting the feature switch instead of hardcoding this.
            if (config.site != .DripAssist) {
                container.addSubview(googleButton)
                container.addSubview(yahooButton)
            }
        }
        
        return container
    }

    func tapGoogle() {
        let openIdViewController = OpenIDViewController.viewControllerForHost("google", delegate:delegate!)
        
        presentOpenIdViewController(openIdViewController)
    }
    
    func presentOpenIdViewController(openIdViewController:OpenIDViewController) {
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            // Special case if our delegate is a list due to being on an iPad
            if self.delegate is ListViewController {
                let appDelegate = UIApplication.sharedApplication().delegate as? iFixitAppDelegate
                appDelegate?.presentViewController(openIdViewController, animated:true, completion:nil)
            } else {
                delegate?.presentViewController(openIdViewController, animated:true, completion:nil)
            }
        } else {
            openIdViewController.delegate = self
            let nvc = UINavigationController(rootViewController:openIdViewController)
            presentViewController(nvc, animated:true, completion:nil)
        }
    }

    func tapYahoo() {
        let openIdViewController = OpenIDViewController.viewControllerForHost("yahoo", delegate:delegate!)
        
        presentOpenIdViewController(openIdViewController)
    }

    func toggleRegister() {
        showRegister = !showRegister
        
        let indexPaths = [ NSIndexPath(forRow:2, inSection:0),
                               NSIndexPath(forRow:3, inSection:0) ]
        
        if (showRegister) {
            self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation:.Fade)
            UIView.beginAnimations("showRegister", context:nil)
            UIView.setAnimationDuration(0.3)
            
            // Hide login
            loginButton?.alpha = 0.0
            googleButton.alpha = 0.0
            yahooButton.alpha = 0.0
            
            // Move Register up, change text, and change target
            var frame = registerButton?.frame
// TODO            frame.origin.y = 0
            registerButton?.frame = frame!
            registerButton?.setTitle(NSLocalizedString("Register", comment:""), forState:.Normal)
            registerButton?.removeTarget(self, action:nil, forControlEvents:.TouchUpInside)
            registerButton?.addTarget(self, action:"sendRegister", forControlEvents:.TouchUpInside)
            
            // Show Cancel
            cancelButton?.alpha = 1.0
            
            UIView.commitAnimations()
        }
        else {
            self.tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation:.Fade)
            UIView.beginAnimations("showRegister", context:nil)
            UIView.setAnimationDuration(0.3)
            
            // Show Login
            loginButton?.alpha = 1.0
            googleButton.alpha = 1.0
            yahooButton.alpha = 1.0
            
            // Move Register down, change text, and change target
            var frame = registerButton?.frame
// TODO             frame.origin.y = 55
            registerButton?.frame = frame!
            registerButton?.setTitle(NSLocalizedString("Create an Account", comment:""), forState:.Normal)
            registerButton?.removeTarget(self, action:nil, forControlEvents:.TouchUpInside)
            registerButton?.addTarget(self, action:"toggleRegister", forControlEvents:.TouchUpInside)

            
            // Hide Cancel
            cancelButton?.alpha = 0.0
            
            UIView.commitAnimations()
        }
        
        // Change the password action item from "Done" to "Next" or back again.
        passwordField?.returnKeyType = showRegister ? .Next : .Done
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("Login", comment:"")
        self.tableView.backgroundView = nil
        self.view.backgroundColor = UIColor(red:0.86, green:0.86, blue:0.86, alpha:1.0)
        
        self.tableView.tableHeaderView = createMessage()
        self.tableView.tableFooterView = createActionButtons()
        
        self.tableView.contentInset = UIEdgeInsetsMake(5, 0, 0, 0)
        self.tableView.separatorStyle = .None
        
        // Adds ability to check when a user touches UITableView only
        let tapGesture = UITapGestureRecognizer(target:self,
                                              action:"tableViewTapped:")
        
        tapGesture.delegate = self
        self.tableView.addGestureRecognizer(tapGesture)
        
        configureAppearance()
        configureLeftBarButtonItem()
    }

    func configureLeftBarButtonItem() {
        let config = Config.currentConfig()

        let button:UIBarButtonItem!
        
        if ((config.site == .Dozuki && modal) || (config.site == .Dozuki && delegate is iFixitAppDelegate)) {
            let icon = UIImage(named:"backtosites.png")
            button = UIBarButtonItem(image:icon, style:.Plain,
                                                     target:delegate,
                                                     action:"showDozukiSplash")
            
        } else {
            button = UIBarButtonItem(title:NSLocalizedString("Done", comment:""),
                                                      style:.Done,
                                                     target:self,
                                                     action:"doneButtonPushed")
        }
        
        self.navigationItem.leftBarButtonItem = button
    }

    func doneButtonPushed() {
        // Create the animation ourselves to mimic a modal presentation
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            UIView.animateWithDuration(0.7,
                             animations:{
                                 UIView.setAnimationTransition(.CurlDown, forView:self.navigationController!.view, cache:true)
                             })
            navigationController?.popViewControllerAnimated(false)
        } else {
            dismissViewControllerAnimated(true, completion:nil)
        }
    }

    func configureAppearance() {
        self.navigationController!.navigationBar.translucent = false
    }

    func gestureRecognizer(gestureRecognizer:UIGestureRecognizer, shouldReceiveTouch touch:UITouch) -> Bool {
        // If the user is trying to select a button on the tableview, don't return the touch event
        return (touch.view is UIButton) == false
    }

    func tableViewTapped(tapGesture:UITapGestureRecognizer) {
        // Remove keyboard
        self.view.endEditing(true)
    }

    // MARK - Table view data source

    override func tableView(tableView:UITableView, titleForHeaderInSection section:Int) -> String {
        return NSLocalizedString("Login", comment:"")
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section:Int) -> Int {
        if (Config.currentConfig().sso != nil) {
            return 0
        }
        
        // Return the number of rows in the section.
        return showRegister ? 4 : 2
    }

    func inputFieldForRow(row:Int) -> UITextField {
        
        let inputField = UITextField()
        inputField.font = UIFont.systemFontOfSize(16.0)
        inputField.adjustsFontSizeToFitWidth = true
        inputField.textColor = UIColor.darkGrayColor()
        var rect = CGRectMake(120, 12, 175, 30)
        
        if (row == 0) {
            if emailField != nil {
                return emailField!
            }
            
            self.emailField = inputField
            rect.origin.y += 1
            inputField.frame = rect
            inputField.placeholder = NSLocalizedString("email@example.com", comment:"")
            inputField.keyboardType = .EmailAddress
            inputField.autocapitalizationType = .None
            inputField.returnKeyType = .Next
        }
        else if (row == 1) {
            if passwordField != nil {
                passwordField?.returnKeyType = showRegister ? .Next : .Done
                return passwordField!
            }
            
            self.passwordField = inputField
            inputField.frame = rect
            inputField.placeholder = NSLocalizedString("Required", comment:"")
            inputField.keyboardType = .Default
            inputField.returnKeyType = showRegister ? .Next : .Done
            inputField.secureTextEntry = true
        }
        else if (row == 2) {
            if (passwordVerifyField != nil) {
                return passwordVerifyField!
            }
            
            self.passwordVerifyField = inputField
            inputField.frame = rect
            let again = NSLocalizedString("again", comment:"")
            inputField.placeholder = "(\(again))"
            inputField.keyboardType = .Default
            inputField.returnKeyType = .Next
            inputField.secureTextEntry = true
        }
        else if (row == 3) {
            if (fullNameField != nil) {
                return fullNameField!
            }
            
            self.fullNameField = inputField
            inputField.frame = rect
            inputField.placeholder = "John Doe"
            inputField.keyboardType = .Default
            inputField.returnKeyType = .Done
        }
        
        inputField.backgroundColor = UIColor.clearColor()
        inputField.autocorrectionType = .No
        inputField.autocapitalizationType = .Words
        inputField.textAlignment = .Left
        inputField.delegate = self
        inputField.tag = 0
        
        inputField.clearButtonMode = .Never
        inputField.enabled = true
        
        return inputField
    }

    override func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
        let CellIdentifier = "Cell"
        
        var cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier)
        if (cell == nil) {
            cell = UITableViewCell(style:.Default, reuseIdentifier:CellIdentifier)
            cell?.selectionStyle = .None
        }
        
        // Set the label
        let textLabels = ["Email", "Password", "Password", "Your Name"]
        cell?.textLabel?.text = NSLocalizedString(textLabels[indexPath.row], comment:"")
        
        // Add the text field
        for v in cell!.subviews {
            if v is UITextField {
                v.removeFromSuperview()
            }
        }
        
        cell?.contentView.addSubview(self.inputFieldForRow(indexPath.row))
        
        return cell!
    }

    // MARK - Table view delegate

    func sendLogin() {
        let config = Config.currentConfig()
        
        if (config.sso != nil) {
            let vc = SSOViewController.viewControllerForURL(config.sso!, delegate:self)
            let nvc = UINavigationController(rootViewController:vc)
            presentViewController(nvc, animated:true, completion:nil)
            
            return
        }
        
        if (emailField?.text?.isEmpty ?? true || passwordField?.text?.isEmpty ?? true) {
            return
        }
        
        showLoading()
        iFixitAPI.sharedInstance.login(name:emailField!.text!, password:passwordField!.text!, handler:{ (results) in
            self.loginResults(results)
        })
    }

    func refresh() {
        dismissViewAndRefreshDelegate()
    }

    func sendRegister() {
        if (emailField?.text?.isEmpty ?? true
            || passwordField?.text?.isEmpty ?? true
            || passwordVerifyField?.text?.isEmpty ?? true
            || fullNameField?.text?.isEmpty ?? true) {
            let alert = UIAlertView(title:NSLocalizedString("More information needed", comment:""),
                                    message:NSLocalizedString("Please fill out all the information.", comment:""),
                                                           delegate:nil,
                                                  cancelButtonTitle:nil,
                                    otherButtonTitles:NSLocalizedString("Okay", comment:""))
            alert.show()
        }
        else if passwordVerifyField?.text != passwordField?.text {
            let alert = UIAlertView(title:NSLocalizedString("Error", comment:""),
                                    message:NSLocalizedString("Passwords don't match", comment:""),
                                                           delegate:nil,
                                                  cancelButtonTitle:nil,
                                    otherButtonTitles:NSLocalizedString("Okay", comment:""))
            alert.show()
        } else {
            showLoading()
            iFixitAPI.sharedInstance.register(login:emailField!.text!, password:passwordField!.text!, name:fullNameField!.text!, handler:{ (results) in
                self.loginResults(results)
            })
        }
    }

    func loginResults(results:[String:AnyObject]?) {
        hideLoading()
        
        if (results == nil) {
            iFixitAPI.displayConnectionErrorAlert()
            return
        }
        
        if results!["authToken"] == nil {
            let alert = UIAlertView(title:NSLocalizedString("Error", comment:""),
                                                            message:results!["message"] as! String,
                                                           delegate:nil,
                                                  cancelButtonTitle:nil,
                                    otherButtonTitles:NSLocalizedString("Okay", comment:""))
            alert.show()
        } else {
            // Analytics
            let userId = iFixitAPI.sharedInstance.user?.iUserid
            let gaInfo = GAIDictionaryBuilder.createEventWithCategory("User", action:"Login", label:"User logged in", value:userId).build()
            GAI.sharedInstance().defaultTracker.send(gaInfo as [NSObject:AnyObject])
            
            emailField?.resignFirstResponder()
            passwordField?.resignFirstResponder()
            passwordVerifyField?.resignFirstResponder()
            fullNameField?.resignFirstResponder()
            
            dismissViewAndRefreshDelegate()
        }
    }

    func dismissViewAndRefreshDelegate() {
        // If we are dealing with the app delegate, we don't dismiss anything, just refresh it
        if delegate is iFixitAppDelegate {
            delegate?.refresh()
        } else if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.listViewController.popViewControllerAnimated(true)
            delegate?.refresh()
        } else {
            dismissViewControllerAnimated(true, completion:{
                delegate?.refresh()
            })
        }
    }

}
