//
//  BookmarksViewController.m
//  iFixit
//
//  Created by David Patierno on 4/4/11.
//  Copyright 2011 iFixit. All rights reserved.
//

import UIKit
//import GoogleAnalytics

class BookmarksViewController : UITableViewController, LoginViewControllerDelegate, UIActionSheetDelegate {

    var bookmarks:[String: [Guide]] = [:]
    var lvc: LoginViewController!
    var devices:[String] = []
    var editButton: UIBarButtonItem!
    var listViewController:ListViewController!

    override init(nibName:String?, bundle:NSBundle?) {
        
        super.init(nibName:nibName, bundle:bundle)
        
        self.title = NSLocalizedString("Favorites", comment:"")
        
        let vc = LoginViewController()
        vc.delegate = self
        self.lvc = vc
        self.devices = []
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector:"refresh",
                                                         name:GuideBookmarksUpdatedNotification,
                                                         object:nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func refreshHierarchy() {
        
        var b:[String:[Guide]] = [:]
        
        // Construct the key-value list by device name.
        let allBookmarks = GuideBookmarks.sharedBookmarks()?.guides.values
        
        for guideData in allBookmarks! {
            let guide = Guide(json:guideData as! [String : AnyObject])
            if b.indexForKey(guide.category) == nil {
                b[guide.category] = []
            }
            
            b[guide.category]?.append(guide)
        }
        
        // Sort everything.
//        b.values.sort { $0.subject < $1.subject }
        
        self.bookmarks = b
        self.devices = Array(bookmarks.keys) // TODO .sort { $0.lowerCase < $1.lowerCase }
        
        dispatch_sync(dispatch_get_main_queue(), {
            if self.bookmarks.keys.count != 0 {
                self.tableView.tableFooterView = nil
            } else {
                // If there are no bookmarks, display a brief message.
                let footer = UIView(frame:CGRectMake(0, 0, 320, 100))
                let label = UILabel(frame:CGRectMake(20, 0, 280, 110))
                label.autoresizingMask = .FlexibleWidth
                label.textAlignment = .Center
                label.numberOfLines = 5
                label.textColor = UIColor.darkGrayColor()
                label.shadowOffset = CGSizeMake(0.0, -1.0)
                label.shadowColor = UIColor.whiteColor()
                label.backgroundColor = UIColor.clearColor()
                label.text = NSLocalizedString("You haven't saved any guides for offline view yet. When you do, they'll appear here.", comment:"")
                footer.addSubview(label)
                self.tableView.tableFooterView = footer
            }
            
            self.tableView.reloadData()
        })
        
    }

    override func didReceiveMemoryWarning() {
        // Releases the view if it doesn't have a superview.
        super.didReceiveMemoryWarning()
        
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - View lifecycle

    func headerView() -> UIView {
        let config = Config.currentConfig()
        let b = UIButton(frame:CGRectMake(0, 0, 320, 40))
        
        b.backgroundColor = config.toolbarColor
        
        if (config.site == .Zeal || config.site == .Magnolia) {
            b.backgroundColor = UIColor(red:0.0, green:0.0, blue:0.0, alpha:1.0)
        }
        
        b.titleLabel?.font = UIFont.boldSystemFontOfSize(14)
        b.titleLabel?.shadowColor = UIColor.blackColor()
        b.titleLabel?.shadowOffset = CGSizeMake(0, 1)
        b.titleLabel?.backgroundColor = UIColor.clearColor()
        b.titleLabel?.textColor = UIColor.whiteColor()
        
        b.setTitle(String(format:NSLocalizedString("LOGOUT", comment:""), (iFixitAPI.sharedInstance.user?.username)!), forState:.Normal)
        
        b.addTarget(self, action:"logout", forControlEvents:.TouchUpInside)
        
        return b
    }

    func applyPaddedFooter() {
        let footer = UIView(frame:CGRectMake(0, 0, 1, 45))
        footer.backgroundColor = UIColor.clearColor()
        self.tableView.tableFooterView = footer
    }

    func configureEditButton() {
        let barButtonItem = UIBarButtonItem(title:NSLocalizedString("Edit", comment:""), style:.Plain, target:self, action:"toggleEdit")
        
        self.editButton = barButtonItem
        self.navigationItem.rightBarButtonItem = self.editButton
    }

    func toggleEdit() {
        self.tableView.setEditing(!self.tableView.editing, animated:true)
        
        self.navigationItem.rightBarButtonItem?.title = self.tableView.editing ? NSLocalizedString("Done", comment:"") : NSLocalizedString("Edit", comment:"")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user = iFixitAPI.sharedInstance.user
        
        // Uncomment the following line to preserve selection between presentations.
        // self.clearsSelectionOnViewWillAppear = NO;
        
        if UIDevice.currentDevice().userInterfaceIdiom != .Pad {
            self.applyPaddedFooter()
        }
        
        self.configureEditButton()
        
        self.navigationItem.rightBarButtonItem = user != nil ?
        self.editButton : nil
        
        self.tableView.tableHeaderView = user != nil ? self.headerView() : nil
        
        // Make room for the toolbar
        if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 44, 0)
            self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 44, 0)
        }
        else {
            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 32, 0)
            self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 32, 0)
        }
        
        let button = UIBarButtonItem(title:NSLocalizedString("Done", comment:""),
                                                                   style:.Plain,
                                                                  target:self,
                                                                  action:"doneButtonPushed")
        
        self.navigationItem.leftBarButtonItem = button
        
        self.configureAppearance()
    }

// iOS 7
    func configureAppearance() {
        self.navigationController?.navigationBar.translucent = false
    }

    func doneButtonPushed() {
        // Create the animation ourselves to mimic a modal presentation
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            UIView.animateWithDuration(0.7,
                             animations:{
                                 UIView.setAnimationTransition(.CurlDown, forView:self.navigationController!.view, cache:true)
                             })
            self.navigationController?.popViewControllerAnimated(false)
        } else {
            self.dismissViewControllerAnimated(true, completion:nil)
        }
        
        self.listViewController.configureProperties()
    }

    override func viewWillAppear(animated: Bool) {
        // Show login view if needed.
        if iFixitAPI.sharedInstance.user == nil {
            lvc.view.frame = self.view.frame;
            self.view.addSubview(lvc.view)
        } else {
            if self.view.subviews.contains(lvc.view) {
                lvc.view.removeFromSuperview()
            }
            
            GuideBookmarks.sharedBookmarks()!.update()
        }
    }

    override func willRotateToInterfaceOrientation(toInterfaceOrientation:UIInterfaceOrientation, duration:NSTimeInterval) {
        // Make room for the toolbar
        if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 44, 0);
            self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 44, 0);
        }
        else {
            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 32, 0);
            self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 32, 0);
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView:UITableView) -> Int {
        // Return the number of sections.
        return bookmarks.keys.count
    }

    override func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
        // Return the number of rows in the section.
        let key = devices[section]
        return bookmarks[key]?.count ?? 0
    }

    override func tableView(tableView:UITableView, titleForHeaderInSection section:Int) -> String {
        // Sort by device name.
        return devices[section]
    }

    override func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let CellIdentifier = "Cell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier, forIndexPath:indexPath)
        
        // Configure the cell...
        let key = devices[indexPath.section]
        let guide = bookmarks[key]![indexPath.row]
        
        // Display the "thing" if possible, otherwise fallback to the full title.
        cell.textLabel!.text = (guide.subject != nil && guide.subject != "") ? guide.subject : guide.title
        
        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(tableView:UITableView, canEditRowAtIndexPath indexPath:NSIndexPath) -> Bool {
        return true
    }

    // Override to support editing the table view.
    override func tableView(tableView:UITableView, commitEditingStyle editingStyle:UITableViewCellEditingStyle, forRowAtIndexPath indexPath:NSIndexPath) {
        
        switch editingStyle {
            
        case .Delete:
            let key = devices[indexPath.section]
            var section = bookmarks[key]
            let guide = section![indexPath.row]
            
            // Delete from bookmarks file
            GuideBookmarks.sharedBookmarks()?.removeGuide(guide)
            
            // Delete the row from the data source
            section?.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation:.Fade)
            
            // Delete the section if there are no guides left.
            if section!.count == 0 {
                devices.removeAtIndex(indexPath.section)
                bookmarks[key] = nil
                tableView.deleteSections(NSIndexSet(index:indexPath.section), withRowAnimation:.Fade)
            }
            
        case .Insert:
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            break
            
        default:
            break
        }
    }

    // MARK: - Table view delegate

    override func tableView(tableView:UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath) {
        let key = devices[indexPath.section]
        let guide = bookmarks[key]![indexPath.row]
        
        let vc = GuideViewController(guide:guide)
        let nvc = UINavigationController(rootViewController:vc)
        vc.offlineGuide = true
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            self.navigationController?.presentViewController(nvc, animated:true, completion:nil)
        } else {
            // TODO
//            let povc = self.splitViewController?.viewControllers[1].popOverController
//            
//            if povc.popoverVisible() {
//                povc.dismissPopoverAnimated(false)
//            }
            
            let delegate = UIApplication.sharedApplication().delegate as! iFixitAppDelegate
            delegate.window?.rootViewController?.presentViewController(nvc, animated:true, completion:nil)
        }
        
        // Refresh any changes.
        GuideBookmarks.sharedBookmarks()?.addGuideid(guide.iGuideid)
        
        tableView.deselectRowAtIndexPath(indexPath, animated:true)
    }

    func dismissView() {
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.navigationController?.popViewControllerAnimated(true)
        } else {
            self.dismissViewControllerAnimated(true, completion:nil)
        }
    }

    func refresh() {
        let user = iFixitAPI.sharedInstance.user
        
        // Show or hide login as needed.
        if (user == nil) {
            self.dismissView()
        } else {
            if self.view.subviews.contains(lvc.view) {
                GuideBookmarks.sharedBookmarks()?.update()
            }
        }
        
        self.navigationItem.rightBarButtonItem = user != nil ?
        self.editButton : nil
        
        self.performSelectorInBackground("refreshHierarchy", withObject:nil)
        
        self.tableView.tableHeaderView = self.headerView()
    }

    func logout() {
        let sheet = UIActionSheet(title:nil, delegate:self,
                                  cancelButtonTitle:NSLocalizedString("Cancel", comment:""),
                                  destructiveButtonTitle:NSLocalizedString("Logout", comment:""),
                                                  otherButtonTitles:"")
        sheet.showFromRect(self.tableView.tableHeaderView!.frame, inView:self.view, animated:true)
    }

    func actionSheet(actionSheet:UIActionSheet, clickedButtonAtIndex buttonIndex:Int) {
        let config = Config.currentConfig()
        if (buttonIndex != 0) {
            return
        }
        
        iFixitAPI.sharedInstance.logout()
        
        // Analytics
        let iUserId = iFixitAPI.sharedInstance.user?.iUserid
        let gaInfo = GAIDictionaryBuilder.createEventWithCategory("User", action:"Logout", label:"User logged out", value:iUserId).build()
        GAI.sharedInstance().defaultTracker.send(gaInfo as [NSObject:AnyObject])

        // Set bookmarks to be nil and reload the tableView to release the cells
        bookmarks = [:]
        self.tableView.reloadData()
        
        // Remove the edit button.
        self.navigationItem.rightBarButtonItem = nil
        
        // On Dozuki App
        let delegate = UIApplication.sharedApplication().delegate as! iFixitAppDelegate
        if (config.dozuki && config.`private`) {
            delegate.showDozukiSplash()
            // On a custom private app
        } else if (config.`private`) {
            delegate.showSiteSplash()
            // Everyone else who is public
        } else {
            self.dismissView()
        }
    }

}
