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

    init(json:[String:AnyObject]) {
        let url = json["url"] as! String
        self.url = "\(url)&format=json"
        
        type = json["type"] as! String

        let width = json["width"] as! CGFloat
        let height = json["height"] as! CGFloat
        size = CGSizeMake(width, height)
    }

}
