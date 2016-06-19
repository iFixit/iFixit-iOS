//
//  CategoriesSingleton.m
//  iFixit
//
//  Created by Stefan Ayala on 7/8/13.
//
//

class CategoriesSingleton : NSObject {

    var masterCategoryList: [String: AnyObject] = [:]
    var masterDisplayTitleList: [String: String] = [:]

    class var sharedInstance: CategoriesSingleton {
        struct Static {
            static let instance = CategoriesSingleton()
        }
        return Static.instance
    }

}
