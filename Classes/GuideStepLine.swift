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
    
    class func guideStepLineWithDictionary(dict:[String:AnyObject]) -> GuideStepLine {
        let guideStepLine = GuideStepLine()

        guideStepLine.bullet = dict["bullet"] as! String
        guideStepLine.level  = dict["level"] as! Int
        guideStepLine.text   = dict["text_rendered"] as! String
        return guideStepLine
    }
    
}
