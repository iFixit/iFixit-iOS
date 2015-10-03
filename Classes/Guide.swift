//
//  Guide.h
//  iFixit
//
//  Created by David Patierno on 8/6/10.
//  Copyright 2010 iFixit. All rights reserved.
//

import Foundation

class Guide: NSObject {

    var data:[String:AnyObject] = [:]
    var iGuideid = 0
    var title: String!
    var category:String!
    var subject:String!
    var author:String!
    var timeRequired:String!
    var difficulty:String!
    var introduction:String!
    var summary:String!
    var introduction_rendered:String!
    var iModifiedDate = 0
    var iPrereqModifiedDate = 0
    var image:GuideImage? = nil

    var documents = []
    var parts = []
    var tools = []
    var flags = []

    var reqreqs = []
    var steps:[GuideStep] = []

    class func repairNullsForDict(dict:[String:AnyObject]) -> [String:AnyObject] {
        
        var newDict:[String:AnyObject] = [:]
        
        // Remove all nulls so the data can be written to disk.
        for key in dict.keys {
            var value = dict[key]
            if (value is NSNull) {
                value = ""
            }
            newDict[key] = value
        }
        
        return dict
    }
    
    class func guideWithDictionary(dict:[String:AnyObject]) -> Guide {
        let guide = Guide()

        guide.data = repairNullsForDict(dict)
        guide.iGuideid = dict["guideid"] as! Int
        
        // Meta information
        guide.title                 = dict["title"] as! String
        guide.category              = dict["category"] as! String
        guide.subject               = dict["subject"] as! String
        guide.author                = (dict["author"] as! [String:AnyObject])["username"] as! String
        guide.timeRequired          = dict["time_required"] as! String
        guide.difficulty            = dict["difficulty"] as! String
        guide.introduction          = dict["introduction_raw"] as! String
        guide.summary               = dict["summary"] as! String
        guide.introduction_rendered = dict["introduction_rendered"] as! String
        guide.iModifiedDate         = dict["modified_date"] as! Int
        guide.iPrereqModifiedDate   = dict["prereq_modified_date"] as! Int
        
        // Main image
        let image	= dict["image"] as? [String:AnyObject]
        if (image != nil) {
            guide.image = GuideImage.guideImageWithDictionary(image!)
        }
        
        // Steps
        let steps = dict["steps"] as! [[String:AnyObject]]
        for step in steps {
            guide.steps.append(GuideStep.guideStepWithDictionary(step))
        }
        
        // Prereqs
        
        // Parts
        guide.parts = dict["parts"] as! [[String:AnyObject]]
        
        // Tools
        guide.tools = dict["tools"] as! [[String:AnyObject]]
        
        // Documents
        guide.documents = dict["documents"] as! [[String:AnyObject]]
        
        // Flags
        
        return guide
    }
    
    func getAbsoluteModifiedDate() -> Int {
        return max(iModifiedDate, iPrereqModifiedDate)
    }
    
    class func getAbsoluteModifiedDateFromGuideDictionary(guideData:[String:AnyObject]) -> Int {
        return max(guideData["modified_date"] as! Int, guideData["prereq_modified_date"] as! Int)

        // Idiots.
//    return [@[[NSNumber numberWithInteger:[guideData["modified_date"] integerValue]],
//    [NSNumber numberWithInteger:[guideData["prereq_modified_date"] integerValue]]
//    ] valueForKeyPath:"@max.intValue"]
    }

}
