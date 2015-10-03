//
//  GuideEmbed.h
//  iFixit
//
//  Created by David Patierno on 11/16/12.
//  Copyright 2012 iFixit. All rights reserved.
//

import Foundation

class GuideEmbed: NSObject {

    var url: String!
    var type: String!
    var size: CGSize = CGSizeMake(0.0, 0.0)

    class func guideEmbedWithDictionary(dict:[String:AnyObject]) -> GuideEmbed {
        let guideEmbed = GuideEmbed()
        
        let url = dict["url"] as! String
        guideEmbed.url = "\(url)&format=json"
        
        guideEmbed.type = dict["type"] as! String

        let width = dict["width"] as! CGFloat
        let height = dict["height"] as! CGFloat
        guideEmbed.size = CGSizeMake(width, height)
        
        return guideEmbed
    }

}
