//
//  GuideStepLine.h
//  iFixit
//
//  Created by David Patierno on 8/7/10.
//  Copyright 2010 iFixit. All rights reserved.
//

import Foundation

@objc
class GuideStepLine: NSObject {
    
    var lineid: Int = 0
    var level: Int = 0
    var bullet: String!
    var text: String!
    
    init(json:[String:AnyObject]) {
        bullet = json["bullet"] as! String
        level  = json["level"] as! Int
        text   = json["text_rendered"] as! String
    }
    
}
