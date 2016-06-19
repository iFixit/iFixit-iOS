//
//  Category.swift
//  iFixit
//
//  Created by Juan J. Collas on 11/12/2015.
//
//

import Foundation

enum Categories: Int {
    case Device = 0
    case Category
    case Guide
}

class Category: NSObject {

    var guideid = 0
    var name: String?
    var type: Categories?
    var displayTitle: String?
    var image: GuideImage?
    var subCategories: [Category] = []
    
    init(json: [String: AnyObject]) {
        super.init()
        
    }
    
}
