//
//  iPhoneDeviceViewController.m
//  iFixit
//
//  Created by David Patierno on 9/15/11.
//  Copyright (c) 2011 iFixit. All rights reserved.
//

import UIKit

class iPhoneDeviceViewController: UITableViewController, UIAlertViewDelegate {
    
    var topic:String?
    var guides:[Guide]!
    var currentCategory:String?
    var moreInfoHTML:String!
    var categoryMetaData:[String:AnyObject]!
    var listViewController:ListViewController!
    var categoryGuides:[String]!
    var showAnswers = false
    var showMoreInfo = false
    var loading = false

    init(topic:String?) {
        super.init(nibName:nil, bundle:nil)
        
        self.topic = topic
        self.guides = []
        
        if topic == nil {
            self.title = NSLocalizedString("Guides", comment:"")
        }
        
        self.getGuides()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }

    // MARK: - View lifecycle

    override func viewWillAppear(animated:Bool) {
        if (self.currentCategory != nil) {
            self.navigationItem.title = self.currentCategory!
        }
    }

    func showRefreshButton() {
        // Show a refresh button in the navBar.
        let refreshButton = UIBarButtonItem(barButtonSystemItem:.Refresh, target:self, action:"getGuides")
        self.navigationItem.rightBarButtonItem = refreshButton
    }

    func showLoading() {
        loading = true
        let container = UIView(frame:CGRectMake(0.0, 0.0, 28.0, 20.0))
        let spinner = UIActivityIndicatorView(frame:CGRectMake(0.0, 0.0, 20.0, 20.0))
        spinner.activityIndicatorViewStyle = (UIDevice.currentDevice().userInterfaceIdiom == .Pad) ?
        .Gray : .White;
        container.addSubview(spinner)
        spinner.startAnimating()
        
        let button = UIBarButtonItem(customView:container)
        self.navigationItem.rightBarButtonItem = button
    }
    
    func hideLoading() {
        loading = false
        self.navigationItem.rightBarButtonItem = nil
        self.listViewController.showFavoritesButton(self)
    }

    func getGuides() {
        if (!loading) {
            loading = true
            self.showLoading()
            
            if (self.topic != nil) {
                iFixitAPI.sharedInstance.getCategory(self.topic!, handler:{ (result) in
                    self.gotCategory(result)
                })
            } else {
                iFixitAPI.sharedInstance.getGuides(nil, handler:{ (guides) in
                    if (guides == nil) {
                        iFixitAPI.displayConnectionErrorAlert()
                        self.showRefreshButton()
                    }
                    
                    self.guides = guides
                    self.tableView.reloadData()
                    self.hideLoading()
                })
            }
        }
    }

    func gotCategory(data:[String:AnyObject]?) {
        if (data == nil) {
            iFixitAPI.displayConnectionErrorAlert()
            self.showRefreshButton()
            return
        }
        
        
        if let guideJsons = data!["guides"] as? [[String:AnyObject]] {
            self.guides = guideJsons.map { Guide(json:$0) }
            self.tableView.reloadData()
            self.hideLoading()
        } else {
            self.showRefreshButton()
        }
    }

    func alertView(alertView:UIAlertView, clickedButtonAtIndex buttonIndex:Int) {
        self.navigationController!.popViewControllerAnimated(true)
    }

    override func viewDidLoad() {
        let config = Config.currentConfig()
        
        super.viewDidLoad()
        
        // Grab reference to listViewController
        self.listViewController = self.navigationController as! ListViewController
        
        // Make room for the toolbar
        self.willRotateToInterfaceOrientation(self.interfaceOrientation, duration:0)
        
        if (loading) {
            self.showLoading()
        }
        
        // Show the Dozuki sites select button if needed.
        if (config.dozuki && self.topic == nil) {
            let icon = UIImage(named:"backtosites.png")
            let button = UIBarButtonItem(image:icon, style:.Bordered,
                                         target:UIApplication.sharedApplication() .delegate,
                                         action:"showDozukiSplash")
            self.navigationItem.leftBarButtonItem = button
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
        return 1
    }

    override func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
        // Return the number of rows in the section.
        return self.guides.count
    }

    override func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
        let CellIdentifier = "GuideCell"
        
//        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier, forIndexPath:indexPath)
        
        var cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as? GuideCell
        if (cell == nil) {
            cell = GuideCell(style:.Default, reuseIdentifier:CellIdentifier)
        }

        
        // Configure the cell...
        var title = self.guides[indexPath.row].title ?? NSLocalizedString("Untitled", comment:"")
        
        
        title = title.stringByReplacingOccurrencesOfString("&amp;", withString:"&")
        title = title.stringByReplacingOccurrencesOfString("&quot;", withString:"\"")
        title = title.stringByReplacingOccurrencesOfString("<wbr />", withString:"")
        
        cell!.textLabel!.text = title
        
        let imageData = guides[indexPath.row].image
        let thumbnailURL = imageData?.thumbnail
        
        cell!.imageView!.setImageWithURL(thumbnailURL, placeholderImage:UIImage(named:"WaitImage.png"))
        
        return cell!
    }

    // MARK: - Table view delegate

    override func tableView(tableView:UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath) {
        GuideLib.loadAndPresentGuideForGuideid(self.guides[indexPath.row].iGuideid as NSNumber)
        self.tableView.deselectRowAtIndexPath(indexPath, animated:true)
    }

}
