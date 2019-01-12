//
//  Video.m
//

#import "Video.h"

@implementation Video

@synthesize title, url;

//                         value = [value stringByReplacingOccurrencesOfString:@"[video|" withString:@""];
//                         value = [value stringByReplacingOccurrencesOfString:@"]" withString:@""];

+(NSArray*) parseForVideos:(NSArray*)videos {

     NSMutableArray* videoList = [NSMutableArray array];
     NSString* possibleTitle = @"";
     NSString* possibleURL = @"";
     BOOL didAdd = false;

     for (id element in videos) {
          
          NSArray* content = [element objectForKey:@"content"];
          
          for (id subElement in content) {
          
               if (didAdd == false) {
                    NSString* value = [subElement objectForKey:@"text"];
                    BOOL isVideoUrl=[value containsString:@"[video|"];
                    if (isVideoUrl) {
                    
                         BOOL isDirectURL=[value containsString:@"[video|http"];
                         if (isDirectURL == true) {
                              value = [value stringByReplacingOccurrencesOfString:@"[video|" withString:@""];
                              value = [value stringByReplacingOccurrencesOfString:@"]" withString:@""];
                              possibleURL = value;
                              NSDictionary *dict = @{ @"title" : possibleTitle, @"url" : possibleURL};
                              [videoList addObject:dict];
                              possibleTitle = @"";
                              possibleURL = @"";
                              didAdd = true;
                         } else {
                              NSDictionary* attrs = [element objectForKey:@"attrs"];
                              if (attrs != NULL) {
                              
                                   NSArray* formats = [attrs objectForKey:@"formats"];
                              
                                   if (formats != NULL && [formats count] > 0) {
                                   
                                        NSDictionary* format = formats[0];
                                        value = [format objectForKey:@"url"];
                                        possibleURL = value;
                                        NSDictionary *dict = @{ @"title" : possibleTitle, @"url" : possibleURL};
                                        [videoList addObject:dict];
                                        possibleTitle = @"";
                                        possibleURL = @"";
                                        didAdd = true;
                                   }
                              }
                         }
                    } else {
                    
                         possibleTitle = value;
                    }
               }
          }
          didAdd = false;
     }
     
     return videoList;
}

- (void) dealloc {
     
    [title release];
    [url release];
    [super dealloc];
}

@end
