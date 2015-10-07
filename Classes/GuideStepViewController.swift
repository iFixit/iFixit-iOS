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
//        for subview in webView.subviews {
        NSArray *subviews = [webView subviews];
        if ([subviews count]) {
            for (UIView *wview in [[subviews objectAtIndex:0] subviews]) {
                if ([wview isKindOfClass:[UIImageView class]]) {
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

    func getOfflineVideoPath() -> String {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)
        NSString *docDirectory = paths[0]
        
        NSString *filePath = [docDirectory stringByAppendingPathComponent:
                              [NSString stringWithFormat:"/Videos/%@_%li_%li_%", [iFixitAPI sharedInstance].user.iUserid, (long)self.step.stepid, (long)self.step.video.videoid, self.step.video.filename]]
        return filePath
    }

    // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ?
        layoutLandscape() : layoutPortrait()
        
        var bgColor = UIColor.clearColor()
        
        self.view.backgroundColor = bgColor
        webView.modalDelegate = delegate
        webView.backgroundColor = bgColor
        webView.opaque = false
        
        let stepTitle = NSLocalizedString("Step \(absoluteStepNumber)", comment:"")
        if self.step.title != "" {
            stepTitle = [NSString stringWithFormat:"%@ - %", stepTitle, self.step.title]
        }
        
        titleLabel.text = stepTitle
        titleLabel.textColor = [Config currentConfig].textColor;
        
        // Load the step contents as HTML.
        let bodyClass = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) ? "big" : "small"
        if ([UIScreen mainScreen].scale == 2.0)
            bodyClass = [bodyClass stringByAppendingString:" retina"];
        let header = "<html><head><style type=\"text/css\"> \(config.stepCSS) </style></head><body class=\"\(bodyClass)\"><ul>"
        let footer = "</ul></body></html>"
        
        var body = ""
        for line in self.step.lines {
            var icon = ""
            
            if ([line.bullet isEqual:"icon_note"] || [line.bullet isEqual:"icon_reminder"] || [line.bullet isEqual:"icon_caution"]) {
                icon = "<div class=\"bulletIcon bullet_\(line.bullet)\"></div>"
                line.bullet = "black"
            }
            
            [body appendFormat:"<li class=\"l_%d\"><div class=\"bullet bullet_%@\"></div>%@<p>%@</p><div style=\"clear: both\"></div></li>\n", line.level, line.bullet, icon, line.text];
        }
        
        self.html = "\(header)\(body)\(footer)"
        [webView loadHTMLString:html baseURL:[NSURL URLWithString:[NSString stringWithFormat:"http://%", [Config host]]]];
        
        removeWebViewShadows()
        
        // Images
        if (self.step.images != nil) {
            // Add a shadow to the images
            [self addViewShadow:mainImage];
            [self addViewShadow:image1];
            [self addViewShadow:image2];
            [self addViewShadow:image3];
            
            startImageDownloads()
        }
        // Videos
        else if (self.step.video != nil) {
            // Hide main image since we are displaying a video
            mainImage.hidden = true
            
            var frame = mainImage.frame
            frame.origin.x = 10.0
            
            // If we are an offline guide, let's get our video from disk, otherwise we load the URL
            let url = self.guideViewController.offlineGuide ?
            [NSURL fileURLWithPath:[self getOfflineVideoPath] isDirectory:NO] :
            [NSURL URLWithString:self.step.video.url];
            
            self.moviePlayer = MPMoviePlayerController(contentURL:url)
            self.moviePlayer.shouldAutoplay = false
            self.moviePlayer.controlStyle = .Embedded
            [self.moviePlayer.view setFrame:frame]
            [self.view addSubview:self.moviePlayer.view]
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
            
            let oembedURL = "\(step.embed.url)&maxwidth=%d&maxheight=%d",
                                   (int)self.embedView.frame.size.width,
                                   (int)self.embedView.frame.size.height];
            NSURL *url = [NSURL URLWithString:oembedURL];
            [ASIHTTPRequest requestWithURL:url];
            
            __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
            [request setCompletionBlock:^{
                let json:[String:AnyObject] = [[request responseString] JSONValue];
                let embedHtml = json["html"] as! String
                let header = "<html><head><style type=\"text/css\"> \(config.stepCSS) </style></head><body>"
                let htmlString = "\(header) \(embedHtml)"
                
                [embedView loadHTMLString:htmlString
                                  baseURL:[NSURL URLWithString:[json objectForKey:"provider_url"]]];
            }];
            [request startAsynchronous];
        }
        
        // Notification to Fix rotation while playing video.
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_moviePlayerWillExitFullscreen:)
                                                     name:MPMoviePlayerWillExitFullscreenNotification
                                                   object:nil];
        
        // Notification to track when the movie player state changes (ie: Pause, Play)
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_moviePlayerPlaybackStateDidChange:)
                                                     name:MPMoviePlayerPlaybackStateDidChangeNotification
                                                   object:nil];
        
        // Notification to track when a movie finishes playing
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(_moviePlayerPlaybackDidFinish:)
                                                     name:MPMoviePlayerPlaybackDidFinishNotification
                                                   object:nil];
        
    }

    override func viewDidAppear(animated:Bool) {
        // Analytics
        let gaInfo = [[GAIDictionaryBuilder createEventWithCategory:"Guide" action:"Step View" label:"User viewed step" value:self.absoluteStepNumber] build];
        GAI.sharedInstance.defaultTracker.send(gaInfo)
    }

    func _moviePlayerPlaybackDidFinish(notification:NSNotification) {
        if (self.moviePlayer.fullscreen) {
            moviePlayer.setFullscreen(false, animated:true)
        }
    }

    func _moviePlayerPlaybackStateDidChange(notification:NSNotification) {
        if (!self.moviePlayer.fullscreen && self.moviePlayer.playbackState == MPMoviePlaybackStatePlaying) {
            [self.moviePlayer setFullscreen:YES animated:YES];
        }
    }

    func moviePlayerWillExitFullscreen(notification:NSNotification) {
        delegate.willRotateToInterfaceOrientation(delegate.interfaceOrientation, duration:0)
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
        if ([self.step.images count] > 0) {
            // Download the image
            [mainImage setImageWithURL:[self.step.images[0] URLForSize:"large"] placeholderImage:[UIImage imageNamed:"WaitImage.png"]];
            
            if ([self.step.images count] > 1) {
                [image1 setImageWithURL:[[self.step.images objectAtIndex:0] URLForSize:"thumbnail"] placeholderImage:[UIImage imageNamed:"WaitImage.png"]];
                image1.hidden = false
            }
        }
        
        if ([self.step.images count] > 1) {
            [image2 setImageWithURL:[[self.step.images objectAtIndex:1] URLForSize:"thumbnail"] placeholderImage:[UIImage imageNamed:"WaitImage.png"]];
            image2.hidden = false
        }
        
        if ([self.step.images count] > 2) {
            [image3 setImageWithURL:[[self.step.images objectAtIndex:2] URLForSize:"thumbnail"] placeholderImage:[UIImage imageNamed:"WaitImage.png"]];
            image3.hidden = false
        }
    }

    @IBAction func changeImage(button:UIButton) {
        let guideImage = self.step.images[button.tag]
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        UIImage *cachedImage = [manager imageWithURL:[guideImage URLForSize:"large"]];
        
        // Use the cached image if we have it, otherwise download it
        if (cachedImage) {
            [UIView transitionWithView:mainImage
                              duration:0.3
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                [mainImage setBackgroundImage:cachedImage forState:UIControlStateNormal];
                            } completion:nil];
        } else {
            [mainImage setImageWithURL:[guideImage URLForSize:"large"] placeholderImage:[UIImage imageNamed:"WaitImage.png"]];
        }
    }

    // Because the web view has a white background, it starts hidden.
    // After the content is loaded, we wait a small amount of time before showing it to prevent flicker.
    func webViewDidFinishLoad(webView:UIWebView) {
        [self performSelector:@selector(showWebView:) withObject:nil afterDelay:0.2];
        [self.webView enableScrollingIfNeeded];
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
            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            
            if (self.step.images.count > 1 && ![manager imageWithURL:[self.step.images[1] URLForSize:"large"]]) {
                [manager downloadWithURL:[self.step.images[1] URLForSize:"large"] delegate:self retryFailed:YES];
            }
            
            if (self.step.images.count > 2 && ![manager imageWithURL:[self.step.images[2] URLForSize:"large"]]) {
                [manager downloadWithURL:[self.step.images[2] URLForSize:"large"] delegate:self retryFailed:YES];
            }
        }
        
    }
    
    @IBAction func zoomImage(sender: AnyObject) {
        let image = mainImage.backgroundImageForState(UIControlStateNormal)
        
        if (!image || [image isEqual:[UIImage imageNamed:"NoImage.jpg"]] ||
            [image isEqual:[UIImage imageNamed:"WaitImage.png"]]) {
            return;
        }
        
        UIApplication.sharedApplication().statusBarHidden = true
        
        // Create the image view controller and add it to the view hierarchy.
        let imageVC = GuideImageViewController(zoomWithUIImage:image, delegate:self)
        
        [delegate presentModalViewController:imageVC animated:YES];
        
        
        // Analytics
        let gaInfo = [[GAIDictionaryBuilder createEventWithCategory:"Guide"
                                                                       action:"Image zoom"
                                                                        label:"User zoomed in on image"
                                                                        value:self.guideViewController.iGuideid] build];
        GAI.sharedInstance.defaultTracker.send(gaInfo)
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
        [webView loadHTMLString:html baseURL:[NSURL URLWithString:"http://%@", [Config host]]]];
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }


}
