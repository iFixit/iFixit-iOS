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

    var thumbnail: NSURL {
        get { return self.URLForSize("thumbnail")! }
    }
    
    var medium: NSURL {
        get { return self.URLForSize("medium")! }
    }
    
    var large: NSURL {
        get { return self.URLForSize("large")! }
    }
    
    var huge: NSURL {
        get { return self.URLForSize("huge")! }
    }
    
    var standard: NSURL {
        get { return self.URLForSize("standard")! }
    }

    init(json: [String:AnyObject]) {
        iImageid = json["id"] as! Int
        url = json["original"] as! String
    }
    
    private func URLForSize(size:String) -> NSURL? {
        return NSURL(string: "\(url).\(size)")
    }

}
