//
//  DozukiSelectSiteViewController.m
//  iFixit
//
//  Created by David Patierno on 8/16/11.
//  Copyright (c) 2011 iFixit. All rights reserved.
//

class DozukiSelectSiteViewController: UITableViewController, UIAlertViewDelegate, UISearchBarDelegate {
    
    let SITES_REQUEST_LIMIT = 500
    
    var searchBar: UISearchBar!
    var searchResults: [Site]?
    var simple = false
    
    var loading = false
    var hasMoreSites = false
    var searching = false
    var noResults = false
    
    // Dismiss the keyboard when searchBar resigns first responder.
    override func disablesAutomaticKeyboardDismissal() -> Bool {
        return false
    }

    func storedListPath() -> NSURL {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let url = urls[urls.count-1]
        
        return url.URLByAppendingPathComponent("dozukiSitePlist.plist")
}

    func loadMore() {
        if (!loading) {
            let config = Config.currentConfig()
            
            config.sites = []
            config.prioritySites = []

            loading = true
            self.showLoading()
            
            iFixitAPI.sharedInstance.getSites(SITES_REQUEST_LIMIT, offset:config.sites.count,
                handler:{ (results) in self.gotSites(results) })
        }
    }

    init(simple:Bool) {

        super.init(nibName:nil, bundle:nil)
        
        // Custom initialization
        hasMoreSites = true
        self.simple = simple
        self.title = NSLocalizedString("Choose a Site", comment:"")
        self.loadMore()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }

    func showLoading() {
        loading = true
        let container = UIView(frame:CGRectMake(0.0, 0.0, 28.0, 20.0))
        let spinner = UIActivityIndicatorView(frame:CGRectMake(0.0, 0.0, 20.0, 20.0))
        spinner.activityIndicatorViewStyle = UIDevice.currentDevice().userInterfaceIdiom == .Pad ? .Gray : .White
        container.addSubview(spinner)
        spinner.startAnimating()
        
        let button = UIBarButtonItem(customView:container)
        self.navigationItem.rightBarButtonItem = button
    }
    
    func hideLoading() {
        loading = false
        self.navigationItem.rightBarButtonItem = nil
    }
    
    func gotSites(theSites:[Site]?) {
        let config = Config.currentConfig()

        self.hideLoading()
        
        let count = theSites?.count
        
        if (theSites != nil && count != 0) {
            hasMoreSites = count! == SITES_REQUEST_LIMIT
            
            // Insert these new rows at the bottom.
            var paths: [NSIndexPath] = []
            for i in 0 ..< count {
                paths.append(NSIndexPath(forRow: (i + count), inSection: 0))
                
                // Check for priority sites and separate them off
                let site = theSites![i]
                if (site.priority && !site.hideFromiOS) {
                    config.prioritySites.append(site)
                }
            }
            
            // Populate the non-priority sites list.
            for site in theSites! {
                if (site.priority == false && site.hideFromiOS == false) {
                    config.sites.append(site)
                }
            }
            
            self.tableView.reloadData()
            
            // Cache to disk.
            let  dict:[String:AnyObject] = ["prioritySites": config.prioritySites,
                "sites" : config.sites]

 // TODO           dict.writeToFile(self.storedListPath(), atomically:true)
        } else {
            hasMoreSites = false
            if config.sites.count != 0 {
                return
            }
            
            // If we failed to get fresh data, use the cached site list if available.
            let  dict = NSDictionary(contentsOfURL:self.storedListPath())
            if config.sites.count == 0 && dict != nil {
                config.sites = dict?["sites"] as! [Site]
                config.prioritySites = dict?["prioritySites"] as! [Site]
                self.tableView.reloadData()
            } else {
                let alert = UIAlertView(title:NSLocalizedString("Could not load site list.", comment:""),
                    message:NSLocalizedString("Please check your internet connection and try again.", comment:""),
                    delegate:self,
                    cancelButtonTitle:NSLocalizedString("Cancel", comment:""),
                    otherButtonTitles:NSLocalizedString("Retry", comment:""))
                alert.show()
            }
        }
    }
    
    func alertView(alertView:UIAlertView, clickedButtonAtIndex buttonIndex:Int) {
        if (buttonIndex != 0) {
            self.loadMore()
        }
    }

    // MARK: - View lifecycle

    override func viewWillAppear(animated:Bool) {
        let config = Config.currentConfig()

        if config.sites.count == 0 {
           self.loadMore()
        }
    }

    override func viewDidLoad() {
        let config = Config.currentConfig()
        
        super.viewDidLoad()
        
        let app = UIApplication.sharedApplication()
        
        app.statusBarHidden = false
        
        if (config.site == .Magnolia) {
            app.statusBarStyle = .Default
        } else {
            app.statusBarStyle = .LightContent
        }
        
        // Add the search bar
        searchBar = UISearchBar(frame:CGRectMake(0.0, 0.0, 320.0, 36.0))
        searchBar.placeholder = NSLocalizedString("Search", comment:"")
        searchBar.delegate = self
        self.tableView.tableHeaderView = searchBar
        searchBar.autocorrectionType = .No
        
        // For iOS 7 we want a different color scheme because the default colors are too aggressive
        UINavigationBar.appearance().barTintColor = config.toolbarColor
        self.navigationController!.navigationBar.translucent = false
        UINavigationBar.appearance().titleTextAttributes =
        [ NSForegroundColorAttributeName : config.textColor ]
        
        UINavigationBar.appearance().tintColor = config.buttonColor
        
        self.navigationItem.leftBarButtonItem!.tintColor = config.buttonColor
        self.navigationItem.rightBarButtonItem!.tintColor = config.buttonColor
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"Back",
        style:.Plain, target:nil, action:nil)
        
        // Update loading display status.
        if (loading) {
            self.showLoading()
        }
    }

    func searchBarTextDidBeginEditing(theSearchBar:UISearchBar) {
        searchBar.setShowsCancelButton(true, animated:true)
    }

    func searchBarTextDidEndEditing(theSearchBar:UISearchBar) {
        if theSearchBar.text == "" {
            searching = false
            noResults = false
            self.tableView.reloadData()
        }
        
        searchBar.setShowsCancelButton(false, animated:true)
        
        // Animate the table back down.
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            UIView.beginAnimations("showSearch", context:nil)
            UIView.setAnimationDuration(0.3)
            var bounds = self.navigationController!.view.bounds
            bounds.origin.y = 0.0
            self.navigationController!.view.bounds = bounds
            UIView.commitAnimations()
        }
    }

    func searchBar(searchBar:UISearchBar, textDidChange searchText:String) {
        let config = Config.currentConfig()

        if searchText == "" {
            searching = false
            noResults = false
            self.tableView.reloadData()
            self.searchResults = []
            return
        }
        
        if (!searching) {
            searching = true
            self.tableView.reloadData()
        }
        
        // Do the search in-memory.
        self.searchResults = []
        let combinedSites = config.prioritySites + config.sites
        
        for site in combinedSites {
            var range = site.title?.rangeOfString(searchText, options:.CaseInsensitiveSearch)
            if range != nil {
                searchResults?.append(site)
            } else {
                range = site.siteDescription?.rangeOfString(searchText, options:.CaseInsensitiveSearch)
                if range != nil {
                    searchResults?.append(site)
                }
            }
        }
        
        noResults = searchResults?.count == 0
        
        self.tableView.reloadData()
    }

    func searchBarCancelButtonClicked(theSearchBar:UISearchBar) {
        searchBar.text = ""
        noResults = false
        self.view.endEditing(true)
    }

    func searchBarSearchButtonClicked(theSearchBar:UISearchBar) {
        self.view.endEditing(true)
    }

    override func scrollViewDidScroll(scrollView:UIScrollView) {
         searchBar.setShowsCancelButton(false, animated:false)
        var bounds = self.navigationController!.view.bounds
        bounds.origin.y = 0.0
        self.navigationController!.view.bounds = bounds
        
        self.view.endEditing(true)
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let config = Config.currentConfig()
        
        if (searching) {
            if (searchResults?.count != 0) {
                return (searchResults?.count)!
            } else if (noResults) {
                return 1
            } else {
                return 0
            }
        }
        
        if (simple && config.prioritySites.count != 0) {
            return config.prioritySites.count + 1
        }
        
        return config.sites.count
    }

    override func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
        let config = Config.currentConfig()
        let CellIdentifier = "Cell"
        
        var cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier)
        if (cell == nil) {
            cell = UITableViewCell(style:.Subtitle, reuseIdentifier:CellIdentifier)
        }
        
        if (searching) {
            if searchResults!.count != 0 {
                let results = searchResults![indexPath.row]
                cell?.textLabel?.text = results.title
                cell?.detailTextLabel?.text = results.siteDescription
            } else {
                cell?.textLabel?.text = NSLocalizedString("No Results Found", comment:"")
                cell?.detailTextLabel?.text = nil
            }
            cell?.accessoryType = .None
        } else {
            let sitesArray = simple ? config.prioritySites : config.sites
            
            // Configure the cell...
            if (simple && indexPath.row == sitesArray.count) {
                cell?.textLabel?.text = NSLocalizedString("More Sites...", comment:"")
                cell?.detailTextLabel?.text = nil
                cell?.accessoryType = .DisclosureIndicator
            }
            else {
                let site = sitesArray[indexPath.row]
                cell?.textLabel?.text = site.title
                cell?.detailTextLabel?.text = site.siteDescription
                cell?.accessoryType = .None
            }
        }
        
        return cell!
    }

    // MARK: - Table view delegate

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let config = Config.currentConfig()

        self.tableView.deselectRowAtIndexPath(indexPath, animated:true)
        
        if (searching && searchResults?.count == 0) {
            return
        }
        
        var sitesArray:[Site]!
        if (searching) {
            sitesArray = searchResults
        } else if (simple) {
            sitesArray = config.prioritySites
        } else {
            sitesArray = config.sites
        }
        
        if (!searching && simple && indexPath.row == sitesArray.count) {
            let vc = DozukiSelectSiteViewController(simple:false)
            self.navigationController!.pushViewController(vc, animated:true)
        } else {
            let site = sitesArray[indexPath.row]
            
            let appDelegate = UIApplication.sharedApplication().delegate as! iFixitAppDelegate
            appDelegate.loadSite(site)
        }
    }

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let config = Config.currentConfig()
        
        // Load the next batch if we're near the bottom.
        if indexPath.row >= config.sites.count - 1 && hasMoreSites && !loading {
            self.loadMore()
        }
    }

}
