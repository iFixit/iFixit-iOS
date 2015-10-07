//
//  GuideVideo.h
//  iFixit
//
//  Created by David Patierno on 11/16/12.
//  Copyright 2012 iFixit. All rights reserved.
//

import Foundation

class GuideVideo: NSObject {

    var videoid = 0
    var url: String!
    var filename: String!
    var size = CGSizeMake(0.0, 0.0)
    
    init?(json: [String:AnyObject]) {
        super.init()

        let encodings = json["encodings"] as! [[String:AnyObject]]
        
        for encoding in encodings {
            // Just grab the first mp4 available.
            if encoding["format"] as! String == "mp4" {
                videoid = json["videoid"] as! Int
                filename = json["filename"] as! String
                url = encoding["url"] as! String
                
                size = CGSizeMake(encoding["width"] as! CGFloat,
                    encoding["height"] as! CGFloat)
                
                return
            }
        }
        
        return nil
    }

}