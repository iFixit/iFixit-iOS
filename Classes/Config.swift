//
//  Config.m
//  iFixit
//
//  Created by David Patierno on 2/3/11.
//  Copyright 2011 iFixit. All rights reserved.
//

import Foundation

@objc
enum SiteID: Int {
    case IFixit = 0
    case IFixitDev
    case Make
    case MakeDev
    case Dozuki
    case Zeal
    case Mjtrim
    case Accustream
    case Magnolia
    case Comcast
    case DripAssist
    case Pva
    case Oscaro
}

class Site {
    
    var siteid = 0
    var priority = false
    var hideFromiOS = false
    var name:String?
    var domain:String?
    var custom_domain:String?
    var title:String?
    var theme:String?
    var color:String?
    var `private` = false
    var siteDescription:String?
    var authentication:[String:AnyObject]?
    var answers = false
    var collections = false
    var store:String?
    
    init(json:[String:AnyObject]) {
        
        siteid = json["siteid"] as? Int ?? 0
        priority = json["priority"] as? Bool ?? false
        hideFromiOS = json["hideFromiOS"] as? Bool ?? false
        name = json["name"] as? String
        domain = json["domain"] as? String
        custom_domain = json["custom_domain"] as? String
        title = json["title"] as? String
        theme = json["theme"] as? String
        color = json["color"] as? String
        `private` = json["private"] as? Bool ?? false
        siteDescription = json["description"] as? String
        authentication = json["authentication"] as? [String:AnyObject]
        answers = json["answers"] as? Bool ?? false
        collections = json["collections"] as? Bool ?? false
        store = json["store"] as? String
    }
    
    init(domain:String) {
        self.domain = domain
    }
}

class Config: NSObject {
    
    var site: SiteID = .IFixit
    var dozuki:Bool = false
    var siteData:[String:AnyObject]!
    var custom_domain:String?
    var title:String? = nil
    var concreteBackgroundImage:UIImage!
    var siteInfo:[String:AnyObject]!
    
    class func currentConfig() -> Config {
        struct Static {
            static let instance = Config()
        }
        return Static.instance
    }
    
    var sites:[Site] = []
    var prioritySites:[Site] = []

    private var _answersEnabled:Bool?
    var answersEnabled:Bool {
        get {
            if _answersEnabled != nil {
                return _answersEnabled!
            }
            switch site {
            case .IFixit, .IFixitDev:
                return true
                
            default:
                return false
            }
        }
        set {
            _answersEnabled = newValue
        }
    }
    
    private var _collectionsEnabled:Bool?
    var collectionsEnabled:Bool {
        get {
            if _collectionsEnabled != nil {
                return _collectionsEnabled!
            }
            switch site {
            case .IFixit, .IFixitDev, .Make, .MakeDev:
                return true
            default:
                return false
            }
        }
        set {
            _collectionsEnabled = newValue
        }
    }
    
    private var _private:Bool?
    var `private`:Bool {
        get {
            if _private != nil {
                return _private!
            }
            switch site {
            case .Comcast, .Magnolia:
                return true
            default:
                return false
            }
        }
        set {
            _private = newValue
        }
    }
    
    private var _scanner:Bool?
    var scanner:Bool {
        get {
            if _scanner != nil {
                return _scanner!
            }
            switch site {
            case .Accustream:
                return true
            default:
                return false
            }
        }
        set {
            _scanner = newValue
        }
    }

    private var _store:String?
    var store:String? {
        get {
            if _store != nil {
                return _store!
            }
            
            switch site {
            case .IFixit:
                return "http://www.ifixit.com/Store"
            case .IFixitDev:
                return "http://www.ifixit.com/Parts-Store"
            case .Mjtrim:
                return "http://www.mjtrim.com/"
            case .Accustream:
                return "http://www.accustream.com/waterjet-parts.html"
            default:
                return nil
            }
        }
        set {
            _store = newValue
        }
    }

    private var _sso:String?
    var sso:String? {
        get {
            if _sso != nil {
                return _sso!
            }
            switch site {
            case .Comcast:
                return "http://comcast.dozuki.com"
            default:
                return nil
            }
        }
        set {
            _sso = newValue
        }
    }
    
    private var _host:String?
    var host: String? {
        get {
            if _host != nil {
                return _host!
            }
            
            // SSO sites on a custom domain need access to their own sessionid.
            if (self.sso != nil && self.custom_domain != nil) {
                return self.custom_domain
            }
            
            // Everyone else uses the main .dozuki.com host.
            
            switch site {
            case .IFixit:
                return "www.ifixit.com"
            case .IFixitDev:
                return "www.cominor.com"
            case .Make:
                return "makeprojects.com"
            case .MakeDev:
                return "make.cominor.com"
            case .Zeal:
                return "zealoptics.dozuki.com"
            case .Mjtrim:
                return "mjtrim.dozuki.com"
            case .Accustream:
                return "accustream.dozuki.com"
            case .Magnolia:
                return "magnoliamedical.dozuki.com"
            case .Comcast:
                return "comcast.dozuki.com"
            case .DripAssist:
                return "dripassist.dozuki.com"
            case .Pva:
                return "pva.dozuki.com"
            case .Oscaro:
                return "oscaro.dozuki.com"
            default:
                return nil
            }
        }
        set {
            _host = newValue
        }
    }

    private var _baseURL:NSURL?
    var baseURL:NSURL? {
        get {
            if _baseURL != nil {
                return _baseURL!
            }
            
            var url:String? = nil
            
            switch site {
            case .IFixit:
                url = "http://www.ifixit.com/Guide"
            case .IFixitDev:
                url = "http://www.cominor.com/Guide"
            case .Make:
                url = "http://makeproject.com"
            case .MakeDev:
                url = "http://make.cominor.com"
            case .Zeal:
                url = "http://zealoptics.dozuki.com"
            case .Mjtrim:
                url = "http://mjtrim.dozuki.com"
            case .Accustream:
                url = "http://accustream.dozuki.com"
            case .Magnolia:
                url = "http://magnoliamedical.dozuki.com"
            case .Comcast:
                url = "http://comcast.dozuki.com"
            case .DripAssist:
                url = "http://dripassist.dozuki.com"
            case .Pva:
                url = "http://pva.dozuki.com"
            case .Oscaro:
                url = "http://oscaro.dozuki.com"
            default:
                break
            }
            
            if url != nil {
                return NSURL(string:url!)
            } else {
                return nil
            }
        }
        set {
            _baseURL = newValue
        }
    }
    
    var backgroundColor:UIColor {
        switch site {
        case .IFixit, .IFixitDev:
            return UIColor(red:39/255.0, green:41/255.0, blue:43/255.0, alpha:1)
        case .Make, .MakeDev, .Mjtrim, .Magnolia:
            return UIColor.whiteColor()
        default:
            return UIColor.blackColor()
        }
    }
    
    var textColor:UIColor {
        switch site {
        case .Make, .MakeDev, .Mjtrim, .Magnolia:
            return UIColor.blackColor()
        default:
            return UIColor.whiteColor()
        }
    }
    
    var toolbarColor:UIColor {
        switch site {
        case .Make, .MakeDev:
            return UIColor(red:0.16, green:0.67, blue:0.89, alpha:1.0)
        case .IFixit, .IFixitDev:
            return UIColor(red:10/255.0, green:10/255.0, blue:10/255.0, alpha:1)
        case .Mjtrim:
            return UIColor(red:204/255.0, green:0.0, blue:0.0, alpha:1.0)
        case .Magnolia:
            return UIColor.whiteColor()
        case .DripAssist:
            return UIColor(red:192.0/255.0, green:192.0/255.0, blue:192.0/255.0, alpha:1.0)
        default:
            return UIColor.blackColor()
        }
    }
    
    var buttonColor:UIColor? {
        switch site {
        case .IFixit, .IFixitDev:
            return UIColor(red:0.0, green:113/255.0, blue:206.0/255.0, alpha:1.0)
        case .Mjtrim:
            return UIColor(red:234/255.0, green:166.0/255.0, blue:160.0/255.0, alpha:1.0)
        case .Magnolia:
            return UIColor(red:0.0, green:113/255.0, blue:206.0/255.0, alpha:1.0)
        case .Accustream:
            return UIColor(red:0.0, green:113/255.0, blue:206.0/255.0, alpha:1.0)
        case .DripAssist:
            return UIColor(red:109.0/255.0, green:109.0/255.0, blue:109.0/255.0, alpha:1.0)
        default:
            return UIColor(red:0.0, green:113/255.0, blue:206.0/255.0, alpha:1.0)
        }
    }
    
    var tabBarColor:UIColor? {
        switch site {
        case .Mjtrim:
            return self.toolbarColor
        case .Magnolia:
            return self.buttonColor
        default:
            return UIColor.blackColor()
        }
    }
    
    var introCSS:String? {
        var filename:String?
        
        switch site {
        case .Make, .MakeDev, .Mjtrim, .Magnolia:
            filename = "make_intro"
        case .Accustream:
            filename = "accustream_intro"
        default:
            filename = "ifixit_intro"
        }
        
        let path = NSBundle.mainBundle().pathForResource(filename, ofType: "css")
        do {
            return try String(contentsOfFile: path!)
        } catch {
            return nil
        }
    }
    
    var stepCSS:String? {
        var filename:String?
        
        switch site {
        case .Make, .MakeDev, .Mjtrim, .Magnolia:
            filename = "make_step"
        case .Accustream:
            filename = "accustream_step"
        default:
            filename = "ifixit_step"
        }
        
        let path = NSBundle.mainBundle().pathForResource(filename, ofType: "css")
        do {
            return try String(contentsOfFile: path!)
        } catch {
            return nil
        }
    }
    
    var moreInfoCSS:String? {
        var filename:String?
        let iPad = UIDevice.currentDevice().userInterfaceIdiom == .Pad
        
        switch site {
            
        default:
            filename = iPad ? "category_more_info_ipad" : "category_more_info_iphone"
        }
        
        let path = NSBundle.mainBundle().pathForResource(filename, ofType: "css")
        do {
            return try String(contentsOfFile: path!)
        } catch {
            return nil
        }
    }
    
    override init() {
        site = .IFixit
        dozuki = false
        concreteBackgroundImage = UIImage(named:"concreteBackgroundWhite.png")
    }

}
