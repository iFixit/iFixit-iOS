//
//  CategoriesViewController.m
//  iFixit
//
//  Created by David Patierno on 8/6/10.
//  Copyright iFixit 2010. All rights reserved.
//

class CategoriesViewController : UIViewController, UISearchBarDelegate, UIAlertViewDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, ZBarReaderDelegate {

    let TOPICS = "TOPICS"
    let CATEGORIES = "categories"
    let DEVICES = "devices"
    
    var delegate: NSObject
    @IBOutlet weak var searchBar:UISearchBar!
    @IBOutlet weak var scannerBarView:UIView!
    @IBOutlet weak var scannerIcon: UIImageView!
    @IBOutlet weak var tableView:UITableView!

    var searching = false

    var searchResults:[String: [[String: AnyObject]]] = [:]
    var noResults = false
    var currentSearchTerm:String?

    var categories:[String: [Category]]?
    var categoryTypes:[String] = []
    var categoryResults:[String: AnyObject] = [:]
    var listViewController:ListViewController!
    var categorySearchResult: [String: AnyObject]?
    var categoryMetaData:Category?

    var searchViewEnabled = false

    override init(nibName:String?, bundle:NSBundle?) {
        super.init(nibName:nibName, bundle:bundle)
        self.categories = nil
        self.searching = false
        searchResults = [:]
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View lifecycle

    override func viewWillAppear(animated:Bool) {
        if self.categories == nil {
            self.getAreas()
        }
    }

    func orientationChanged(notification:NSNotification?) {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone && searchViewEnabled {
            self.enableSearchView(true)
        }
    }

    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation:UIInterfaceOrientation) {
        self.orientationChanged(nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                 selector:"orientationChanged:",
                                                     name:UIDeviceOrientationDidChangeNotification,
                                                   object:nil)
        
        searchViewEnabled = false
        
        // Create a reference to the navigation controller
        self.listViewController = self.navigationController as! ListViewController
        
        // Create our empty dictionary
        searchResults = [:]
        
        if self.title == nil {
            let fileName:String!
            switch Config.currentConfig().site {
                case .IFixit:
                    fileName = "iPhone-ifixit-logo.png"

                case .Zeal:
                    fileName = "titleImageZeal.png"

                case .Mjtrim:
                    fileName = "titleImageMjtrim.png"

                case .Accustream:
                    fileName = "accustream_logo_transparent.png"

                case .Magnolia:
                    fileName = "titleImageMagnoliamedical.png"

                case .Comcast:
                    fileName = "titleImageComcast.png"

                case .DripAssist:
                    fileName = "titleImageDripassist.png"

                case .Pva:
                    fileName = "titleImagePva.png"

                case .Oscaro:
                    fileName = "titleImageOscaro.png"

                    /*EAOTitle*/
            }
            
            let imageTitle = UIImageView(image:UIImage(named:fileName))
            imageTitle.contentMode = .ScaleAspectFit
            self.navigationItem.titleView = imageTitle
        }
        
        // Configure our search bar
        self.configureSearchBar()
        
        // Make room for the toolbar
        self.willAnimateRotationToInterfaceOrientation(self.interfaceOrientation, duration:0)
        
        self.navigationItem.titleView?.contentMode = .ScaleAspectFit
        
        // Display the favorites button on the top right
        self.listViewController.showFavoritesButton(self)
        
        // Solves an edge case dealing with categories not always loading
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone && self.listViewController.viewControllers.count == 1 {
            self.viewWillAppear(false)
        }
        
        // Be explicit for iOS 7
        self.tableView.backgroundColor = UIColor.whiteColor()
        
        // Only needed for iOS 7 + iPhone
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height + (self.tabBarController?.tabBar.frame.size.height)!)
        }
        
        self.tableView.rowHeight = 43.5
    }

    func configureSearchBar() {
        if Config.currentConfig().scanner {
            self.searchBar.placeholder = NSLocalizedString("Search or Scan", comment:"")
            self.scannerIcon.hidden = false
        } else {
            self.searchBar.placeholder = NSLocalizedString("Search", comment:"")
            self.scannerIcon.hidden = true
        }
        
        // Fix for iOS 8, without this, the search bar and scope bar won't show up
        self.searchBar.sizeToFit()
    }

    func displayBackToSitesButton() {
        // Show the Dozuki sites select button if needed.
        if Config.currentConfig().dozuki && self.navigationController?.viewControllers.count == 1 {
            let icon = UIImage(named:"backtosites.png")
            let button = UIBarButtonItem(image:icon, style:.Plain,
                                                                      target:UIApplication.sharedApplication().delegate,
                                                                      action:"showDozukiSplash")
            self.navigationItem.leftBarButtonItem = button
        }
    }

    func showLoading() {
        let container = UIView(frame:CGRectMake(0.0, 0.0, 28.0, 20.0))
        let spinner = UIActivityIndicatorView(frame:CGRectMake(0.0, 0.0, 20.0, 20.0))
        spinner.activityIndicatorViewStyle = .White
        container.addSubview(spinner)
        spinner.startAnimating()
        
        let button = UIBarButtonItem(customView:container)
        self.navigationItem.rightBarButtonItem = button
    }

    func showRefreshButton() {
        // Show a refresh button in the navBar.
        let refreshButton = UIBarButtonItem(barButtonSystemItem:.Refresh, target:self, action:"getAreas")
        if (self.listViewController.viewControllers.count == 1) {
            self.navigationItem.leftBarButtonItem = refreshButton;
            self.listViewController.showFavoritesButton(self)
        } else {
            self.navigationItem.rightBarButtonItem = refreshButton;
        }
    }

    func configureTableViewTitleLogoFromURL(URL:NSURL) {
        // Bail early if viewing iFixit from within the Dozuki app
        if Config.currentConfig().siteData["name"] == "ifixit" {
            return
        }
        
        let imageTitle = UIImageView()
        imageTitle.contentMode = .ScaleAspectFit
        imageTitle.setImageWithURL(URL)
        
        self.navigationItem.titleView = imageTitle;
        
        self.willAnimateRotationToInterfaceOrientation(self.interfaceOrientation, duration:0)
    }
    
    func setTableViewTitle() {
        let config = Config.currentConfig()
        
        let titleLabel = UILabel(frame:CGRectZero)
        titleLabel.backgroundColor = UIColor.clearColor()
        titleLabel.font = UIFont(name:"Helvetica-Bold", size:24.0)
        titleLabel.shadowColor = UIColor(white:0.0, alpha:0.5)
        titleLabel.textAlignment = .Center
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.adjustsFontSizeToFitWidth = true
        self.navigationItem.titleView = titleLabel
        titleLabel.text = config.title?.characters.count != 0
        ? config.title
        : NSLocalizedString("Categories", comment:"")
        titleLabel.alpha = 0
        titleLabel.sizeToFit()
        
        UIView.animateWithDuration(0.3, animations:{
            titleLabel.alpha = 1
        })
    }
    
    func getAreas() {
        self.showLoading()

        iFixitAPI.sharedInstance.getCategories({ (result) in
            self.gotAreas(result)
        })
    }

    func gotAreas(areas:[String:AnyObject]?) {
        let config = Config.currentConfig()
        let singleton = CategoriesSingleton.sharedInstance
        
        // Only show backToSites button on Dozuki and if we are a root view
        if (config.dozuki && self.listViewController.viewControllers.count == 1) {
            self.displayBackToSitesButton()
        } else {
            self.navigationItem.leftBarButtonItem = nil
        }
        
        self.navigationItem.rightBarButtonItem = nil
        
        let hierarchy = areas?["hierarchy"] as? [String:AnyObject]
        
        // Areas was nil, meaning we probably had a connection error
        if hierarchy == nil {
            self.showRefreshButton()
            iFixitAPI.displayConnectionErrorAlert()
        }
        
        if (hierarchy!.keys.count != 0) {
            // Save a master category list to a singleton if it hasn't
            // been created yet
            if singleton.masterCategoryList.isEmpty {
                singleton.masterCategoryList = hierarchy
            }
            
            if singleton.masterDisplayTitleList.isEmpty {
                singleton.masterDisplayTitleList = areas?["display_titles"] as? [String: String]
            }
            
            self.setData(hierarchy!)
            self.tableView.reloadData()
            self.listViewController.showFavoritesButton(self)
        } else {
            // If there is no area hierarchy, show a guide list instead
            if (hierarchy is Array) && (areas!.count == 0) {
                let dvc = iPhoneDeviceViewController(topic: nil)
                self.navigationController?.pushViewController(dvc, animated:true)
            }
        }
    }

// This is a deprecated method as of iOS 6.0, keeping this in to support older iOS versions
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation:UIInterfaceOrientation, duration:NSTimeInterval) {
        let config = Config.currentConfig()
        
        if ((toInterfaceOrientation == .LandscapeLeft || toInterfaceOrientation == .LandscapeRight) && UI_USER_INTERFACE_IDIOM() == .Phone) {
            switch config.site {
                case .Make:
                    break
                case .Dozuki, .Zeal:
                    self.navigationItem.titleView?.frame.size = CGSize(width:100, height:25)

                case .Mjtrim:
                    self.navigationItem.titleView?.frame.size = CGSize(width:75, height:24)

                case .Accustream:
                    self.navigationItem.titleView?.frame.size = CGSize(width:95, height:44)

                case .Magnolia:
                    self.navigationItem.titleView?.frame.size = CGSize(width:257, height:70)

                case .Comcast, .DripAssist, .Pva, .Oscaro:
                    self.navigationItem.titleView?.frame.size = CGSize(width:257, height:30)

                    /*EAOLandscapeResize*/
                default:
                    self.navigationItem.titleView?.frame.size = CGSize(width:75, height:24)
            }
        } else {
            switch config.site {
            case .Make:
                break
            case .Dozuki, .Zeal, .Mjtrim:
                self.navigationItem.titleView?.frame.size = CGSize(width:137, height:35)
                
            case .Accustream:
                self.navigationItem.titleView?.frame.size = CGSize(width:157, height:55)
                
            case .Magnolia:
                self.navigationItem.titleView?.frame.size = CGSize(width:157, height:65)
                
            case .Comcast, .DripAssist, .Pva, .Oscaro:
                self.navigationItem.titleView?.frame.size = CGSize(width:157, height:40)

                /*EAOPortraitResize*/
            default:
                self.navigationItem.titleView?.frame.size = CGSize(width:98, height:34)
            }
        }
    }

    func searchBarTextDidBeginEditing(theSearchBar:UISearchBar) {
        // If the user is about to search for something, let's sn
        if (self.tableView.decelerating) {
            self.tableView.scrollToRowAtIndexPath(self.tableView.indexPathsForVisibleRows![0],
                                  atScrollPosition:.None,
                                          animated:false)
        }
        
        
        self.enableSearchView(true)
    }

    func searchBarTextDidEndEditing(theSearchBar:UISearchBar) {
        
        searchBar.setShowsCancelButton(false, animated:true)
        self.enableSearchView(false)
        
        if theSearchBar.text == "" {
            noResults = false
            self.tableView.reloadData()
        }
    }

    func searchBarCancelButtonClicked(theSearchBar:UISearchBar) {
        searchBar.text = ""
        noResults = false
        self.enableSearchView(false)
        self.view.endEditing(true)
    }

    func searchBar(searchBar:UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        let scopeFilter = self.searchBar.scopeButtonTitles![selectedScope]
        
        if self.searchBar.text?.characters.count != 0 && self.searchResults[scopeFilter]!.count == 0 {
            let filter = self.searchBar.selectedScopeButtonIndex == 0 ? "guide,teardown" : "category"
            iFixitAPI.sharedInstance.getSearchResults((self.searchBar?.text)!, filter:filter) { (results) in
                self.gotSearchResults(results)
            }
        } else {
            self.tableView.reloadData()
        }
    }

    func searchBar(searchBar:UISearchBar, shouldChangeTextInRange range:NSRange, replacementText text:String) -> Bool {
        
        // Let the user input text if they are under the char limit or trying to delete text
        return searchBar.text?.characters.count <= 128 || text == ""
    }

    func getFilter() -> String {
        return (searchBar.selectedScopeButtonIndex == 0) ? "guide,teardown" : "category"
    }

    func searchBar(searchBar:UISearchBar, textDidChange searchText:String) {
        
        if searchText == "" {
            self.searching = false
            noResults = false
            self.tableView.reloadData()
            return;
        }
        
        if (!self.searching) {
            self.searching = true
        }
        
        if (searchText.characters.count <= 3) {
            iFixitAPI.sharedInstance.getSearchResults(searchText, filter:self.getFilter()) { (results) in
                self.gotSearchResults(results)
            }
            
        } else {
            self.performSelector("throttle:", withObject:searchText, afterDelay:0.3)
        }
        
    }

    func throttle(searchText:String) {
        if searchText == self.searchBar.text {
            iFixitAPI.sharedInstance.getSearchResults(searchText, filter:self.getFilter(), handler:{ (results) in
                    self.gotSearchResults(results)
            })
        }
    }

    func gotSearchResults(results:[String:AnyObject]?) {
        let filter = self.searchBar.scopeButtonTitles![self.searchBar.selectedScopeButtonIndex]
        
        if results?["search"] == self.searchBar?.text {
            searchResults = [:]
            self.currentSearchTerm = self.searchBar.text
            searchResults[filter] = results?["results"]
            noResults = searchResults[filter]!.count == 0
            self.tableView.reloadData()
            
            let search = results!["search"] as? String
            let gaInfo = GAIDictionaryBuilder.createEventWithCategory("Search", action:"query", label:"User searched for: \(search)", value:nil).build()
            GAI.sharedInstance().defaultTracker.send(gaInfo as [NSObject:AnyObject])
        }
    }

    func searchBarSearchButtonClicked(theSearchBar:UISearchBar) {
        let reachability = Reachability.reachabilityForInternetConnection()
        let internetStatus = reachability.currentReachabilityStatus()
        
        if (internetStatus == .NotReachable) {
            iFixitAPI.displayConnectionErrorAlert()
        }
        
        self.view.endEditing(true)
    }

// Helper function for devices older than 7.0 to help with odd UI rotation issues when using the search bar
    func repositionFramesForLegacyDevices(navigationBarHeight:Double, searchEnabled enabled:Bool) {
        self.view.frame = CGRectMake(0, enabled ? CGFloat(navigationBarHeight * -1.0) : 0.0, self.view.frame.size.width, self.view.frame.size.height)
        self.navigationController?.navigationBar.bounds = CGRectMake(0, 0, (self.navigationController?.navigationBar.bounds.size.width)!,
                                                                    enabled ? 0.0 : CGFloat(navigationBarHeight)
                                                                    )
    }

    func enableSearchView(option:Bool) {
        searchBar.setShowsCancelButton(option, animated:true)
        
        UIView.transitionWithView(self.tableView,
                          duration:0.2,
                           options:.CurveEaseOut,
                        animations:{
                            self.tableView.transform = option ? CGAffineTransformMakeTranslation(0, Config.currentConfig().scanner ? 88 : 44) : CGAffineTransformIdentity
                        }, completion:nil)
        
        // Only on iPhone do we want to make more room
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            
            // On iOS 7 we can simply move the whole view frame and take advantage of sexy animations
            let statusBarHeight: CGFloat = 20
            UIView.beginAnimations("search", context:nil)
            UIView.setAnimationDuration(0.3)
            self.view.frame = CGRectMake(0,
                                         option ? statusBarHeight :
                                         ((self.navigationController?.navigationBar.frame.size.height)! + statusBarHeight), self.view.frame.size.width, self.view.frame.size.height
                                         )
            
            UIView.commitAnimations()
            
            self.navigationController?.navigationBar.hidden = option
            self.listViewController.favoritesButton?.enabled = !option
        }
        
        // Toggle the favorites button
        UIView.transitionWithView(self.scannerIcon,
                          duration:option ? 0 : 0.4,
                           options:.TransitionCrossDissolve,
                        animations:{
                            self.scannerIcon.hidden = Config.currentConfig().scanner && !self.searching ? option : true
                        }, completion:nil)
        
        searchViewEnabled = option
    }

    func scrollViewDidScroll(scrollView:UIScrollView) {
        
        if searchViewEnabled {
            self.view.endEditing(true)
            self.enableSearchView(false)
        }
    }

    override func willRotateToInterfaceOrientation(toInterfaceOrientation:UIInterfaceOrientation, duration:NSTimeInterval) {
        // Make room for the toolbar
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad || UIInterfaceOrientationIsPortrait(toInterfaceOrientation) {
            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 60, 0)
            self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 60, 0)
        }
        
        // Reset the searching view offset to prevent rotating weirdness.
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            var bounds = self.navigationController?.view.bounds
            bounds.origin = CGPoint(x: bounds.origin.x, y:0.0)
            self.navigationController?.view.bounds = bounds!
        }
        
        UIApplication.sharedApplication().setStatusBarOrientation(toInterfaceOrientation, animated:true)
    }

    // MARK: - Table view data source

    func setData(dict: [String: AnyObject]) {
        self.categoryResults = dict
        self.categories = self.parseCategories(dict)
        self.categoryTypes = (self.categories?.keys.sort())!
    }

    func parseCategories(categoriesCollection:[String:AnyObject]?) -> [String:[Category]] {
        var categories: [Category] = []
        var devices: [Category] = []
        var allCategories: [String: [Category]] = [:]
        var categoryDisplayTitles = CategoriesSingleton.sharedInstance.masterDisplayTitleList
        
        // Bail early, we are working with a category with no children
        if categoriesCollection == nil {
            return allCategories
        }
        
        // Split categories from devices for iFixit and create key-value objects in the process
        for category in categoriesCollection! {
            if categoriesCollection![category] != nil {
                categories.append(["name" : category,
                                        "display_title" : categoryDisplayTitles[category] ?
                                        categoryDisplayTitles[category] : category,
                                        "type" : Categories.Category
                                        ])
            } else {
                devices.append(["name" : category,
                                     "display_title" : categoryDisplayTitles[category] ?
                                     categoryDisplayTitles[category] : category,
                                     "type" : Categories.Device
                                     ])
            }
        }
        
        // Sort categories and devices alphabetically
        categories.sort { $0.displayTitle < $1.displayTitle }
        devices.sortInPlace { $0.displayTitle < $1.displayTitle }
        
        // If on iFixit, keep them separate
        if Config.currentConfig().site == .IFixit {
            if (categories.count != 0) {
                allCategories[CATEGORIES] = categories
            }
            if (devices.count != 0) {
                allCategories[DEVICES] = devices
            }
        } else {
            // If we have both categories and devices, merge them
            allCategories[CATEGORIES] = []
            
            if (devices.count != 0) {
                allCategories[CATEGORIES] = devices
            // We only have categories
            }
            
            if (categories.count != 0) {
                allCategories[CATEGORIES]! += categories
            }
        }
        
        return allCategories
    }

    func numberOfSectionsInTableView(aTableView:UITableView) -> Int {
        if (self.searching) {
            return 1
        }
        
        return self.categoryTypes.count
    }

    func tableView(tableView:UITableView, titleForHeaderInSection section:Int) -> String? {
        if (self.searching) {
            let string = self.searchBar.scopeButtonTitles![self.searchBar.selectedScopeButtonIndex]
            return NSLocalizedString(string, comment:"")
        }
        
        return NSLocalizedString(self.categoryTypes[section].capitalizedString, comment:"");
    }

    func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
        
        if self.searching {
            let filter = self.searchBar.scopeButtonTitles![self.searchBar.selectedScopeButtonIndex]
            if searchResults[filter]!.count != 0 {
                return searchResults[filter]!.count
            } else if (noResults) {
                return 1
            } else {
                return 0
            }
            
        }
        
        return self.categories![self.categoryTypes[section]]!.count
    }

    func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
        
        var cellIdentifier = "SearchCell"
        var cell:UITableViewCell!
        
        // If searching, create the cell and bail early
        if (self.searching) {
            let filter = self.searchBar.scopeButtonTitles?[self.searchBar.selectedScopeButtonIndex]
            cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath:indexPath)
            
            if searchResults[filter]!.count != 0 {
                let result = searchResults[filter]![indexPath.row]
                
                if result["dataType"] == "guide" {
                    cell.textLabel?.text = result["title"]
                    cell.accessoryType = .None
                } else {
                    cell.textLabel?.text = result["display_title"]
                    cell.accessoryType = .DisclosureIndicator
                }
            } else {
                cell.textLabel?.text = NSLocalizedString("No Results Found", comment:"")
                cell.accessoryType = .None
            }
            
            return cell
        }
        
        let category = self.categories![self.categoryTypes[indexPath.section]]![indexPath.row]
        
        if (category.type == .Device || category.type == .Category) {
            
            cellIdentifier = "CellIdentifier"
            cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath:indexPath)
            
            cell.accessoryType = (category.type == .Category)
             ? .DisclosureIndicator : .None
            cell.textLabel?.text = category.displayTitle
            
        } else {
            cellIdentifier = "GuideCell"
            cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath:indexPath)
            
            cell.accessoryType = .None
            
            let thumbnailImage = category.image?.thumbnail
            
            cell.imageView?.setImageWithURL(thumbnailImage, placeholderImage:UIImage(named:"WaitImage.png"))
            
            cell.textLabel?.text = category.name
            cell.textLabel?.adjustsFontSizeToFitWidth = true
        }
        
        return cell
    }

    // MARK: - Table view delegate

    func tableView(aTableView:UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath) {
        let reachability = Reachability.reachabilityForInternetConnection()
        let internetStatus = reachability.currentReachabilityStatus()
        
        let appDelegate = UIApplication.sharedApplication().delegate as! iFixitAppDelegate
        let filter = self.searchBar.scopeButtonTitles![self.searchBar.selectedScopeButtonIndex]
        
        self.tableView.deselectRowAtIndexPath(indexPath, animated:true)
        self.view.endEditing(true)
        
        if self.searching && searchResults[filter]!.count == 0 {
            return
        }
        
        let cellResult = searchResults[filter]![indexPath.row] as [String:AnyObject]
        var category:Category!
        
        if self.searching && searchResults[filter]!.count != 0 {
            // If we are dealing with a guide we bail early
            if cellResult["dataType"] == "guide" {
                GuideLib.loadAndPresentGuideForGuideid(cellResult["guideid"])
                self.tableView.deselectRowAtIndexPath(indexPath, animated:true)
                
                return
            } else {
                category = Category(json: aDict)
                category.name = cellResult["title"]
                category.type = .Category
            }
        } else {
            category = self.categories![self.categoryTypes[indexPath.section]]![indexPath.row]
        }
        
        // Category
        if (category.type == .Category) {
            let vc = CategoriesViewController(nibName:"CategoriesViewController", bundle:nil)
            vc.title = category.displayTitle
            vc.categoryMetaData = category
            
            if (self.searching) {
                self.findChildCategoriesFromParent(category.name!)
            }
            
            vc.setData(self.searching ? categorySearchResult : categoryResults.map { $0.name! == category.name! })
            
            self.navigationController?.pushViewController(vc, animated:true)
            vc.tableView.reloadData()
            categorySearchResult = nil
            
            // Device
        } else if (category.type == .Device) {
            if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
                let vc = iPhoneDeviceViewController(topic:category.name!)
                vc.title = category.displayTitle
                self.navigationController?.pushViewController(vc, animated:true)
            } else {
                self.categoryMetaData = category
            }
            // Guide
        } else {
            GuideLib.loadAndPresentGuideForGuideid(category.guideid)
            
            self.tableView.deselectRowAtIndexPath(indexPath, animated:true)
            return
        }
        
        iFixitAPI.sharedInstance.getCategory(category.name!) { (result) in
            self.listViewController.categoryTabBarViewController?.gotCategoryResult(result)
        }
        
        // Change the back button title to "Home", only if we have 2 views on the stack
        if (self.navigationController?.viewControllers.count == 2) {
            self.listViewController.navigationBar.backItem?.title = NSLocalizedString("Home", comment:"")
        }
        
    }

// Given a parent category, find the category and it's children
    func findChildCategoriesFromParent(parentCategory: String) {
        // TODO: Check to see if the category is on the top level, if it isn't, then do recursion =/
        self.findCategory(parentCategory, inList:CategoriesSingleton.sharedInstance.masterCategoryList)
    }

// Recursive function to find the search result in our master category list
    func findCategory(needle:String, inList haystack: [String: AnyObject]) -> Bool {
        
        // Try to access the key first
        if (haystack[needle] as? NSNull) != nil {
            categorySearchResult = (haystack[needle] as! [String: AnyObject])
            return true
            // Key doesn't exist, we must go deeper
        }

        for (category, _) in haystack {
            // We have another dictionary to look at, lets call ourselves
            if (haystack[category] as? NSNull) != nil {
                // If we return true, that means we found our category, lets stop iterating through our current level
                if self.findCategory(needle, inList: haystack[category] as! [String: AnyObject]) {
                    break
                }
            }
        }
        
        return false
    }

// Add guides to the tableview if they exist
    func addGuidesToTableView(guides: [Guide]) {
        
        let newGuides = guides.map {
            $0.type = Categories.Guide
            $0.name = $0.title == "" ? NSLocalizedString("Untitled", comment:"") : $0.title
        }
        
        // Begin the update
        self.tableView.beginUpdates()
        self.tableView.insertSections(NSIndexSet(index:self.categoryTypes.count), withRowAnimation:.Fade)
        
        // Add the new guides to our category list
        self.categories?["guides"] = newGuides
        
        // Add a new category type "guides"
        self.categoryTypes.append("guides")
        
        // Donezo
        self.tableView.endUpdates()
    }
    
    @IBAction func scannerViewTouched(sender:AnyObject) {
        
        let qrReader = ZBarReaderViewController()
        qrReader.readerDelegate = self
        qrReader.supportedOrientationsMask = ZBarOrientationMaskAll
        
        let qrScanner = qrReader.scanner
        qrScanner.setSymbology(ZBAR_I25, config:ZBAR_CFG_ENABLE, to:0)
        
        let appDelegate = UIApplication.sharedApplication().delegate as! iFixitAppDelegate
        appDelegate.window?.rootViewController?.presentViewController(qrReader, animated:true, completion:nil)
    }

    func imagePickerController(picker:UIImagePickerController, didFinishPickingMediaWithInfo info:[String:AnyObject]) {
        
        // Get the results from the reader
        let results = info[ZBarReaderControllerResults] as? [ZBarSymbol]
        
        // We only care about the first symbol we find
        let symbol = results?.first
        
        let validUrl = self.openUrlFromScanner((symbol?.data!)!)
        
        picker.dismissViewControllerAnimated(true, completion:{
            if (!validUrl) {
                let alertView = UIAlertView(title:NSLocalizedString("Error", comment:""),
                                            message:NSLocalizedString("Not a valid QR Code", comment:""),
                                            delegate:self,
                                            cancelButtonTitle:NSLocalizedString("Okay", comment:""),
                                            otherButtonTitles:"")
                alertView.show()
            }
        })
        
        if (validUrl) {
            self.showLoading()
        }
    }

    func gotGuide(guide:Guide?) {
        if (guide != nil) {
            let guideViewController = GuideViewController(guide:guide!)
            let navigationController = UINavigationController(rootViewController:guideViewController)
            
            let appDelegate = UIApplication.sharedApplication().delegate as! iFixitAppDelegate
            appDelegate.window?.rootViewController?.presentViewController(navigationController, animated:true, completion:nil)
            
        } else {
            let alertView = UIAlertView(title:NSLocalizedString("Error", comment:""),
                                        message:NSLocalizedString("Guide not found", comment:""),
                                                               delegate:self,
                                        cancelButtonTitle:NSLocalizedString("Okay", comment:""),
                                                      otherButtonTitles:"")
            alertView.show()
        }
        
        self.listViewController.showFavoritesButton(self)
    }

// We want to look for the a valid category/device or guide URL
    func openUrlFromScanner(url:String) -> Bool {
        
        let guideRegex = try! NSRegularExpression(pattern:"(guide|teardown)/.+?/(\\d+)",
                                                                                    options:.CaseInsensitive)
        let categoryRegex = try! NSRegularExpression(pattern:"(device|c)\\/([^\\/]+)",
                                                                                       options:.CaseInsensitive)
        let guideMatches = guideRegex.matchesInString(url,
                                                    options:[],
                                                      range:NSMakeRange(0, url.utf16.count))
        
        let categoryMatches = categoryRegex.matchesInString(url,
                                                          options:[],
                                                            range:NSMakeRange(0, url.utf16.count))
        
        if (guideMatches.count != 0) {
            let guideIdRange = guideMatches[0].rangeAtIndex(2)
            let formatter = NSNumberFormatter()
            if let range = url.rangeFromNSRange(guideIdRange) {
                let iGuideId = formatter.numberFromString(url.substringWithRange(range))
                
                iFixitAPI.sharedInstance.getGuide(iGuideId!) { (aGuide) in
                    self.gotGuide(aGuide)
                }
            }
            
            return true
        }
        
        if (categoryMatches.count != 0) {
            let categoryIdRange = categoryMatches[0].rangeAtIndex(2)
            if let range = url.rangeFromNSRange(categoryIdRange) {
                let category = url.substringWithRange(range)
                
                iFixitAPI.sharedInstance.getCategory(category) { (result) in
                    self.gotCategoryResult(result)
                }
            }
            
            return true
        }
        
        return false
    }

    func gotCategoryResult(results:[String:AnyObject]?) {
        
        if results == nil {
            iFixitAPI.displayConnectionErrorAlert()
            return
        }
        
        let category = results!["title"] as! String
        self.findChildCategoriesFromParent(category)
        
        if (categorySearchResult != nil) {
            let vc = CategoriesViewController(nibName:"CategoriesViewController", bundle:nil)
            
            vc.title = category
            vc.setData(categorySearchResult!)
            self.navigationController?.pushViewController(vc, animated:true)
            vc.tableView.reloadData()
            
            if UIDevice.currentDevice().userInterfaceIdiom == .Phone &&
                 results!["guides"].count != 0 {
                    vc.addGuidesToTableView(results["guides"])
                }
            
            categorySearchResult = nil
            
            self.listViewController.categoryTabBarViewController?.updateTabBar(results!)
            self.listViewController.categoryTabBarViewController?.showTabBar(true)
        } else {
            let alertView = UIAlertView(title:NSLocalizedString("Error", comment:""),
                                        message:NSLocalizedString("Category not found", comment:""),
                                        delegate:self,
                                        cancelButtonTitle:NSLocalizedString("Okay", comment:""),
                                        otherButtonTitles:"")
            alertView.show()
        }
        
        self.listViewController.showFavoritesButton(self)
    }

    // MARK: - Memory management

    override func didReceiveMemoryWarning() {
        // Releases the view if it doesn't have a superview.
        super.didReceiveMemoryWarning()
        // Relinquish ownership any cached data, images, etc. that aren't in use.
    }

}
