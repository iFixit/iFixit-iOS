//
//  PastFeaturesViewController.m
//  iFixit
//
//  Created by David Patierno on 11/7/11.
//  Copyright (c) 2011 iFixit. All rights reserved.
//


class PastFeaturesViewController: UITableViewController {

    var collections:[[String:AnyObject]] = []
    var dateFormat:NSDateFormatter!
    var delegate:PastFeaturesViewDelegate?

    override init(style:UITableViewStyle) {
        super.init(style:.Grouped)
        self.title = NSLocalizedString("Past Features", comment:"")
        
        self.dateFormat = NSDateFormatter()
        dateFormat.dateFormat = "MM/dd"
}

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func TODOsetCollections(collections:[[String:AnyObject]]) {
        self.collections = collections
        self.tableView.reloadData()
    }

    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.collections.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let CellIdentifier = "Cell"
        
        var cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier)
        if (cell == nil) {
            cell = UITableViewCell(style:.Default, reuseIdentifier:CellIdentifier)
        }
        
        // Configure the cell...
        let collection = self.collections[indexPath.row]
        let date = NSDate(timeIntervalSince1970:(collection["date"] as! NSTimeInterval))
        let title = collection["title"] as! String
        
        let dateString = dateFormat.stringFromDate(date)
        cell!.textLabel!.text = "\(dateString) \(title)"
        
        return cell!
    }

    // MARK: - Table view delegate

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate?.collection = collections[indexPath.row]
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

}
