//
//  Video.h
//  iFixit
//

@interface Video : NSObject

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *url;

+(NSArray*) parseForVideos:(NSArray*)videos;

@end
