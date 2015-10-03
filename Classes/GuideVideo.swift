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
    
    class func guideVideoWithDictionary(dict: [String:AnyObject]) -> GuideVideo? {
        let encodings = dict["encodings"] as! [[String:AnyObject]]
        
        for encoding in encodings {
            // Just grab the first mp4 available.
            if encoding["format"] as! String == "mp4" {
                let guideVideo = GuideVideo()
                guideVideo.videoid = dict["videoid"] as! Int
                guideVideo.filename = dict["filename"] as! String
                guideVideo.url = encoding["url"] as! String
                
                guideVideo.size = CGSizeMake(encoding["width"] as! CGFloat,
                    encoding["height"] as! CGFloat)
                
                return guideVideo
            }
        }
        
        return nil
    }

}