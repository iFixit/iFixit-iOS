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

    class func guideImageWithDictionary(dict: [String:AnyObject]) -> GuideImage {
        let guideImage = GuideImage()
        
        guideImage.iImageid = dict["id"] as! Int
        guideImage.url = dict["original"] as! String
        
        return guideImage
    }
    
    func URLForSize(size:String) -> NSURL? {
        return NSURL(string: "\(url).\(size)")
    }

}
