//
//  DMPGridViewController.m
//  DMPGridViewController
//
//  Created by David Patierno on 11/7/11.
//  Copyright (c) 2011. All rights reserved.
//

class DMPGridViewController : UITableViewController {

    var delegate: DMPGridViewDelegate?

    override init(nibName:String?, bundle:NSBundle?) {
        super.init(nibName:nibName, bundle:bundle)
    }
    
    init(delegate:DMPGridViewDelegate?) {
        
        super.init(style:.Plain)
        
        self.delegate = delegate
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didReceiveMemoryWarning() {
        // Releases the view if it doesn't have a superview.
        super.didReceiveMemoryWarning()
        
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - View lifecycle

    override func viewWillAppear(animated:Bool) {
        self.tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.separatorStyle = .None
    }

    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation:UIInterfaceOrientation, duration:NSTimeInterval) {
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    func styleForRow(row:Int) -> DMPGridViewCellStyle {
        var style:DMPGridViewCellStyle?
        
        if UIInterfaceOrientationIsPortrait(self.interfaceOrientation) {
            style = DMPGridViewCellStyle(rawValue:row + 1 % 4)
        } else {
            style = DMPGridViewCellStyle(rawValue:row + 1 % 3 + 4)
        }
        
        return style!
    }

    override func numberOfSectionsInTableView(tableView:UITableView) -> Int {
        return 1
    }

    override func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
        var numberOfCells = delegate!.numberOfCellsForGridViewController(self)
        
        var rows = 0
        for (var i=0; numberOfCells>0; i += 1) {
            numberOfCells -= DMPGridViewCell.cellsPerRowForStyle(self.styleForRow(i))
            rows += 1
        }
        
        return rows
    }

    override func tableView(tableVIew:UITableView, heightForRowAtIndexPath indexPath:NSIndexPath) -> CGFloat {
        return 235.0
    }

    override func tableView(tableView:UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
        // Choose a row style.
        var style = self.styleForRow(indexPath.row)
        
        let CellIdentifier = "Cell\(style)"
        
        var cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier)
        if (cell == nil) {
            cell = UITableViewCell(style: .Default, reuseIdentifier:CellIdentifier)
            cell?.selectionStyle = .None
        } else {
            // Remove any existing DMPGridViewCells since we don't reuse them.
            for v in cell!.contentView.subviews {
                v.removeFromSuperview()
            }
        }
        
        // Configure the cell...
        var offset = 0
        for i in 0 ..< indexPath.row {
            offset += DMPGridViewCell.cellsPerRowForStyle(self.styleForRow(i))
        }
        
        var numberOfCells = delegate?.numberOfCellsForGridViewController(self)
        
        for i in 0 ..< DMPGridViewCell.cellsPerRowForStyle(style) {
            if (offset + i >= numberOfCells) {
                break
            }
            
            var gridCell = DMPGridViewCell(style:style, index:i)
            
            // Image
            if let url = delegate?.gridViewController!(self, imageURLForCellAtIndex:offset + i) {
                gridCell.imageView.setImageWithURL(url, placeholderImage:UIImage(named:"WaitImage.png"))
            } else {
                let image = delegate?.gridViewController!(self, imageForCellAtIndex:offset + i)
                gridCell.imageView.image = image
            }
            
            // Title
            var text = delegate?.gridViewController(self, titleForCellAtIndex:offset + i)
            let label = gridCell.textLabel
            label.text = text
            label.font = UIFont.systemFontOfSize(14.0)
            label.numberOfLines = 2;
            label.adjustsFontSizeToFitWidth = true
            
            // Handle taps.
            gridCell.tag = offset + i
            var g = UITapGestureRecognizer(target:self, action:"tap:")
            g.numberOfTapsRequired = 1
            g.numberOfTouchesRequired = 1
            gridCell.addGestureRecognizer(g)
            
            cell?.contentView.addSubview(gridCell)
        }
        
        // For iOS 7, ensures we have a transparent background
        cell?.backgroundColor = UIColor.clearColor()
        
        return cell!
    }

    func tap(gestureRecognizer:UIGestureRecognizer) {
        delegate?.gridViewController(self, tappedCellAtIndex:gestureRecognizer.view!.tag)
    }

}
