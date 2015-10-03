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
    
    class func guideStepWithDictionary(dict: [String:AnyObject]) -> GuideStep {
        let guideStep = GuideStep()
        
        guideStep.number = dict["orderby"] as! Int
        guideStep.title = dict["title"] as! String
        guideStep.stepid = dict["stepid"] as! Int
        
        // Media
        let media = dict["media"] as! [String: AnyObject]
        
        // Possible types: image, video, embed
        let type = media["type"] as? String
        
        switch type! {
            
        case "image":
            for image in media["data"] as! [[String:AnyObject]] {
                guideStep.images.append(GuideImage.guideImageWithDictionary(image))
            }
            
        case "video":
            let video = media["data"] as! [String:AnyObject]
            guideStep.video = GuideVideo.guideVideoWithDictionary(video)
            
        case "embed":
            let embed = media["data"] as! [String:AnyObject]
            guideStep.embed = GuideEmbed.guideEmbedWithDictionary(embed)
            
        default:
            break
        }
        
        // Lines
        for line in dict["lines"] as! [[String:AnyObject]] {
            guideStep.lines.append(GuideStepLine.guideStepLineWithDictionary(line))
        }
        
        return guideStep
    }

}
