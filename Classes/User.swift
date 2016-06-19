//
//  User.m
//  iFixit
//
//  Created by David Patierno on 5/25/11.
//  Copyright 2011 iFixit. All rights reserved.
//

import Foundation

class User: NSObject {

    var data:[String: AnyObject]!
    var iUserid = 0
    var username:String!
    var iImageid = 0
    var session:String!

    init(dictionary:[String:AnyObject]) {
        
        data = dictionary
        iUserid = dictionary["userid"] as! Int
        username = dictionary["username"] as! String
        
        let image = dictionary["image"]
        iImageid = image is NSNull ? 0 : (image as! [String:AnyObject])["id"] as! Int
        
        session = dictionary["authToken"] as! String
    }

}