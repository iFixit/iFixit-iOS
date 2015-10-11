//
//  GuideBookmarks.m
//  iFixit
//
//  Created by David Patierno on 4/7/11.
//  Copyright 2011 iFixit. All rights reserved.
//

import Foundation
import Alamofire

let GuideBookmarksUpdatedNotification = "GuideBookmarksUpdatedNotification"

class GuideBookmarks: NSObject, SDWebImageManagerDelegate {
    
    static var _sharedBookmarks:GuideBookmarks?
    
    var imagesDownloaded = 0
    var imagesRemaining = 0
    var videosDownloaded = 0
    var videosRemaining = 0
    var documentsDownloaded = 0
    var documentsRemaining = 0

    var guides:[String: AnyObject]!
    var images:[String: [String]]!
    var queue:[String: String]!
    var videos:[String: [String]]!
    var documents:[String: [String]]!
    var guidesFilePath:NSURL!
    var imagesFilePath:NSURL!
    var queueFilePath:NSURL!
    var videosFilePath:NSURL!
    var documentsFilePath:NSURL!
    var currentItem:String?
    var bookmarker:GuideBookmarker?
    var favorites:[[String:AnyObject]]?
    
    class func sharedBookmarks() -> GuideBookmarks? {
        if (_sharedBookmarks == nil && iFixitAPI.sharedInstance.user != nil) {
            _sharedBookmarks = GuideBookmarks()
        }
        return _sharedBookmarks
    }

    class func reset() {
        _sharedBookmarks = nil
    }
    
    func documentDirectoryURL() -> NSURL {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }
    
    override init() {
        let config = Config.currentConfig()
        let uid = iFixitAPI.sharedInstance.user!.iUserid
        
        super.init()
        
        // First get the file paths.
        var filename:String!
        let docDirectory = documentDirectoryURL()
        
        filename = "\(config.host)_\(uid)_bookmarkedGuides.plist"
        self.guidesFilePath = docDirectory.URLByAppendingPathComponent(filename)
        
        filename = "\(config.host)_\(uid)_bookmarkedImages.plist"
        self.imagesFilePath = docDirectory.URLByAppendingPathComponent(filename)
        
        filename = "\(config.host)_\(uid)_bookmarkedQueue.plist"
        self.queueFilePath = docDirectory.URLByAppendingPathComponent(filename)
        
        filename = "\(config.host)_\(uid)_bookmarkedVideos.plist"
        self.videosFilePath = docDirectory.URLByAppendingPathComponent(filename)
        
        filename = "\(config.host)_\(uid)_bookmarkedDocuments.plist"
        self.documentsFilePath = docDirectory.URLByAppendingPathComponent(filename)
        
        // Now load: Guides
        let g = NSDictionary(contentsOfURL:self.guidesFilePath) as? [String:AnyObject] ?? [:]
        
        // We must deserialize our guides first before using them
        self.guides = deserializeGuides(g)
        
        // Images
        self.images = NSDictionary(contentsOfURL:self.imagesFilePath) as? [String:[String]] ?? [:]
        
        // Media
        self.videos = NSDictionary(contentsOfURL:self.videosFilePath) as? [String:[String]] ?? [:]
        
        // Documents
        self.documents = NSDictionary(contentsOfURL:self.documentsFilePath) as? [String:[String]] ?? [:]
        
        // Queue
        self.queue = NSDictionary(contentsOfURL:self.queueFilePath) as? [String:String] ?? [:]
    }

    // Returns a flat list of all cached image paths so
    // SDImageCache can avoid evicting them during its cleanDisk operation.
    func cachedImages() -> [String] {
        // TODO
//        return GuideBookmarks.sharedBookmarks()!.images.values
        return []
    }

    func guideForGuideid(iGuideid:NSNumber) -> Guide? {
        let uid = iFixitAPI.sharedInstance.user?.iUserid
        let key = "\(uid)_\(iGuideid)"

        return guides[key] != nil ? Guide(json:guides[key]! as! [String : AnyObject]) : nil
    }

    func addGuideid(aiGuideid:Int) {
        let uid = iFixitAPI.sharedInstance.user!.iUserid
        let iGuideid = aiGuideid
        // Analytics
        let builder = GAIDictionaryBuilder.createEventWithCategory("Guide", action: "Add", label: "Add to favorites", value: iGuideid)
        GAI.sharedInstance().defaultTracker.send(builder.build() as [NSObject:AnyObject])
        
        queue["\(uid)_\(iGuideid)"] = "add"
        synchronize()
    }

    func addGuideid(iGuideid:NSNumber, forBookmarker theBookmarker:GuideBookmarker) {
        bookmarker = theBookmarker
        
        self.addGuideid(iGuideid as Int)
    }

// Saves (1) the guide json data as a string to disk, along with
// (2) a master list of images/videos in separate files so we never evict them
    func saveGuide(guide:Guide) {
        let uid = iFixitAPI.sharedInstance.user!.iUserid

        // Index bookmarks by userid and guideid to prevent duplicates.
        let key = "\(uid)_\(guide.iGuideid)"
        
        // 1. Save the guide data.
        guides[key] = guide.data
        
        // 2. Save the list of images/videos.
        var guideImages:[String] = []
        var guideVideos:[String] = []
        var guideDocuments:[String] = []
        
        for document in guide.documents {
            let docid = document["documentid"] as! String
            guideDocuments.append("\(uid)_\(guide.iGuideid)_\(docid)")
        }
        
        if (guide.image != nil) {
            let standardURL = guide.image!.URLForSize("standard")!.absoluteString
            // TODO[guideImages addObject:[SDImageCache cacheFilenameForKey:standardURL]];
        }
        
        for step in guide.steps {
            for image in step.images {
                let thumbnailURL = guide.image!.URLForSize("thumbnail")!.absoluteString
                let largeURL = guide.image!.URLForSize("large")!.absoluteString
                // TODO [guideImages addObject:[SDImageCache cacheFilenameForKey:thumbnailURL]];
                // TODO [guideImages addObject:[SDImageCache cacheFilenameForKey:largeURL]];
            }
            
            if step.video != nil {
                guideVideos.append("\(uid)_\(step.stepid)_\(step.video.videoid)_\(step.video.filename)")
            }
        }
        
        images[key] = guideImages
        
        if (guideVideos.count != 0) {
            videos[key] = guideVideos
        }
        
        if (guideDocuments.count != 0) {
            documents[key] = guideDocuments
        }
        
        // Write to disk.
        saveBookmarks()
    }

    func removeGuideid(aiGuideid:Int) {
        let uid = iFixitAPI.sharedInstance.user!.iUserid
        let iGuideid = aiGuideid
        // Analytics
        let builder = GAIDictionaryBuilder.createEventWithCategory("Guide", action: "Remove", label: "Remove from favorites", value: iGuideid)
        GAI.sharedInstance().defaultTracker.send(builder.build() as [NSObject:AnyObject])
        
        let key = "\(uid)_\(iGuideid)"
        
        guides[key] = nil
        images[key] = nil
        
        // Remove videos stored on disk
        removeOfflineVideos(videos[key]!)
        videos[key] = nil
        
        // Remove documents stored on disk
        removeOfflineDocuments(documents[key]!)
        documents[key] = nil
        
        saveBookmarks()
    }

    func removeOfflineVideos(videos:[String]) {
        let fileManager = NSFileManager.defaultManager()
        let videosDirectory = documentDirectoryURL().URLByAppendingPathComponent("Videos")
        
        for video in videos {
            let filePath = videosDirectory.URLByAppendingPathComponent(video)
            do {
                try fileManager.removeItemAtURL(filePath)
            } catch {
                
            }
        }
    }

    func removeOfflineDocuments(guideDocuments:[String]) {
        let fileManager = NSFileManager.defaultManager()
        let documentsDirectory = documentDirectoryURL().URLByAppendingPathComponent("Documents")
        
        for document in guideDocuments {
            let filePath = documentsDirectory.URLByAppendingPathComponent(document)
            do {
                try fileManager.removeItemAtURL(filePath)
            } catch {
                
            }
        }
    }

    func removeGuide(guide:Guide) {
        let uid = iFixitAPI.sharedInstance.user!.iUserid
        removeGuideid(guide.iGuideid)
        queue["\(uid)_\(guide.iGuideid)"] = "remove"
        synchronize()
    }

    func serializedGuides(guides:[String:AnyObject]) -> [String:String] {
        var serializedGuides:[String:String] = [:]
        
        for key in guides.keys {
            serializedGuides[key] = Utility.serializeDictionary(guides[key] as! [String:AnyObject])!
        }
        
        return serializedGuides;
    }

    func deserializeGuides(guides:[String: AnyObject]) -> [String:AnyObject] {
        var deserializedGuides:[String:AnyObject] = [:]
        
        for key in guides.keys {
            deserializedGuides[key] = guides[key] is String ?
                Utility.deserializeJsonString(guides[key] as! String) : guides[key];
        }
        
        return deserializedGuides;
    }

    func saveBookmarks() {
        // Write to disk
        if guides == nil {
            return
        }
        
        // We must first serialize the JSONData before writing to disk,
        // otherwise it is possible for a write to fail if a dictionary contains
        // NSNull values or non First Class Objects
        // TODO
//        [[self serializeGuides:guides] writeToFile:[self guidesFilePath] atomically:YES];
//        [images writeToFile:[self imagesFilePath] atomically:YES];
//        [queue  writeToFile:[self queueFilePath] atomically:YES];
//        [videos writeToFile:[self videosFilePath] atomically:YES];
//        [documents writeToFile:[self documentsFilePath] atomically:YES];
    }

    func synchronize() {
        let uid = iFixitAPI.sharedInstance.user!.iUserid
        saveBookmarks()
        
        if (queue.count == 0) {
            return
        }

        let f = NSNumberFormatter()
        f.numberStyle = .DecimalStyle
        
        // Loop through all items in the queue.
        for key in queue.keys {
            let chunks = key.characters.split("_").map(String.init)
            let iUserid = f.numberFromString(chunks[0])
            let iGuideid = f.numberFromString(chunks[1])
            
            // Only synchronize for the current user.
            if iUserid != uid {
                continue
            }
            
            // One at a time.
            if (currentItem != nil) {
                continue
            }
            
            // Download a new guide
            if queue[key] == "add" {
                self.currentItem = key;
                //            [[iFixitAPI sharedInstance] getGuide:iGuideid forObject:self withSelector:@selector(gotGuide:)];
                iFixitAPI.sharedInstance.getGuide(iGuideid!, handler: { (aGuide) in
                    self.gotGuide(aGuide)
                })
            }
            // Remove an existing guide
            else {
                self.currentItem = key
                iFixitAPI.sharedInstance.unlike(iGuideid!, handler: { (result) in
                    self.unliked(result!)
                })
            }
            
            /*
             Stop the loop here.
             
             Guide download will continue in the background, and will call 
             [self synchronize] again once all images/videos have completed downloading.
             */
            break
        }
        
    }

    func announceUpdate() {
        NSNotificationCenter.defaultCenter().postNotificationName(GuideBookmarksUpdatedNotification, object:nil)
    }

    func unliked(result:[String:AnyObject]) {
        if (result["statusCode"] as! Int != 204) {
            iFixitAPI.displayConnectionErrorAlert()
            self.currentItem = nil
            self.announceUpdate()
            return
        }
        
        queue[currentItem!] = nil
        self.currentItem = nil
        synchronize()
        
        // Notify listeners.
        announceUpdate()
    }

    func gotGuide(guide:Guide?) {
        if (guide == nil) {
            self.currentItem = nil
            return
        }
        
        // Remove guides that don't exist anymore.
        if guide!.data["message"] as? String == "Guide not found" {
            let f = NSNumberFormatter()
            f.numberStyle = .DecimalStyle
            
            let chunks = currentItem?.characters.split("_").map(String.init)
            let iGuideid = f.numberFromString(chunks![1])
            
            guide!.iGuideid = iGuideid as! Int
            removeGuide(guide!)
            return
        }
        
        // Save the result.
        saveGuide(guide!)
        
        // Count the media items...
        for step in guide!.steps {
            if step.video != nil {
                videosRemaining++
            }
            
            for image in step.images {
                imagesRemaining += 2
            }
        }
        
        // ...and now download them.
        downloadDocumentsForGuide(guide!)
        
        if guide?.image != nil {
            imagesRemaining++
            SDWebImageManager.sharedManager().downloadWithURL(guide!.image?.URLForSize("standard"), delegate: self, retryFailed:true)
        }
        
        for step in guide!.steps {
            if (step.video != nil) {
                downloadGuideVideoForGuideStep(step)
            }
            
            for image in step.images {
                SDWebImageManager.sharedManager().downloadWithURL(guide!.image?.URLForSize("thumbnail"), delegate: self, retryFailed:true)
                SDWebImageManager.sharedManager().downloadWithURL(guide!.image?.URLForSize("large"), delegate: self, retryFailed:true)
            }
        }
    }

    func downloadDocumentsForGuide(guide:Guide) {
        let uid = iFixitAPI.sharedInstance.user!.iUserid
        documentsRemaining = guide.documents.count;
        
        // Create the request
        for document in guide.documents {
            let manager = NSFileManager.defaultManager()
            // Grab the path to the sandboxed directory given to us
            let documentsPath = documentDirectoryURL().URLByAppendingPathComponent("Documents")
            let documentId = document["documentid"] as! String
            // Create the file path
            let filePath = documentsPath.URLByAppendingPathComponent("\(uid)_\(guide.iGuideid)_\(documentId).pdf")

            Alamofire.request(.GET, document["download_url"] as! String).responseData({ (req, resp, result) in
                if result.isSuccess {
                    if let documentData = result.data {
                        do {
                            try manager.createDirectoryAtURL(documentsPath, withIntermediateDirectories: false, attributes: nil)
                            
                            // Write to disk
                            documentData.writeToURL(filePath, atomically:true)
                        } catch {
                            
                        }
                    }
                }
                
                self.documentsDownloaded++
                self.documentsRemaining--
                
                self.updateProgessBar()
                self.checkIfFinishedDownloading()
            })
            
        }
    }

    func downloadGuideVideoForGuideStep(step:GuideStep) {
        let uid = iFixitAPI.sharedInstance.user!.iUserid
        let manager = NSFileManager.defaultManager()
        // Grab the path to the sandboxed directory given to us
        let videosPath = documentDirectoryURL().URLByAppendingPathComponent("Videos")
        // Create the file path
        let filePath = videosPath.URLByAppendingPathComponent(
            "\(uid)_\(step.stepid)_\(step.video.videoid)_\(step.video.filename)")

        // Create the request
        Alamofire.request(.GET, step.video.url).responseData({ (req, resp, result) in
            if result.isSuccess {
                if let videoData = result.data {
                    do {
                        try manager.createDirectoryAtURL(videosPath, withIntermediateDirectories: false, attributes: nil)
                        
                        // Write to disk
                        videoData.writeToURL(filePath, atomically:true)
                    } catch {
                        
                    }
                }
            }
            
            self.videosDownloaded++
            self.videosRemaining--
            
            self.updateProgessBar()
            self.checkIfFinishedDownloading()
        })
    }
    
    func checkIfFinishedDownloading() {
        if videosRemaining == 0 && imagesRemaining == 0 && documentsRemaining == 0 {
            // Reset counters.
            imagesDownloaded = 0
            videosDownloaded = 0
            documentsDownloaded = 0
            
            bookmarker!.bookmarked()
            self.bookmarker = nil
            
            // Update queue, continue synchronizing.
            queue[currentItem!] = nil
            self.currentItem = nil
            synchronize()
            
            // Notify listeners.
            announceUpdate()
        }
    }

    func webImageManager(imageManager: SDWebImageManager!, didFinishWithImage image: UIImage!) {
        imagesDownloaded++;
        imagesRemaining--;
        
        // Update the progress bar.
        updateProgessBar()
        
        // Done
        checkIfFinishedDownloading()
    }

    func updateProgessBar() {
        let totalDownloaded = imagesDownloaded + videosDownloaded + documentsDownloaded
        let totalRemaining = imagesRemaining + imagesDownloaded + videosRemaining
        bookmarker!.progress!.progress = Float(totalDownloaded) / Float(totalRemaining + videosDownloaded + documentsRemaining + documentsDownloaded);
    }

    func update() {
        //    [[iFixitAPI sharedInstance] getUserFavoritesForObject:self withSelector:@selector(gotUpdates:)];
        iFixitAPI.sharedInstance.getUserFavorites { (likes) in
            
            if likes == nil {
                iFixitAPI.displayConnectionErrorAlert()
                return
            }
            
            // TODO
//            if (([likes isKindOfClass:[NSDictionary class]] && likes["error"])) {
//                // Notify listeners of a potential logout.
//                self.announceUpdate()
//                return
//            }
            
            var guideids:[Int] = []
            self.favorites = likes
            
            // Add new guides.
            for like in likes! {
                let jsonGuide = like["guide"] as! [String:AnyObject]
                let iGuideid = jsonGuide["guideid"] as! Int
                
                guideids.append(iGuideid)
                let savedGuide = self.guideForGuideid(iGuideid)
                
                if (savedGuide == nil) {
                    self.addGuideid(iGuideid)
                    // Force both modified dates into integers when comparing, this is to deal with data type inconsistency across
                    // different endpoints. Remove when new version of API is released
                } else if (Guide.getAbsoluteModifiedDateFromGuideDictionary(jsonGuide) != savedGuide!.getAbsoluteModifiedDate()) {
                    self.removeGuideid(iGuideid)
                    self.addGuideid(iGuideid)
                }
            }
            
            // Remove deleted guides.
            for guide in self.guides.values {
                let iGuideid = guide["guideid"] as! Int
                
                if guideids.contains(iGuideid) == false {
                    self.removeGuideid(iGuideid)
                }
            }
            
            // Notify listeners.
            self.announceUpdate()
        }
    }


}
