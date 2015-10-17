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

    var documents:[[String:AnyObject]] = []
    var parts:[[String:AnyObject]] = []
    var tools:[[String:AnyObject]] = []
    var flags = []

    var reqreqs = []
    var steps:[GuideStep] = []

    func repairNullsForDict(dict:[String:AnyObject]) -> [String:AnyObject] {
        
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
    
    init(json:[String:AnyObject]) {
        super.init()
        
        data = repairNullsForDict(json)
        
        iGuideid = json["guideid"] as! Int
        
        // Meta information
        title                 = json["title"] as! String
        category              = json["category"] as! String
        subject               = json["subject"] as! String
        author                = json["username"] as? String ?? (json["author"] as! [String:AnyObject])["username"] as! String
        timeRequired          = json["time_required"] as? String ?? ""
        difficulty            = json["difficulty"] as? String ?? ""
        introduction          = json["introduction_raw"] as? String ?? ""
        summary               = json["summary"] as! String
        introduction_rendered = json["introduction_rendered"] as? String ?? ""
        iModifiedDate         = json["modified_date"] as! Int
        iPrereqModifiedDate   = json["prereq_modified_date"] as! Int
        
        // Main image
        let image	= json["image"] as? [String:AnyObject]
        if (image != nil) {
            self.image = GuideImage(json: image!)
        }
        
        // Steps
        if let steps = json["steps"] as? [[String:AnyObject]] {
            for step in steps {
                self.steps.append(GuideStep(json: step))
            }
        }
        
        // Prereqs
        
        // Parts
        parts = json["parts"] as? [[String:AnyObject]] ?? []
        
        // Tools
        tools = json["tools"] as? [[String:AnyObject]] ?? []
        
        // Documents
        documents = json["documents"] as? [[String:AnyObject]] ?? [[:]]
        
        // Flags
        
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
