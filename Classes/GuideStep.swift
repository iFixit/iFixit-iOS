//
//  GuideStep.h
//  iFixit
//
//  Created by David Patierno on 8/7/10.
//  Copyright 2010 iFixit. All rights reserved.
//

import Foundation

class GuideStep: NSObject {

    var number = 0
    var stepid = 0
    var title: String!
    var lines:[GuideStepLine] = []
    var images:[GuideImage] = []
    var video: GuideVideo!
    var embed: GuideEmbed!
    
    init(json: [String:AnyObject]) {
        number = json["orderby"] as! Int
        title = json["title"] as! String
        stepid = json["stepid"] as! Int
        
        // Media
        let media = json["media"] as! [String: AnyObject]
        
        // Possible types: image, video, embed
        let type = media["type"] as? String
        
        switch type! {
            
        case "image":
            for image in media["data"] as! [[String:AnyObject]] {
                images.append(GuideImage(json: image))
            }
            
        case "video":
            let video = media["data"] as! [String:AnyObject]
            self.video = GuideVideo(json: video)
            
        case "embed":
            let embed = media["data"] as! [String:AnyObject]
            self.embed = GuideEmbed(json: embed)
            
        default:
            break
        }
        
        // Lines
        for line in json["lines"] as! [[String:AnyObject]] {
            lines.append(GuideStepLine(json: line))
        }
    }

}
