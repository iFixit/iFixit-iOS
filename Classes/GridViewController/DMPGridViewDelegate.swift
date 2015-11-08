//
//  DMPGridViewDelegate.h
//  DMPGridViewController
//
//  Created by David Patierno on 11/7/11.
//  Copyright (c) 2011. All rights reserved.
//

import UIKit

protocol DMPGridViewDelegate: UITableViewDelegate {

    func gridViewController(gridViewController:DMPGridViewController, titleForCellAtIndex index:Int) -> String
    func numberOfCellsForGridViewController(gridViewController:DMPGridViewController) -> Int
    func gridViewController(gridViewController:DMPGridViewController, tappedCellAtIndex index:Int)

    optional func gridViewController(gridViewController:DMPGridViewController, imageURLForCellAtIndex index:Int) -> NSURL?
    optional func gridViewController(gridViewController:DMPGridViewController, imageForCellAtIndex index:Int) -> UIImage
}
