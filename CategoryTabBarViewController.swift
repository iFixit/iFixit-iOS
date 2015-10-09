//
//  CategoryTabBarViewController.m
//  iFixit
//
//  Created by Stefan Ayala on 6/20/13.
//
//

//#import <QuartzCore/QuartzCore.h>

class CategoryTabBarViewController: UITabBarController, UINavigationBarDelegate, MGSplitViewControllerDelegate, UITabBarControllerDelegate {
    
    // View controllers that our tab bar is going to reference

    // iPad
    var detailGridViewController:DetailGridViewController?
    var popOverController:UIPopoverController?
    var browseButton:UIButton?

    // iPhone
    var categoriesViewController:CategoriesViewController?
    var listViewController:ListViewController?

    // Both
    var categoryMoreInfoViewController:CategoryWebViewController?
    var categoryAnswersWebViewController:CategoryWebViewController?
    var tabBarViewControllers:[UIViewController]?

    var categoryMetaData:[String:AnyObject]?
    var toolBarFillerImage:UIImageView?

    // Integers to be used as constants
    var GUIDES = 0
    var ANSWERS = 1
    var MORE_INFO = 2

    var onTablet = false
    var initialLoad = false
    var showTabBar = false

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        
        super.init(nibName:nibNameOrNil, bundle:nibBundleOrNil)
        
        // Custom initialization
        initializeProperties()
        initializeViewControllers()
        configureTabBar()
        buildTabBarConstants()
        buildTabBarItems()
        configureStateForInitialLoad()

    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillDisappear(animated:Bool) {
        if (self.popOverController?.popoverVisible ?? false) {
            popOverController!.dismissPopoverAnimated(true)
        }
    }

    func configureStateForInitialLoad() {
        if onTablet {
            hideBrowseInstructions(true)
        }
    }

    // Initialize our properties that will be used throughout the program
    func initializeProperties() {
        let config = Config.currentConfig()
        onTablet = UIDevice.currentDevice().userInterfaceIdiom == .Pad
        initialLoad = true
        showTabBar = (UIApplication.sharedApplication().delegate as! iFixitAppDelegate).showsTabBar
        
        // This is a hack built on top of a hack. We have a filler image we use when we hide the tabbar to avoid funky resizing issues of the view
        if (onTablet) {
            let size = self.tabBar.frame.size
            let filler = UIImageView(frame:CGRectMake(0, 19, size.width, size.height))
            
            filler.image = config.concreteBackgroundImage ?? UIImage(named:"concreteBackground.png")
            
            view.addSubview(filler)
            
            self.toolBarFillerImage = filler
            
            createBrowseButton()
            self.view.subviews[1].addSubview(browseButton!)
            
            self.browseButton!.hidden = UIInterfaceOrientationIsLandscape(UIApplication.sharedApplication().statusBarOrientation)
            showTabBar = false
        }
        
        self.delegate = self
        
        createStatusBarBackgroundView()
        
        // Remove translucence on iOS 7 for iPhone only
        if (!onTablet) {
            self.tabBar.translucent = false
        }
    }

    // We create different buttons depending on what version the user is on
    func createBrowseButton() {
        let frame = CGRectMake(7, 10, 100, 34)
        browseButton = UIButton(type:.RoundedRect)
        browseButton!.frame = frame
        
        browseButton!.setTitle(NSLocalizedString("Browse", comment:""), forState:.Normal)
        browseButton!.addTarget(self, action:"browseButtonPushed", forControlEvents:.TouchUpInside)
    }
    
    func createStatusBarBackgroundView() {
        let view = UIView(frame:CGRectMake(0, 0, self.view.frame.size.width, 20))
        view.backgroundColor = Config.currentConfig().toolbarColor
        self.view.addSubview(view)
    }

    func browseButtonPushed() {
        // For iOS 7, our popover content controller works differently, because of that we have to be explicit on our height
        let frame = CGRectMake(browseButton!.frame.origin.x, 34, browseButton!.frame.size.width, browseButton!.frame.size.height);
        
        popOverController!.presentPopoverFromRect(frame, inView: self.view, permittedArrowDirections: .Up, animated: true)
    }

    func createGradient(btn:UIButton) {
        
        /**
        * Taken from: http://stackoverflow.com/a/14940984/2089315
        */
        
        let btnGradient = CAGradientLayer()
        btnGradient.frame = btn.bounds
        btnGradient.colors = [
            UIColor(red:100.0/255.0, green:100.0/255.0, blue:100.0/255.0, alpha:0.4).CGColor,
        UIColor(red:50.0/255.0, green:50.0/255.0, blue:50.0/255.0, alpha:0.4).CGColor,
        UIColor(red:5.0/255.0, green:5.0/255.0, blue:5.0/255.0, alpha:0.4).CGColor]
        
        btn.layer.insertSublayer(btnGradient, atIndex:0)
        
        let glossLayer = CAGradientLayer()
        glossLayer.frame = btn.bounds
        glossLayer.colors = [
        UIColor(white:1.0, alpha:0.4).CGColor,
        UIColor(white:1.0, alpha:0.1).CGColor,
        UIColor(white:0.75, alpha:0.0).CGColor,
        UIColor(white:1.0, alpha:0.1).CGColor]
        glossLayer.locations = [0.0, 0.5, 0.5, 1.0]
        btn.layer.insertSublayer(glossLayer, atIndex:0)
        
        let btnLayer = btn.layer
        btnLayer.masksToBounds = true
        
        let myColor = btn.backgroundColor
        btn.layer.borderColor = myColor!.CGColor
        btn.layer.borderWidth = 2.0
        btn.layer.cornerRadius = 10.0
    }

    func configureTabBar() {
        // On iPad we move the tabbar to the top of the frame.
        
        if (onTablet) {
            tabBar.frame = CGRectMake(0, 20, UIScreen.mainScreen().bounds.size.width, 44);
            tabBar.autoresizingMask = [.FlexibleBottomMargin, .FlexibleRightMargin, .FlexibleWidth, .FlexibleLeftMargin]
        } else {
            showTabBar = false
        }
        
        tabBar.backgroundColor = UIColor.whiteColor()
    }

    // Dynamically build our tab bar constants which depends on our config settings.
    func buildTabBarConstants() {
        // Set up constants
        if (Config.currentConfig().answersEnabled) {
            self.GUIDES = 0
            self.ANSWERS = 1
            self.MORE_INFO = 2
        } else {
            self.GUIDES = 0
            self.MORE_INFO = 1
        }
    }

    // Build tab bar items and insert them into our tabbar
    func buildTabBarItems() {
        
        var viewControllers:[UIViewController] = []
        
        // If on a tablet, we initialize the guide layout as our first viewcontroller
        if (onTablet) {
            viewControllers.append(detailGridViewController!)
            detailGridViewController!.tabBarItem.title = NSLocalizedString("Guides", comment:"");
            detailGridViewController!.tabBarItem.tag = self.GUIDES
            detailGridViewController!.tabBarItem.image = UIImage(named:"guides")
        } else {
            // On iPhone our first view controller is a navigation controller
            viewControllers.append(listViewController!)
            listViewController!.tabBarItem.title = NSLocalizedString("Guides", comment:"")
            listViewController!.tabBarItem.tag = self.GUIDES
            listViewController!.tabBarItem.image = UIImage(named:"guides")
            // Create a reference that our navigation controller can use to access the tabbar controller easily
// TODO            self.listViewController!.categoryTabBarViewController = self
        }
        
        self.categoryMoreInfoViewController!.tabBarItem.title = NSLocalizedString("More Info", comment:"")
        self.categoryMoreInfoViewController!.tabBarItem.tag = self.MORE_INFO
        self.categoryMoreInfoViewController!.tabBarItem.image = UIImage(named:"moreinfo")
        
        // Not every site has answers enabled
        if (Config.currentConfig().answersEnabled) {
            categoryAnswersWebViewController!.tabBarItem.title = NSLocalizedString("Answers", comment:"")
            categoryAnswersWebViewController!.tabBarItem.tag = self.ANSWERS
            categoryAnswersWebViewController!.tabBarItem.image = UIImage(named:"answers")
            viewControllers.append(categoryAnswersWebViewController!)
        }
        
        // Lastly add our moreInfoViewController, this maintains order and simplifies a lot of code.
        viewControllers.append(categoryMoreInfoViewController!)
        
        tabBarViewControllers = viewControllers
        setViewControllers(tabBarViewControllers, animated:true)
        
        // Disable our tabBarItems since we don't show it on the root view
        enableTabBarItems(false)
        
        // iPad is wonky, we have to resize the subview since we are already doing hacky things, this is the path
        // of least resistance.
        if (onTablet) {
            let primaryView = self.view.subviews[0]
            primaryView.frame = CGRectMake(0, 44, primaryView.frame.size.width, primaryView.frame.size.height + 5)
        }
    }

    func showTabBar(option:Bool) {
        // Disable the animation on iOS7+ as it is no longer needed
        let duration = 0.0
        
        UIView.transitionWithView(tabBar,
            duration:duration,
            options:.TransitionCrossDissolve,
            animations:{
                // If on a tablet, we manipulate the opacity and show the filler image
                // This is much more sane then removing the tabBar on iPad to avoid view manipulations
                // and strange bugs.
                if (self.onTablet) {
                    if (option) {
                        self.tabBar.alpha = 1.0
                        self.toolBarFillerImage!.alpha = 0.0
                    } else {
                        self.tabBar.alpha = 0.0
                        self.toolBarFillerImage!.alpha = 1.0
                    }
                } else {
                    // We can get away with just hiding the tabBar on iPhone since we aren't doing
                    // anything crazy, ie: moving the tabbar from it's default position
                    self.tabBar.hidden = !option
                    
                    // Resize the subview, it is sane to do this on an iPhone
                    self.configureSubViewFrame(0)
                }
            },
            completion:nil
        )
    }

    func enableTabBarItems(option:Bool) {
        
        UIView.transitionWithView(tabBar,
            duration:0.3,
            options:.TransitionCrossDissolve,
            animations:{
                if (self.onTablet) {
                    for tabBarItem in self.tabBar.items! {
                        tabBarItem.enabled = option
                    }
                    // Since iPhone will always have the guide tab enabled, we only want to
                    // manipulate the other tabBar Items
                } else {
                    self.tabBar.items![self.MORE_INFO].enabled = option
                    
                    if Config.currentConfig().answersEnabled {
                        self.tabBar.items![self.ANSWERS].enabled = option
                    }
                }
            },
            completion:nil
        )
    }

    // Build references to our view controllers that will be used in our tabBar
    func initializeViewControllers() {
        // Only create the references if we need to
        if (onTablet) {
            detailGridViewController = DetailGridViewController()
        } else {
            categoriesViewController = CategoriesViewController(nibName:"CategoriesViewController", bundle:nil)
            listViewController = ListViewController(rootViewController:categoriesViewController!)
        }
        
        self.categoryMoreInfoViewController = configureWebViewController(categoryMoreInfoViewController)
        
        // Answers isn't enabled for everyone
        if Config.currentConfig().answersEnabled {
            categoryAnswersWebViewController = configureWebViewController(categoryAnswersWebViewController)
            categoryAnswersWebViewController!.webViewType = "answers"
        }
    }

    // Configure our webViewControllers so they can be reused
    func configureWebViewController(viewController:UIViewController?) -> CategoryWebViewController {
        let vc = CategoryWebViewController(nibName:"CategoryWebViewController", bundle:nil)
        
        vc.loadView()
// TODO        vc.setCategoryTabBarViewController(self)
        vc.configureProperties()
        
        return vc
    }

    // Configure our subview frame depending on what view we are looking at
    func configureSubViewFrame(viewControllerIndex:Int) {
        
        // Bail early if we aren't showing a tabBar
        if (!showTabBar && onTablet) {
            return
        }
        
        let subView = view.subviews[0]
        let bounds = view.bounds
        
        // Tablet is tricky because we are already doing things we shouldn't be doing
        if (onTablet) {
            // Forgive me father for I have sinned. This is why we shouldn't go against Apple's Guidelines
            // For iPhone we change the subview frame to account for hidden tabbar
        } else {
            // iOS7 works much differently, we essentially shrink and expand the tabbar frame
            let origin = self.tabBar.frame.origin
            self.tabBar.frame = (listViewController!.viewControllers.count == 1)
                ? CGRectMake(origin.x, origin.y, 0, 0)
                : CGRectMake(origin.x, origin.y, bounds.size.width, 49)
            
            configureFontSizeForTabBarItems()
        }
    }

    // Resize our fonts to avoid edge case on iOS 7 when resizing tabbar
    func configureFontSizeForTabBarItems() {
        let textAttributes = [NSFontAttributeName : UIFont(name:"OpenSans", size:12.0)!]
        
        for viewController in tabBarViewControllers! {
            viewController.tabBarItem.setTitleTextAttributes(textAttributes, forState:.Normal)
        }
    }

    // Update the tab bar once we get more information about the category we are currently viewing
    func updateTabBar(results:[String:AnyObject]) {
        self.categoryMetaData = results
        
        UIView.transitionWithView(tabBar,
            duration:0.0,
            options:.TransitionCrossDissolve,
            animations:{
                
                // Only on a tablet can the Guides tab be enabled/disabled
                if (self.onTablet) {
                    let guides = results["guides"] as? [Guide]
                    self.tabBar.items![self.GUIDES].enabled = guides?.count > 0
                }
                
                let contentsRendered = results["contents_rendered"] as? [String]
                self.tabBar.items![self.MORE_INFO].enabled = contentsRendered!.count > 0
                
                if (Config.currentConfig().answersEnabled) {
                    let solutions = results["solutions"] as? [String:AnyObject]
                    self.tabBar.items![self.ANSWERS].enabled = solutions!["count"] != nil
                }
                
                // Only on the tablet do we force an update to our tabBarSelection
                if (self.onTablet) {
                    self.updateTabBarSelection()
                }
            },
            completion:nil
        )
    }

    // Force a tab bar selection on the first item that is enabled
    func updateTabBarSelection() {
        
        for (var i = 0; i < self.tabBar.items!.count; i++) {
            // We only care about the first item that is enabled
            if self.tabBar.items![i].enabled {
                self.tabBar(self.tabBar, didSelectItem:self.tabBar.items![i])
                selectedIndex = i
                
                // Don't show the noGuides Image if we found something
                self.detailGridViewController!.showNoGuidesImage(false)
                
                // Bail early if we got what we needed
                return
            }
        }
        
        // If we get this far, it's because the category has no guides/answers/more-info.
        // In this case we disable all the tabBar items, force a selection to Guides index,
        // then show the noGuides image.
        enableTabBarItems(false)
        selectedIndex = 0
        detailGridViewController!.category = nil
        detailGridViewController!.showNoGuidesImage(true)
        configureSubViewFrame(self.GUIDES)
    }

    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        if (onTablet) {
            return true
        } else {
            return tabBarController.selectedViewController != viewController;
        }
    }

// Delegate method, called when a tabBarItem is selected, or when I want to force a selection programatically
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        
        // Google Analytics
        let category = self.categoryMetaData!["title"] as! String
        recordAnalyticsEvent(item.tag, withCategory:category)
        
        if (item.tag == self.selectedIndex && !onTablet) {
            return;
        }

        if (item.tag == self.GUIDES) {
            if category != detailGridViewController!.category {
                detailGridViewController!.category = category
            }
        } else if (item.tag == self.MORE_INFO) {
            prepareWebViewController(categoryMoreInfoViewController!, fromTag: item.tag, withCategory: category)
        } else {
            prepareWebViewController(categoryAnswersWebViewController!, fromTag: item.tag, withCategory: category)
        }
        
        // Configure the subview frame to take into account the tabbar being moved to the top
        if (onTablet) {
            configureSubViewFrame(item.tag)
        }
        
    }

    // Google Analytics: record category and action
    func recordAnalyticsEvent(event:Int, withCategory category:String) {
        
        // Bail early if we are just navigating through Guides
        if (event == self.GUIDES) {
            return
        }
        
        var eventType:String!
        
        if (event == self.MORE_INFO) {
            eventType = "more info"
        } else if (event == self.ANSWERS) {
            eventType = "answers"
        }
        
        // Analytics
        let gaInfo = GAIDictionaryBuilder.createEventWithCategory("Category", action: eventType, label: category, value: 0).build()
        GAI.sharedInstance().defaultTracker.send(gaInfo as [NSObject:AnyObject])
    }

// Prepare our webViewController before presenting it to the user
    func prepareWebViewController(viewController:CategoryWebViewController, fromTag tag:Int, withCategory category:String) {
        
        // Don't reload the page if we are looking at the current category
        if category != viewController.category {
            // Empty the page
            viewController.webView.stringByEvaluatingJavaScriptFromString("document.body.innerHTML = \"\";")
            
            // Our more info page needs to be configured
            if (tag == self.MORE_INFO) {
                let cwvc = CategoryWebViewController.configureHtmlForWebview(self.categoryMetaData)
                viewController.webView.loadHTMLString(cwvc, baseURL:nil)
                // Answers is a straight webview so no HTML manipulation is needed, just load the request
            } else {
                let url = NSURL(string:(categoryMetaData!["solutions"] as! [String:AnyObject])["url"] as! String)
                let request = NSURLRequest(URL: url!)
                viewController.webView.loadRequest(request)
            }
            
            viewController.category = category
            viewController.listViewController = self.listViewController
            
            // Hack to create the back arrow on a Navigation bar that is not using a navigation controller
            // This is the most elegant solution sadly.
            if (!onTablet) {
                let navItems = listViewController!.navigationBar.items!
                viewController.categoryNavigationBar.items![1].title = navItems[navItems.count - 2].title
            }
        }
        
    }

    func gotCategoryResult(results:[String:AnyObject]?) {
        if results == nil {
            iFixitAPI.displayConnectionErrorAlert()
            return
        }
        
        // We need to find the view controller that this response belongs to
        for viewController in self.listViewController!.viewControllers as! [CategoriesViewController] {
            let categoryInfo = viewController.categoryMetaData as! [String:AnyObject]
            let categoryName = (categoryInfo["name"] ?? categoryInfo["title"]) as! String
            
            if (categoryName == results!["title"] as! String) {
                viewController.categoryMetaData = results!
                
                // Only on iPhone do we want to add a guides section to the tableView
                if (!onTablet && viewController.respondsToSelector("addGuidesToTableView:") && (results!["guides"] as? [Guide])!.count > 0) {
                    // Add guides to our top level view controller's tableview
                    viewController.addGuidesToTableView(results!["guides"] as! [AnyObject])
                }
            }
        }
        
        showTabBar = true
        updateTabBar(results!)
    }

// Override the default behavior of our navigation bar. This is only used for iPhone
    func navigationBar(navigationBar: UINavigationBar, shouldPopItem item: UINavigationItem) -> Bool {
        // Select our guide tab bar item and pop a viewcontroller of the stack
        selectedIndex = self.GUIDES;
        listViewController!.popViewControllerAnimated(true)
        
        return false
    }

    func reflowLayout(orientation:UIInterfaceOrientation) {
        
        if (UIInterfaceOrientationIsLandscape(orientation)) {
            showTabBar = self.listViewController!.viewControllers.count > 1 || self.detailGridViewController!.category != nil
            configureFistImageView(.LandscapeLeft)
            popOverController = nil
            detailGridViewController!.orientationOverride = .LandscapeLeft
        } else {
            showTabBar = true
            configureFistImageView(.Portrait)
            detailGridViewController!.orientationOverride = .Portrait
        }
        
        detailGridViewController!.tableView.reloadData()
    }

    func hideBrowseInstructions(option:Bool) {
        detailGridViewController!.guideArrow.hidden = option
        detailGridViewController!.browseInstructions.hidden = option;
    }

    func splitViewController(svc: MGSplitViewController!, willHideViewController aViewController: UIViewController!, withBarButtonItem barButtonItem: UIBarButtonItem!, forPopoverController pc: UIPopoverController!) {
        
        //TODO[pc.contentViewController navigationBar].translucent = false
        //TODO[pc.contentViewController navigationBar].barStyle = UIBarStyleBlack;
        
        self.popOverController = pc;
        reflowLayout(.Portrait)
        
        if (!showTabBar) {
            enablePresentWithGesture(true)
        }
        
        if (self.listViewController!.viewControllers.count == 1) {
            hideBrowseInstructions(false)
        }
        
        browseButton!.hidden = false
    }

    func enablePresentWithGesture(option:Bool) {
        // Backwards compatibility
        if splitViewController!.respondsToSelector("setPresentsWithGesture:") {
            self.splitViewController!.presentsWithGesture = option
        }
    }

    func configureFistImageView(orientation:UIInterfaceOrientation) {
        let fistImageView = self.detailGridViewController!.fistImage
        var yCoord:CGFloat = UIInterfaceOrientationIsLandscape(orientation) ? 0 : 250;
        
        yCoord += 64;
        
        if (initialLoad) {
            fistImageView.frame = CGRectMake(0, yCoord, UIScreen.mainScreen().bounds.size.width, fistImageView.frame.size.height)
            initialLoad = false
        } else {
            UIView.transitionWithView(fistImageView,
                duration:0.3,
                options:.CurveEaseInOut,
                animations:{
                    var width: CGFloat
                    
                    // Nasty...nasty hack
                    if (UIInterfaceOrientationIsLandscape(orientation)) {
                        width = UIScreen.mainScreen().bounds.size.height
                    } else {
                        width = UIScreen.mainScreen().bounds.size.width
                    }
                    
                    fistImageView.frame = CGRectMake(0, yCoord, width, fistImageView.frame.size.height)
                }, completion:nil
            )
        }
    }

    func splitViewController(svc: MGSplitViewController!, willShowViewController aViewController: UIViewController!, invalidatingBarButtonItem barButtonItem: UIBarButtonItem!) {
        self.popOverController = nil;
        reflowLayout(.LandscapeLeft)
        hideBrowseInstructions(true)
        self.browseButton!.hidden = true
        
        if (!showTabBar) {
            enablePresentWithGesture(false)
        }
    }

    func gotSiteInfoResults(results:[String:AnyObject]?) {
        let config = Config.currentConfig()
        
        config.siteInfo = results
        
        let cvc = listViewController!.viewControllers[0] as! CategoriesViewController
        config.scanner = results!["feature-mobile-scanner"] as! Bool
        cvc.configureSearchBar()
        
        // We don't have logo data, so let's just configure the backup titles
        if results!["logo"] is NSNull {
            detailGridViewController!.configureDozukiTitleLabel()
            cvc.setTableViewTitle()
        } else {
            let imageData = (results!["logo"] as! [String:AnyObject])["image"] as! [String:AnyObject]
            if imageData["standard"] != nil {
                cvc.configureTableViewTitleLogoFromURL(imageData["standard"] as! String)
            } else {
                cvc.setTableViewTitle()
            }
            
            if imageData["large"] != nil {
                detailGridViewController!.configureSiteLogoFromURL(imageData["large"] as! String)
            } else {
                detailGridViewController!.configureDozukiTitleLabel()
            }
        }
    }

}
