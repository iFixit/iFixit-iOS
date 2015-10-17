//
//  GuideIntroViewController.m
//  iFixit
//
//  Created by David Patierno on 8/9/10.
//  Copyright 2010 iFixit. All rights reserved.
//
    
class GuideIntroViewController: UIViewController, UIWebViewDelegate {

    var delegate: UIViewController?
    
    @IBOutlet weak var headerImageLogo:UIImageView!
    @IBOutlet weak var headerTextDozuki:UILabel!
    @IBOutlet weak var overlayView:UIView!
    @IBOutlet weak var swipeLabel:UILabel!
    @IBOutlet weak var device:UILabel!
    @IBOutlet weak var mainImage:UIImageView!
    @IBOutlet weak var webView:GuideCatchingWebView!
    
    var guide:Guide!
    var huge:UIImage?
    var html:String?

    init(guide:Guide) {
        super.init(nibName: nil, bundle: nil)
        
        self.guide = guide
        self.huge = nil
}

    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }

    func removeWebViewShadows() {
        let subviews = webView.subviews
        if subviews.count != 0 {
            for wview in subviews[0].subviews {
                if wview is UIImageView {
                    wview.hidden = true
                }
            }
        }
    }

    func addViewShadow(view:UIView) {
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            // Apply a blur!
            view.layer.rasterizationScale = 0.25
            view.layer.shouldRasterize = true
            return
        }
        
        view.layer.masksToBounds = false
        view.layer.shadowOffset = CGSizeMake(0.0, 1.0)
        view.layer.shadowRadius = 3.0
        view.layer.shadowOpacity = 0.8
        view.layer.shadowPath = UIBezierPath(rect:view.bounds).CGPath
    }

    func configureIntroTitleLogo() {
        let config = Config.currentConfig()
        
        if let logo = config.siteInfo["logo"] as? [String:AnyObject],
            let image = logo["image"] as? [String:AnyObject],
            let large = image["large"] as? String {
                headerImageLogo.contentMode = .ScaleAspectFit
                headerImageLogo.setImageWithURL(NSURL(string:large))
        } else {
            headerImageLogo.hidden = true
            headerTextDozuki.font = UIFont(name:"Helvetica-Bold", size:75.0)
            headerTextDozuki.text = (config.siteData["title"] as! String)
            headerTextDozuki.hidden = false
        }
    }

    override func viewDidLoad() {
        let config = Config.currentConfig()
        
        super.viewDidLoad()
        
        // Set the appropriate header image.
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            var image:UIImage!
            
            switch (config.site) {
            case .Make:
                image = UIImage(named:"logo_make.png")
                headerImageLogo.frame = CGRectMake(headerImageLogo.frame.origin.x, headerImageLogo.frame.origin.y, image.size.width, image.size.height)
                headerImageLogo.image = image

            case .Zeal:
                image = UIImage(named:"logo_zeal@2x.png")
                headerImageLogo.frame = CGRectMake(headerImageLogo.frame.origin.x, headerImageLogo.frame.origin.y, image.size.width, image.size.height)
                headerImageLogo.image = image

            case .Mjtrim:
                image = UIImage(named:"mjtrim_logo_transparent.png")
                headerImageLogo.frame = CGRectMake(headerImageLogo.frame.origin.x, headerImageLogo.frame.origin.y, image.size.width, image.size.height)
                headerImageLogo.image = image

            case .Accustream:
                headerImageLogo.image = UIImage(named:"accustream_logo_transparent.png")

            case .Magnolia:
                image = UIImage(named:"magnoliamedical_logo_transparent.png")
                headerImageLogo.frame = CGRectMake(headerImageLogo.frame.origin.x, headerImageLogo.frame.origin.y, image.size.width/1.5, image.size.height/1.5)
                headerImageLogo.image = image
                break;
            case .Comcast:
                image = UIImage(named:"comcast_logo_transparent.png")
                headerImageLogo.frame = CGRectMake(headerImageLogo.frame.origin.x, headerImageLogo.frame.origin.y - 30, image.size.width/2, image.size.height/2)
                headerImageLogo.image = image

            case .DripAssist:
                image = UIImage(named:"dripassist_logo_transparent.png")
                headerImageLogo.frame = CGRectMake(headerImageLogo.frame.origin.x, headerImageLogo.frame.origin.y, image.size.width/2, image.size.height/2)
                headerImageLogo.image = image

            case .Pva:
                image = UIImage(named:"pva_logo_transparent.png")
                headerImageLogo.frame = CGRectMake(headerImageLogo.frame.origin.x, headerImageLogo.frame.origin.y, image.size.width/2, image.size.height/2)
                headerImageLogo.image = image

            case .Oscaro:
                image = UIImage(named:"oscaro_logo_transparent.png")
                headerImageLogo.frame = CGRectMake(headerImageLogo.frame.origin.x, headerImageLogo.frame.origin.y, image.size.width/2, image.size.height/2)
                headerImageLogo.image = image

                /*EAOGuideIntro*/
            case .Dozuki:
                self.configureIntroTitleLogo()
                
            default:
                break
            }
        }
        
        // Hide the swipe label if there are no steps.
        if self.guide.steps.count == 0 {
            swipeLabel.hidden = true
        }
        
        if (config.buttonColor != nil) {
            self.navigationItem.rightBarButtonItem?.tintColor = config.buttonColor
            self.navigationItem.leftBarButtonItem?.tintColor = config.buttonColor
        }
        
        let bgColor = UIColor.clearColor()
        
        if config.backgroundColor == UIColor.whiteColor() {
            overlayView.backgroundColor = UIColor.whiteColor()
            overlayView.alpha = 0.3
        }
        
        self.view.backgroundColor = bgColor
        webView.modalDelegate = delegate
        webView.backgroundColor = bgColor
        webView.opaque = false
        
        // Load the intro contents as HTML.
        let deviceSize = (UIDevice.currentDevice().userInterfaceIdiom == .Pad) ? "big" : "small"
        let header = "<html><head><style type=\"text/css\"> \(config.introCSS!) </style></head><body class=\"\(deviceSize)\">"
        
        let docsHtml = buildHtmlForDocs(self.guide.documents)
        let partsHtml = buildHtmlForItems(self.guide.parts, fromType:"part")
        let toolsHtml = buildHtmlForItems(self.guide.parts, fromType:"tool")
        
        let body = "\(self.guide.introduction_rendered)\(docsHtml)\(partsHtml)\(toolsHtml)"
        
        self.html = "\(header)\(body)</body></html>"

        webView.loadHTMLString(html!, baseURL:NSURL(string:"http://\(config.host!)"))
        
        self.removeWebViewShadows()
        
        device?.text = self.guide.category
        
        // Add a shadow to the image
        self.addViewShadow(mainImage)
        
        mainImage.setImageWithURL(self.guide.image!.standard, placeholderImage:nil)
        
        swipeLabel.adjustsFontSizeToFitWidth = true
        let swipeText = NSLocalizedString("Swipe to Begin", comment:"")
        swipeLabel.text = " ←\(swipeText) "
    }

    func buildHtmlForDocs(docs:[[String:AnyObject]]) -> String {
        
        // Return an empty string if no docs are found
        if docs.count == 0 {
            return ""
        }
        
        var html = "<div class=\"files\"><strong>Files</strong><ul>"
        
        for doc in docs {
            // We cannot display offline pdfs in our current
            // Guide Intro view because it's full of Webviews. When we make a
            // pretty native view, we can enable offline documents.
            let docUrl = doc["download_url"] as! String
            let docText = doc["text"] as! String

            html = "\(html)<li><a href=\"\(docUrl)\">\(docText)</a></li>"
        }
        
        return "\(html)</ul></div>"
    }

// Temporary method to build html for parts/tools, remove when we implement a native view
    func buildHtmlForItems(items:[[String:AnyObject]], fromType itemType:String) -> String {
        
        // Return an empty string if we have no items
        if items.count == 0 {
            return ""
        }
        
        var html = "<div class=\"\(itemType)s\"><strong>\(itemType.capitalizedString)s</strong><ul>"
        
        for item in items {
            let url = item["url"] as! String
            let quantity = item["quantity"] as! String
            let text = item["text"] as! String

            html = "\(html)<li><a href=\"\(url)\">\(quantity) x \(text)</a></li>"
        }
        
        return "\(html)</ul></div>"
    }

// Because the web view has a white background, it starts hidden.
// After the content is loaded, we wait a small amount of time before showing it to prevent flicker.
    func webViewDidFinishLoad(webView: UIWebView) {
        self.performSelector("showWebView:", withObject: nil, afterDelay: 0.2)
        self.webView.enableScrollingIfNeeded()
    }
    
    func showWebView(sender:AnyObject) {
        UIView.transitionWithView(webView,
            duration:0.5,
            options:.TransitionCrossDissolve,
            animations:{
                self.webView.hidden = false
            }, completion:nil)
    }

    @IBAction func zoomImage(sender:AnyObject) {
        // Disabled on the intro.
        return
    }

    func layoutLandscape() {
        // iPad
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            swipeLabel.frame = CGRectMake(600.0, 563.0, 375.0, 84.0)
            webView.frame = CGRectMake(20.0, 160.0, 984.0, 395.0)
        }
            // iPhone
        else {
            var frame = webView.frame
            frame.size.height = 180
            webView.frame = frame
        }
    }
    
    func layoutPortrait() {
        let screenSize = UIScreen.mainScreen().bounds.size
        
        // iPad
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            swipeLabel.frame = CGRectMake(340.0, 790.0, 375.0, 84.0)
            webView.frame = CGRectMake(20.0, 160.0, 728.0, 605.0)
        }
            // iPhone
        else {
            webView.frame = CGRectMake(0.0, 20, webView.frame.size.width, screenSize.height - 175) // 305
            swipeLabel.frame = CGRectMake(0.0, 0.0, 320.0, 45.0)
        }
    }
    
    func documentDirectoryURL() -> NSURL {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }

    func getOfflineDocumentPath(guideDocument:NSMutableDictionary) -> NSURL {
        let uid = iFixitAPI.sharedInstance.user?.iUserid
        let documentPath = documentDirectoryURL().URLByAppendingPathComponent("Documents")
        let documentid = guideDocument["documentid"] as! String
        let filename = "\(uid)_\(self.guide.iGuideid)_\(documentid).pdf"
        let filePath = documentPath.URLByAppendingPathComponent(filename)
        
        return filePath
    }

    override func willRotateToInterfaceOrientation(toInterfaceOrientation:UIInterfaceOrientation, duration:NSTimeInterval) {
        let config = Config.currentConfig()
        
        if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
            layoutLandscape()
        }
        else {
            layoutPortrait()
        }
        
        // Re-flow HTML
        webView.loadHTMLString(html!, baseURL:NSURL(string:"http://\(config.host!)"))
    }

}
