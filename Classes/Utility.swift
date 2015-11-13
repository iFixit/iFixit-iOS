//
//  Utility.m
//  iFixit
//
//  Created by Stefan Ayala on 3/7/14.
//
//

import Foundation

class Utility: NSObject {

    class func serializeDictionary(dictionary:[String:AnyObject]) -> String? {

        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(dictionary, options:.PrettyPrinted)
            return NSString(data:jsonData, encoding:NSUTF8StringEncoding) as? String
        } catch {
            return nil
        }
}

    class func deserializeJsonString(jsonString:NSString) -> [String: AnyObject]? {
        let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding)
        
        do {
            return try NSJSONSerialization.JSONObjectWithData(data!, options:.MutableContainers) as? [String : AnyObject]
        } catch {
            return nil
        }
}

    class func getDeviceLanguage() -> String {
        let language = NSLocale.preferredLanguages().first! as NSString

        return language.substringToIndex(2)
    }

}
