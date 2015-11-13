//
//  DetailGridViewController.m
//  iFixit
//
//  Created by David Patierno on 11/15/11.
//  Copyright (c) 2011 iFixit. All rights reserved.
//

class DetailGridViewController : DMPGridViewController, DMPGridViewDelegate, UIAlertViewDelegate {

    var category: String? {
        didSet {
            self.guides = nil
            self.tableView.reloadData()
            
            if (category != nil) {
                self.loadCategory()
            }
        }
    }
    var guides: [Guide]?
    var loading: WBProgressHUD!
    var orientationOverride: UIInterfaceOrientation = .Unknown

    var noGuidesImage: UIImageView!
    var fistImage: UIImageView!
    var guideArrow: UIImageView!
    var siteLogo: UIImageView!
    var backgroundView: UIImageView!
    
    var browseInstructions: UILabel!
    var dozukiTitleLabel: UILabel!

    var gridDelegate: DetailGridViewControllerDelegate?

    override init(nibName:String?, bundle:NSBundle?) {
        
        super.init(nibName:nibName, bundle:bundle)

        // Custom initialization
        self.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    // TODO: Shouldn't exist, temporary
    convenience init() {
        self.init(nibName:"DetailGridViewController", bundle:nil)
    }

    func showLoading() {
        if loading.superview != nil {
            loading.showInView(self.view)
            return
        }
        
        let frame = CGRectMake(self.view.frame.size.width / 2.0 - 60, 260.0, 120.0, 120.0)
        self.loading = WBProgressHUD(frame:frame)
        self.loading.autoresizingMask = [.FlexibleTopMargin, .FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleBottomMargin]
        loading.showInView(self.view)
    }

    func loadCategory() {
        showLoading()

        iFixitAPI.sharedInstance.getCategory(category!) { (results) in
            self.gotCategory(results)
        }
    }

    func configureSiteLogoFromURL(url:String) {
        // Set up the site logo frame
        configureSiteLogo()
        
        self.siteLogo.setImageWithURL(NSURL(string:url))
        self.backgroundView.addSubview(self.siteLogo)
    }

    func configureSiteLogo() {
        let siteLogoImageView = UIImageView(frame:CGRectMake(0, 0, 400, 300))

        siteLogoImageView.contentMode = .ScaleAspectFit
        siteLogoImageView.autoresizingMask = [.FlexibleWidth, .FlexibleBottomMargin, .FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleTopMargin]
        siteLogoImageView.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)
        
        self.siteLogo = siteLogoImageView
    }

    func gotCategory(data:[String:AnyObject]?) {
        self.guides = data?["guides"] as? [Guide]    // Check if NSNull
        
        if (guides == nil) {
            self.loading.hide()
            let alert = UIAlertView(title:NSLocalizedString("Could not load guide list.", comment:""),
                                    message:NSLocalizedString("Please check your internet connection and try again.", comment:""),
                                             delegate:self,
                                    cancelButtonTitle:NSLocalizedString("Cancel", comment:""),
                                    otherButtonTitles:NSLocalizedString("Retry", comment:""))
            alert.show()
            return
        }
        else if guides?.count == 0 {
            gridDelegate?.detailGrid(self, gotGuideCount:0)
            
            self.loading.hide()
            return
        }
        
        gridDelegate?.detailGrid(self, gotGuideCount:guides!.count)
        
        UIView.transitionWithView(self.tableView,
                          duration:0.5,
                           options:.TransitionCrossDissolve,
                        animations:{
                            self.tableView.reloadData()
                            self.loading.hide()
                        },
                        completion:nil)
    }

    func alertView(alertView:UIAlertView, clickedButtonAtIndex buttonIndex:Int) {
        if buttonIndex == 0 {
            return
        }
        
        loadCategory()
    }

    func showNoGuidesImage(option: Bool) {
        self.noGuidesImage.hidden = !option
    }

    // MARK: - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
    override func viewDidLoad() {
        let config = Config.currentConfig()
        
        super.viewDidLoad()
        
        self.backgroundView = UIImageView(image:config.concreteBackgroundImage ?? UIImage(named:"concreteBackground.png"))
        
        if (!config.dozuki) {
            configureSiteLogo()
        }
        
        switch (config.site) {
            case .IFixit:
                self.fistImage = UIImageView(image:UIImage(named:"detailViewFist.png"))
                self.fistImage.frame = CGRectMake(0, 64, 703, 660)
                self.backgroundView.addSubview(self.fistImage)

            case .Mjtrim:
                self.siteLogo.image = UIImage(named:"mjtrim_logo_transparent.png")
                self.siteLogo.frame = CGRectMake(140, 160, self.siteLogo.frame.size.width, self.siteLogo.frame.size.height)
                self.backgroundView.addSubview(self.siteLogo)

            case .Accustream:
                self.siteLogo.image = UIImage(named:"accustream_logo_transparent.png")
                self.siteLogo.frame = CGRectMake(-60, 140, 654, 226)
                self.backgroundView.addSubview(self.siteLogo)

            case .Zeal:
                self.siteLogo.image = UIImage(named:"zeal_logo_transparent.png")
                self.siteLogo.frame = CGRectMake(60, 100, self.siteLogo.frame.size.width, self.siteLogo.frame.size.height)
                self.backgroundView.addSubview(self.siteLogo)

            case .Magnolia:
                self.siteLogo.image = UIImage(named:"magnoliamedical_logo_transparent.png")
                self.siteLogo.frame = CGRectMake(140, 180, self.siteLogo.frame.size.width, self.siteLogo.frame.size.height)
                self.backgroundView.addSubview(self.siteLogo)

            case .Comcast:
                self.siteLogo.image = UIImage(named:"comcast_logo_transparent.png")
                self.siteLogo.frame = CGRectMake(50, 120, self.siteLogo.frame.size.width, self.siteLogo.frame.size.height)
                self.backgroundView.addSubview(self.siteLogo)

            case .DripAssist:
                self.siteLogo.image = UIImage(named:"dripassist_logo_transparent.png")
                self.siteLogo.frame = CGRectMake(60, 110, self.siteLogo.frame.size.width, self.siteLogo.frame.size.height)
                self.backgroundView.addSubview(self.siteLogo)

            case .Pva:
                self.siteLogo.image = UIImage(named:"pva_logo_transparent.png")
                self.siteLogo.frame = CGRectMake(60, 110, self.siteLogo.frame.size.width, self.siteLogo.frame.size.height)
                self.backgroundView.addSubview(self.siteLogo)

            case .Oscaro:
                self.siteLogo.image = UIImage(named:"oscaro_logo_transparent.png")
                self.siteLogo.frame = CGRectMake(60, 110, self.siteLogo.frame.size.width, self.siteLogo.frame.size.height)
                self.backgroundView.addSubview(self.siteLogo)
                break;
                /*EAOiPadSiteLogo*/
                
            default:
                break
        }
        
        self.guideArrow = UIImageView(image:UIImage(named:"detailViewArrowDark.png"))
        self.guideArrow.frame = CGRectMake(45, 64, self.guideArrow.frame.size.width, self.guideArrow.frame.size.height)
        
        self.backgroundView.addSubview(self.guideArrow)
        
        configureInstructionsLabel()
        
        // Add a 10px bottom margin.
        self.tableView.backgroundView = self.backgroundView;
        
        // Decide how much margin we give our tableview
        configureTableViewContentInsent()
        
        self.noGuidesImage = UIImageView(image:UIImage(named:"noGuides.png"))
        self.noGuidesImage.frame = CGRectMake(135.0, 30.0, self.noGuidesImage.frame.size.width, self.noGuidesImage.frame.size.height)
        self.view.addSubview(self.noGuidesImage)
        
        self.showNoGuidesImage(false)
        
        self.willRotateToInterfaceOrientation(UIApplication.sharedApplication().statusBarOrientation, duration:0)
    }

    func configureTableViewContentInsent() {
        let showsTabBar = (UIApplication.sharedApplication().delegate as! iFixitAppDelegate).showsTabBar
        
        let inset = UIEdgeInsetsMake(78.0, 0, (showsTabBar) ? 70.0 : 10.0 , 0)
        
        self.tableView.contentInset = inset
    }
    
    func configureDozukiTitleLabel() {
        let config = Config.currentConfig()
        let siteData = config.siteData as? [String:String]
        
        // Bail early if we are on iFixit within Dozuki
        if siteData!["name"] == "ifixit" {
            return
        }
        
        let l = UILabel()
        l.autoresizingMask = [.FlexibleWidth, .FlexibleBottomMargin, .FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleTopMargin]
        l.textAlignment = .Center
        l.backgroundColor = UIColor.clearColor()
        l.font = UIFont(name:"Helvetica-Bold", size:50.0)
        l.textColor = UIColor(red:1.0, green:1.0, blue:1.0, alpha:0.8)
        l.shadowColor = UIColor.darkGrayColor()
        l.shadowOffset = CGSizeMake(0.0, 1.0)
        l.numberOfLines = 1
        l.text = siteData!["title"];
// TODO        l.frame = CGRectMake(0, 0, l.text!.sizeWithFont(l.font).width, l.text!.sizeWithFont(l.font).height)
        l.adjustsFontSizeToFitWidth = true
        l.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)
        l.sizeToFit()
        
        self.dozukiTitleLabel = l
        self.dozukiTitleLabel.alpha = 0
        self.backgroundView.addSubview(self.dozukiTitleLabel)
        
        
        UIView.animateWithDuration(0.3, animations:{
            self.dozukiTitleLabel.alpha = 1;
        })
    }
    
    func configureInstructionsLabel() {
        let config = Config.currentConfig()
        
        let l = UILabel(frame:CGRectMake(135, 254, 280, 30))
        l.autoresizingMask = .FlexibleWidth
        l.textAlignment = .Center
        l.lineBreakMode = .ByWordWrapping
        l.backgroundColor = UIColor.clearColor()
        l.font = UIFont(name:"OpenSans-Bold", size:17.0)
        l.textColor = config.textColor
        l.alpha = 0.8
        l.shadowColor = UIColor.darkGrayColor()
        l.shadowOffset = CGSizeMake(0.0, 1.0)
        l.numberOfLines = 0
        
        // TODO: Make this a config setting, not a silly if else statement here
        if (config.site == .Accustream) {
            l.text = NSLocalizedString("Welcome to our 24/7 support app, below you will find an assortment of how-to guides that will lead you step by step through the assembly of various HyPrecision, Accustream, and OEM parts", comment:"")
        } else {
            l.text = config.dozuki ?
            NSLocalizedString("Looking for Guides? Browse them here.", comment:"") :
            NSLocalizedString("Looking for Guides? Browse thousands of them here.", comment:"")
        }
        l.sizeToFit()
        
        self.browseInstructions = l
        self.backgroundView.addSubview(self.browseInstructions)
    }

    func styleForRow(row:Int) -> DMPGridViewCellStyle? {
        return UIInterfaceOrientationIsPortrait(orientationOverride) ?
        .PortraitColumns : .LandscapeColumns
    }

    func numberOfCellsForGridViewController(gridViewController:DMPGridViewController) -> Int {
        return guides?.count ?? 0
    }
    
    func gridViewController(gridViewController:DMPGridViewController, imageURLForCellAtIndex index:Int) -> NSURL? {
        if guides?.count == 0 {
            return nil
        }
        
        let image = guides?[Int(index)].image
        
        return image?.medium
    }
    
    func gridViewController(gridViewController:DMPGridViewController, titleForCellAtIndex index:Int) -> String {
        
        if guides?.count == 0 {
            return NSLocalizedString("Loading...", comment:"");
        }
        
        let guide = guides?[Int(index)]
        var title = guide?.title ?? NSLocalizedString("Untitled", comment:"")
        
        title = title.stringByReplacingOccurrencesOfString("&amp;", withString:"&")
        title = title.stringByReplacingOccurrencesOfString("&quot;", withString:"\"")
        title = title.stringByReplacingOccurrencesOfString("<wbr />", withString:"")
        
        return title
    }
    
    func gridViewController(gridViewController:DMPGridViewController, tappedCellAtIndex index: Int) {
        let delegate = UIApplication.sharedApplication().delegate as! iFixitAppDelegate
        
        let iGuideid = guides?[Int(index)].iGuideid
        let vc = GuideViewController(guideid:iGuideid!)
        let nc = UINavigationController(rootViewController:vc)
        delegate.window?.rootViewController?.presentViewController(nc, animated:true, completion:nil)
    }

}
