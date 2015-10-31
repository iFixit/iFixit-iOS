    //
//  GuideImageViewController.m
//  iFixit
//
//  Created by David Patierno on 8/14/10.
//  Copyright 2010 iFixit. All rights reserved.
//
class GuideImageViewController: UIViewController, UIScrollViewDelegate, TapDetectingImageViewDelegate {
    
    let ZOOM_VIEW_TAG = 100
    
    var delegate:UIViewController!
    var imageScrollView:UIScrollView!
    var image:UIImage!
    var delay:NSDate!
    
    var doubleTap = false

    var frameView:CGRect?

    func detectOrientation() {
        if (delegate.view.frame.size.width > 400.0) {
            frameView = CGRectMake(0.0, 0.0, 480.0, 320.0)
        } else {
            frameView = CGRectMake(0.0, 0.0, 320.0, 480.0)
        }
        
        self.view.frame = frameView!
    }

    init(image:UIImage?, delegate d:UIViewController) {
        super.init(nibName:nil, bundle:nil)
        
        self.image = image
        self.delegate = d
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }

    class func zoomWithUIImage(image:UIImage?, delegate:UIViewController) -> UIViewController {
        let vc = GuideImageViewController(image:image, delegate:delegate)
        vc.view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        vc.modalTransitionStyle = .CrossDissolve
        
// TODO       vc.wantsFullScreenLayout = true
        
        if (UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
            vc.frameView = CGRectMake(0.0, 0.0, 1024.0, 748.0)
            vc.view.frame = vc.frameView!
        }
        else {
            vc.detectOrientation()
        }
        
        return vc
    }

    override func loadView() {
        super.loadView()
        
        UIApplication.sharedApplication().statusBarHidden = true
        
        // set up main scroll view
        self.imageScrollView = UIScrollView(frame:self.view.frame)
        imageScrollView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        imageScrollView.backgroundColor = Config.currentConfig().backgroundColor
        imageScrollView.delegate = self
        imageScrollView.bouncesZoom = true
        self.view.addSubview(imageScrollView)
        self.view.sendSubviewToBack(imageScrollView)
        
        // add touch-sensitive image view to the scroll view
        let imageView = UIImageView(image:self.image)
        
        imageView.tag = ZOOM_VIEW_TAG
        imageView.userInteractionEnabled = true
        //[imageScrollView setContentSize:[imageView frame].size];
        imageView.frame = CGRectMake(0.0, 0.0, 1600.0, 1200.0)
        imageScrollView.contentSize = CGSizeMake(1600.0, 1200.0)
        imageScrollView.addSubview(imageView)
        
        // calculate minimum scale to perfectly fit longer edge, and begin at that scale
        let minimumWidthScale = imageScrollView.frame.size.width / imageView.frame.size.width;
        let minimumHeightScale = imageScrollView.frame.size.height / imageView.frame.size.height;
        let minimumScale = fmax(minimumWidthScale, minimumHeightScale)
        
        imageScrollView.minimumZoomScale = minimumScale
        imageScrollView.zoomScale = minimumScale
        imageScrollView.maximumZoomScale = 2.0
        
        let center = CGPointMake(0, 0)
        let zoomRect = self.zoomRectForScale(minimumScale, withCenter:center)
        imageScrollView.zoomToRect(zoomRect, animated:false)
        
        self.setupTouchEvents(imageView)
        
        self.delay = NSDate()
        
        // Show the x icon.
        let backFrame = CGRectMake(5, 5, 50, 50)
        let x = UIImage(named:"x-icon.png")
        let back = UIButton(type:.Custom)
        back.alpha = 0.4
        back.setBackgroundImage(x, forState:.Normal)
        back.userInteractionEnabled = false
        //[back addTarget:delegate action:@selector(hideGuideImage:) forControlEvents:UIControlEventTouchUpInside];
        back.frame = backFrame;
        self.view.addSubview(back)
    }
    
    func setupTouchEvents(imageView:UIImageView) {
        
        // add gesture recognizers to the image view
        let singleTapG = UITapGestureRecognizer(target:self, action:"handleSingleTap:")
        let doubleTapG = UITapGestureRecognizer(target:self, action:"handleDoubleTap:")
        let twoFingerTapG = UITapGestureRecognizer(target:self, action:"handleTwoFingerTap:")
        
        doubleTapG.numberOfTapsRequired = 2
        twoFingerTapG.numberOfTouchesRequired = 2
        
        imageView.addGestureRecognizer(singleTapG)
        imageView.addGestureRecognizer(doubleTapG)
        imageView.addGestureRecognizer(twoFingerTapG)
    }

    // MARK: UIScrollViewDelegate methods
    
    func viewForZoomingInScrollView(scrollView:UIScrollView)-> UIView? {
        return imageScrollView.viewWithTag(ZOOM_VIEW_TAG)
    }

    // MARK: TapDetectingImageViewDelegate methods

    func handleSingleTap(gestureRecognizer:UIGestureRecognizer) {
        
        if (delay.timeIntervalSinceNow > -0.5) {
            return
        }
        
        doubleTap = false
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            NSThread.sleepForTimeInterval(0.25)
            
            if (!self.doubleTap) {
                dispatch_async(dispatch_get_main_queue(), {
                    UIApplication.sharedApplication().statusBarHidden = false
                    self.delegate.dismissViewControllerAnimated(true, completion:nil)
                })
            }
            
        })
    }

    func handleDoubleTap(gestureRecognizer:UIGestureRecognizer) {
        doubleTap = true
        
        // double tap zooms in and out
        var newScale: CGFloat
        if (imageScrollView.zoomScale == imageScrollView.minimumZoomScale) {
            newScale = 2.0
        } else {
            newScale = imageScrollView.minimumZoomScale
        }
        
        let zoomRect = zoomRectForScale(newScale, withCenter:gestureRecognizer.locationInView(gestureRecognizer.view))
        imageScrollView.zoomToRect(zoomRect, animated:true)
    }

    func handleTwoFingerTap(gestureRecognizer:UIGestureRecognizer) {
        // two-finger tap zooms out
        let newScale = imageScrollView.minimumZoomScale
        let zoomRect = self.zoomRectForScale(newScale, withCenter:gestureRecognizer.locationInView(gestureRecognizer.view))
        imageScrollView.zoomToRect(zoomRect, animated:true)
    }

    // MARK: Utility methods

    func zoomRectForScale(scale:CGFloat, withCenter center:CGPoint) -> CGRect {
        
        var zoomRect: CGRect!
        
        // the zoom rect is in the content view's coordinates.
        //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
        //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
        zoomRect.size.height = imageScrollView.frame.size.height / scale
        zoomRect.size.width  = imageScrollView.frame.size.width  / scale
        
        // choose an origin so as to get the right center.
        zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0)
        zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0)
        
        return zoomRect
    }

    }
