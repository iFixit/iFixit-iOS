//
//  DozukiInfoViewController.m
//  iFixit
//
//  Created by David Patierno on 8/16/11.
//  Copyright (c) 2011 iFixit. All rights reserved.
//

class DozukiInfoViewController : UIViewController {

    var dssvc: DozukiSelectSiteViewController!

    override init(nibName:String?, bundle:NSBundle?) {
        
        super.init(nibName:nibName, bundle:bundle)

        // Custom initialization
        self.dssvc = DozukiSelectSiteViewController(simple:true)
        self.title = NSLocalizedString("Back", comment:"")
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }

    func showList() {
        self.navigationController?.pushViewController(dssvc, animated:false)
    }

    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
    
        willRotateToInterfaceOrientation(self.interfaceOrientation, duration:0)
    }

}
