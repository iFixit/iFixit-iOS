//
//  GuideImage.h
//  iFixit
//
//  Created by David Patierno on 8/7/10.
//  Copyright 2010 iFixit. All rights reserved.
//

import Foundation

class GuideImage: NSObject {

    var iImageid = 0
    var url: String!

    init(json: [String:AnyObject]) {
        iImageid = json["id"] as! Int
        url = json["original"] as! String
    }
    
    func URLForSize(size:String) -> NSURL? {
        return NSURL(string: "\(url).\(size)")
    }

}
