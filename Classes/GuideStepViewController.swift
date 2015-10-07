    //
//  GuideStepViewController.m
//  iFixit
//
//  Created by David Patierno on 8/7/10.
//  Copyright 2010 iFixit. All rights reserved.
//

import UIKit
import Alamofire
import MediaPlayer


class GuideStepViewController : UIViewController, UIWebViewDelegate, SDWebImageManagerDelegate {

    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var mainImage:UIButton!
    @IBOutlet weak var webView:GuideCatchingWebView!
    @IBOutlet weak var image1:UIButton!
    @IBOutlet weak var image2:UIButton!
    @IBOutlet weak var image3:UIButton!

    var delegate: UIViewController?
    var step:GuideStep!
    var moviePlayer:MPMoviePlayerController!
    var embedView:UIWebView!
    var guideViewController:GuideViewController!
    var numImagesLoaded = 0
    var absoluteStepNumber = 0
    var html:String!
    var largeImages:[String:String]!
    
    // Load the view nib and initialize the pageNumber ivar.
    init(step:GuideStep, withAbsolute stepNumber:Int) {
        
        self.absoluteStepNumber = stepNumber
        
        super.init(nibName:nil, bundle:nil)
        self.step = step
        self.numImagesLoaded = 0
        self.largeImages = [:]
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        view.layer.masksToBounds = false
        view.layer.shadowOffset = CGSizeMake(0.0, 1.0)
        view.layer.shadowRadius = 3.0
        view.layer.shadowOpacity = 0.8
        view.layer.shadowPath = UIBezierPath(rect:view.bounds).CGPath
    }

    func getOfflineVideoPath() -> NSURL? {
        let uid = iFixitAPI.sharedInstance.user!.iUserid
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let documentDirectory = urls[urls.count-1]
        let filename = "/Videos/\(uid)_\(step.stepid)_\(step.video.videoid)_\(step.video.filename)"

        
        let filePath = documentDirectory.URLByAppendingPathComponent(filename)
        
        return filePath
    }

    // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let config = Config.currentConfig()
        UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ?
        layoutLandscape() : layoutPortrait()
        
        var bgColor = UIColor.clearColor()
        
        self.view.backgroundColor = bgColor
        webView.modalDelegate = delegate
        webView.backgroundColor = bgColor
        webView.opaque = false
        
        var stepTitle = NSLocalizedString("Step \(absoluteStepNumber)", comment:"")
        if self.step.title != "" {
            stepTitle = "\(stepTitle) - \(step.title)"
        }
        
        titleLabel.text = stepTitle
        titleLabel.textColor = config.textColor;
        
        // Load the step contents as HTML.
        var bodyClass = UIDevice.currentDevice().userInterfaceIdiom == .Pad ? "big" : "small"
        if UIScreen.mainScreen().scale == 2.0 {
            bodyClass = "\(bodyClass) retina"
        }
        let header = "<html><head><style type=\"text/css\"> \(config.stepCSS) </style></head><body class=\"\(bodyClass)\"><ul>"
        let footer = "</ul></body></html>"
        
        var body = ""
        for line in self.step.lines {
            var icon = ""
            
            if line.bullet == "icon_note" || line.bullet == "icon_reminder" || line.bullet == "icon_caution" {
                icon = "<div class=\"bulletIcon bullet_\(line.bullet)\"></div>"
                line.bullet = "black"
            }
            
            body = "\(body)<li class=\"l_\(line.level)\"><div class=\"bullet bullet_\(line.bullet)\"></div>\(icon)<p>\(line.text)</p><div style=\"clear: both\"></div></li>\n"
        }
        
        self.html = "\(header)\(body)\(footer)"
        webView.loadHTMLString(html, baseURL:NSURL(string:"http://\(config.host)"))
        
        removeWebViewShadows()
        
        // Images
        if (step.images.count != 0) {
            // Add a shadow to the images
            addViewShadow(mainImage)
            addViewShadow(image1)
            addViewShadow(image2)
            addViewShadow(image3)
            
            startImageDownloads()
        }
        // Videos
        else if (self.step.video != nil) {
            // Hide main image since we are displaying a video
            mainImage.hidden = true
            
            var frame = mainImage.frame
            frame.origin.x = 10.0
            
            // If we are an offline guide, let's get our video from disk, otherwise we load the URL
            let url = self.guideViewController.offlineGuide ? getOfflineVideoPath() : step.video.url
            
            self.moviePlayer = MPMoviePlayerController(contentURL:url)
            self.moviePlayer.shouldAutoplay = false
            self.moviePlayer.controlStyle = .Embedded
            moviePlayer.view.frame = frame
            view.addSubview(moviePlayer.view)
        }
        // Embeds
        else if (self.step.embed != nil) {
            // Hide main image since we are displaying an embed
            mainImage.hidden = true
            var frame = mainImage.frame
            frame.origin.x = 10.0
            
            self.embedView = UIWebView(frame:frame)
            self.embedView.backgroundColor = UIColor.clearColor()
            self.embedView.opaque = false
            self.view.addSubview(embedView)
            
            let embedSize = embedView.frame.size
            
            let oembedURL = "\(step.embed.url)&maxwidth=\(embedSize.width)&maxheight=\(embedSize.height)"
            
            let url = NSURL(string:oembedURL)
            
            Alamofire.request(.GET, oembedURL).responseJSON { (req, resp, result) in
                if result.isSuccess {
                    let json = result.value as! [String:AnyObject]
                    let embedHtml = json["html"] as! String
                    let header = "<html><head><style type=\"text/css\"> \(config.stepCSS) </style></head><body>"
                    let htmlString = "\(header) \(embedHtml)"
                    
                    self.embedView.loadHTMLString(htmlString, baseURL:NSURL(string:json["provider_url"] as! String))
                }
            }
        }
        
        // Notification to Fix rotation while playing video.
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"_moviePlayerWillExitFullscreen:", name:MPMoviePlayerWillExitFullscreenNotification, object:nil)
        
        // Notification to track when the movie player state changes (ie: Pause, Play)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"_moviePlayerPlaybackStateDidChange:", name:MPMoviePlayerPlaybackStateDidChangeNotification, object:nil)
        
        // Notification to track when a movie finishes playing
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"_moviePlayerPlaybackDidFinish:", name:MPMoviePlayerPlaybackDidFinishNotification, object:nil)
    }

    override func viewDidAppear(animated:Bool) {
        // Analytics
        let gaInfo = GAIDictionaryBuilder.createEventWithCategory("Guide", action:"Step View", label:"User viewed step", value:absoluteStepNumber).build() as [NSObject:AnyObject]
        GAI.sharedInstance().defaultTracker.send(gaInfo)
    }

    func _moviePlayerPlaybackDidFinish(notification:NSNotification) {
        if (self.moviePlayer.fullscreen) {
            moviePlayer.setFullscreen(false, animated:true)
        }
    }

    func _moviePlayerPlaybackStateDidChange(notification:NSNotification) {
        if (!self.moviePlayer.fullscreen && self.moviePlayer.playbackState == .Playing) {
            moviePlayer.setFullscreen(true, animated:true)
        }
    }

    func moviePlayerWillExitFullscreen(notification:NSNotification) {
        delegate!.willRotateToInterfaceOrientation(delegate!.interfaceOrientation, duration:0)
    }

    override func viewWillDisappear(animated:Bool) {
        // In iOS 6 and up, this method gets called when the video player goes into full screen.
        // This prevents the movie player from stopping itself by only stopping the video if not in
        // full screen (meaning the view has actually disappeared).
        if (!self.moviePlayer.fullscreen) {
            moviePlayer.stop()
        }
    }

    func startImageDownloads() {
        let waitImage = UIImage(named:"WaitImage.png")
        
        if step.images.count > 0 {
            // Download the image
            mainImage.setImageWithURL(step.images[0].URLForSize("large"), placeholderImage:waitImage)
            
            if (step.images.count > 1) {
                image1.setImageWithURL(step.images[0].URLForSize("thumbnail"), placeholderImage:waitImage)
                image1.hidden = false
            }
        }
        
        if (step.images.count > 1) {
            image2.setImageWithURL(step.images[1].URLForSize("thumbnail"), placeholderImage:waitImage)
            image2.hidden = false
        }
        
        if (step.images.count > 2) {
            image3.setImageWithURL(step.images[2].URLForSize("thumbnail"), placeholderImage:waitImage)
            image3.hidden = false
        }
    }

    @IBAction func changeImage(button:UIButton) {
        let waitImage = UIImage(named:"WaitImage.png")
        let guideImage = self.step.images[button.tag]
        let manager = SDWebImageManager.sharedManager()
        let cachedImage = manager.imageWithURL(guideImage.URLForSize("large"))
        
        // Use the cached image if we have it, otherwise download it
        if (cachedImage != nil) {
            UIView.transitionWithView(mainImage,
                              duration:0.3,
                               options:.TransitionCrossDissolve,
                            animations:{
                                self.mainImage.setBackgroundImage(cachedImage, forState:.Normal)
                            }, completion:nil)
        } else {
            mainImage.setImageWithURL(guideImage.URLForSize("large"), placeholderImage:waitImage)
        }
    }

    // Because the web view has a white background, it starts hidden.
    // After the content is loaded, we wait a small amount of time before showing it to prevent flicker.
    func webViewDidFinishLoad(webView:UIWebView) {
        self.performSelector("showWebView:", withObject:nil, afterDelay:0.2)
//     TODO   webView.enabledScrollingIfNeeded()
    }
    
    func showWebView(sender:AnyObject) {
        webView.hidden = false
    }

// I'll leave this here in case we ever want to use this
    func webImageManager(imageManager:SDWebImageManager, didFinishWithImage image:UIImage) {
    }

    func loadSecondaryImages() {
        
        // Only load the secondary large images if we are looking at the current view being presented on the screen
        if (self.step.number == self.guideViewController.pageControl.currentPage) {
            let manager = SDWebImageManager.sharedManager()
            
            if (step.images.count > 1) {
                let url = step.images[1].URLForSize("large")
                
                if manager.imageWithURL(url) == nil {
                    manager.downloadWithURL(url, delegate:self, retryFailed:true)
                }
            }
            
            if (step.images.count > 2) {
                let url = step.images[2].URLForSize("large")
                
                if manager.imageWithURL(url) == nil {
                    manager.downloadWithURL(url, delegate:self, retryFailed:true)
                }
            }
        }
    }
    
    @IBAction func zoomImage(sender: AnyObject) {
        let image = mainImage.backgroundImageForState(.Normal)
        
        if (image == nil || image! == UIImage(named:"NoImage.jpg") || image! == UIImage(named:"WaitImage.png")) {
            return
        }
        
        UIApplication.sharedApplication().statusBarHidden = true
        
        // Create the image view controller and add it to the view hierarchy.
        let imageVC = GuideImageViewController(zoomWithUIImage:image, delegate:self)
        
        [delegate presentModalViewController:imageVC animated:YES];
        
        
        // Analytics
        let gaInfo = GAIDictionaryBuilder.createEventWithCategory("Guide", action:"Image zoom", label:"User zoomed in on image", value:guideViewController.iGuideid).build() as [NSObject:AnyObject]
        GAI.sharedInstance().defaultTracker.send(gaInfo)
    }

    func layoutLandscape() {
        // iPad
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            mainImage.frame = CGRectMake(20.0, 103.0, 592.0, 444.0)
            webView.frame = CGRectMake(620.0, 103.0, 404.0, 562.0)
            titleLabel.frame = CGRectMake(30.0, 30.0, 975.0, 65.0)
            titleLabel.textAlignment = .Right;
            
            var frame = mainImage.frame
            frame.origin.x = 10.0
            moviePlayer.view.frame = frame
            embedView.frame = frame
            
            frame = image1.frame
            frame.origin.y = 560.0
            
            frame.origin.x = 20.0
            image1.frame = frame
            
            frame.origin.x = 173.0
            image2.frame = frame
            
            frame.origin.x = 326.0
            image3.frame = frame
        }
        // iPhone
        else {
            let screenSize = UIScreen.mainScreen().bounds.size;
            
            // These dimensions represent the object's position BEFORE rotation,
            // and are automatically tweaked during animation with respect to their resize masks.
            var frame = image1.frame
            frame.origin.y = 170
            
            frame.origin.x = 20
            image1.frame = frame
            
            frame.origin.x = 90
            image2.frame = frame
            
            frame.origin.x = 160
            image3.frame = frame
            
            webView.frame = CGRectMake(230, 0, screenSize.height - 230, 236)
        }
    }
    
    func layoutPortrait() {
        // iPad
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            mainImage.frame = CGRectMake(20.0, 30.0, 592.0, 444.0)
            webView.frame = CGRectMake(20.0, 554.0, 615.0, 380.0)
            titleLabel.frame = CGRectMake(30.0, 489.0, 708.0, 65.0)
            titleLabel.textAlignment = .Left;
            
            var frame = mainImage.frame
            frame.origin.x = 10.0
            moviePlayer.view.frame = frame
            embedView.frame = frame
            
            frame = image1.frame
            frame.origin.x = 626.0
            
            frame.origin.y = 30.0
            image1.frame = frame
            
            frame.origin.y = 150.0
            image2.frame = frame
            
            frame.origin.y = 270.0
            image3.frame = frame
        }
        // iPhone
        else {
            let screenSize = UIScreen.mainScreen().bounds.size;
            
            // These dimensions represent the object's position BEFORE rotation,
            // and are automatically tweaked during animation with respect to their resize masks.
            var frame = image1.frame
            frame.origin.x = 238
            
            frame.origin.y = 10
            image1.frame = frame
            
            frame.origin.y = 62
            image2.frame = frame
            
            frame.origin.y = 115
            image3.frame = frame
            
            webView.frame = CGRectMake(0, 168, 320, screenSize.height - 255);
        }
    }

    override func willRotateToInterfaceOrientation(toInterfaceOrientation:UIInterfaceOrientation, duration:NSTimeInterval) {
        let config = Config.currentConfig()
        
        // Really stupid hack. This prevents the status bar from overlapping with the view controller on iOS
        // versions < 6.0. This works by forcing the status bar to always appear before we manipulate the view,
        // otherwise the view thinks that it does not exist and creates the overlapping issue.
        UIApplication.sharedApplication().statusBarHidden = false
        
        if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
            layoutLandscape()
        }
        else {
            layoutPortrait()
        }
        
        // Re-flow HTML
        webView.loadHTMLString(html, baseURL:NSURL(string:"http://\(config.host)"))
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }


}
