//
//  iFixitAPI.m
//  iFixit
//
//  Created by David Patierno on 8/6/10.
//  Copyright 2010 iFixit. All rights reserved.
//

#import "iFixitAPI.h"
#import "iFixitAppDelegate.h"
#import "Guide.h"
#import "JSON.h"
#import "Config.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "User.h"
#import "GuideBookmarks.h"

@implementation iFixitAPI

static int volatile openConnections = 0;

@synthesize user;

- (NSString *)sessionFilePath {
    NSString *filename = [NSString stringWithFormat:@"%@_session.plist",
                          [Config currentConfig].host];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDirectory = [paths objectAtIndex:0];
    return [docDirectory stringByAppendingPathComponent:filename];
}

- (void)saveSession {
    if (user) {
        // Write to disk
        [user.data writeToFile:[self sessionFilePath] atomically:YES];
    }
    else {
        // Clear the session
        [[NSFileManager defaultManager] removeItemAtPath:[self sessionFilePath] error:nil];   
    }
}

- (void)loadSession {
    // Read from disk
    NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:[self sessionFilePath]];
    self.user = data ? [User userWithDictionary:data] : nil;
}

/**
  * Singleton accessor.
  */
+ (iFixitAPI *)sharedInstance {
	static iFixitAPI *sharedInstance;
	
	@synchronized(self) {
		if (!sharedInstance) {
			sharedInstance = [[iFixitAPI alloc] init];
            [sharedInstance loadSession];
        }
		
		return sharedInstance;
	}
	
	return nil;
}

- (void)getSitesWithLimit:(NSUInteger)limit andOffset:(NSUInteger)offset forObject:(id)object withSelector:(SEL)selector {
	NSString *url =	[NSString stringWithFormat:@"http://%@/api/0.1/sites?limit=%d&offset=%d", [Config host], limit, offset];	
	
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
    [request setCompletionBlock:^{
        NSArray *results = [[request responseString] JSONValue];
        [object performSelector:selector withObject:results];
    }];
    [request setFailedBlock:^{
        [object performSelector:selector withObject:nil];
    }];
    [request startAsynchronous];
}

- (void)getGuide:(NSInteger)guideid forObject:(id)object withSelector:(SEL)selector {
	NSString *url =	[NSString stringWithFormat:@"http://%@/api/0.1/guide/%d", [Config host], guideid];	

    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
    [request setCompletionBlock:^{
        NSDictionary *result = [[request responseString] JSONValue];
        Guide *guide = result ? [Guide guideWithDictionary:result] : nil;
        [object performSelector:selector withObject:guide];
    }];
    [request setFailedBlock:^{
        [object performSelector:selector withObject:nil];
    }];
    [request startAsynchronous];
}

- (void)getAreas:(NSString *)parent forObject:(id)object withSelector:(SEL)selector {
	if (!parent)
		parent = @"";
    
    // On iPhone and iPod touch, only show leaf nodes with viewable guides.
    NSString *requireGuides = @"";
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
        requireGuides = @"?requireGuides=yes";
	
	NSString *url =	[NSString stringWithFormat:@"http://%@/api/0.1/areas/%@%@", [Config host], parent, requireGuides];	
	
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
    [request setCompletionBlock:^{
        NSDictionary *results = [[request responseString] JSONValue];
        [object performSelector:selector withObject:results];
    }];
    [request setFailedBlock:^{
        [object performSelector:selector withObject:nil];
    }];
    [request startAsynchronous];
}

- (void)getDevice:(NSString *)device forObject:(id)object withSelector:(SEL)selector {
    device = [device stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
	NSString *url =	[NSString stringWithFormat:@"http://%@/api/0.1/device/%@", [Config host], device];	
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
    [request setCompletionBlock:^{
        NSDictionary *results = [[request responseString] JSONValue];
        [object performSelector:selector withObject:results];
    }];
    [request setFailedBlock:^{
        [object performSelector:selector withObject:nil];
    }];
    [request startAsynchronous];
}

- (void)getGuides:(NSString *)type forObject:(id)object withSelector:(SEL)selector {
    int limit = [type isEqual:@"featured"] ? 9 : 100;
	
	NSString *url =	[NSString stringWithFormat:@"http://%@/api/0.1/guides/%@?limit=%d", [Config host], type, limit];	
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
    [request setCompletionBlock:^{
        NSArray *results = [[request responseString] JSONValue];
        [object performSelector:selector withObject:results];
    }];
    [request setFailedBlock:^{
        [object performSelector:selector withObject:nil];
    }];
    [request startAsynchronous];
}

- (void)getSearchResults:(NSString *)search forObject:(id)object withSelector:(SEL)selector {
    search = [search stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    search = [search stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
    search = [search stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
	
    NSString *url =	[NSString stringWithFormat:@"http://%@/api/0.1/search/%@?filter=device&limit=50", [Config host], search];	
	
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
    [request setCompletionBlock:^{
        NSDictionary *results = [[request responseString] JSONValue];
        [object performSelector:selector withObject:results];
    }];
    [request setFailedBlock:^{
        [object performSelector:selector withObject:nil];
    }];
    [request startAsynchronous];
}

- (void)checkLogin:(NSDictionary *)results {
    if ([results respondsToSelector:@selector(valueForKey:)]) {
        if (![results valueForKey:@"error"]) {
            self.user = [User userWithDictionary:results];
            [self saveSession];
        }
    }
}

- (void)checkSession:(NSDictionary *)results {
    // Check for invalid sessionid
    if ([results valueForKey:@"error"] && [[results valueForKey:@"msg"] isEqual:@"Invalid login"]) {
        self.user = nil;
        [self saveSession];
    }
}

- (void)loginWithLogin:(NSString *)login andPassword:(NSString *)password forObject:(id)object withSelector:(SEL)selector {
    [TestFlight passCheckpoint:@"Login"];

    NSString *url =	[NSString stringWithFormat:@"https://%@/api/0.1/login", [Config host]];	

    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
    [request setRequestMethod:@"POST"];
    [request setPostValue:login forKey:@"login"];
    [request setPostValue:password forKey:@"password"];
    
    [request setCompletionBlock:^{
        NSDictionary *results = [[request responseString] JSONValue];
        [self checkLogin:results];
        [object performSelector:selector withObject:results];
    }];
    [request setFailedBlock:^{
        NSDictionary *results = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], @"error", [[request error] localizedDescription], @"msg", nil];
        [object performSelector:selector withObject:results];
    }];
    
    [request startAsynchronous];
}

- (void)registerWithLogin:(NSString *)login andPassword:(NSString *)password andName:(NSString *)name forObject:(id)object withSelector:(SEL)selector {
    [TestFlight passCheckpoint:@"Register"];

    NSString *url =	[NSString stringWithFormat:@"https://%@/api/0.1/register", [Config host]];	
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];    
    [request setRequestMethod:@"POST"];
    [request setPostValue:login forKey:@"login"];
    [request setPostValue:password forKey:@"password"];
    [request setPostValue:name forKey:@"username"];
    
    [request setCompletionBlock:^{
        NSDictionary *results = [[request responseString] JSONValue];
        [self checkLogin:results];
        [object performSelector:selector withObject:results];
    }];
    [request setFailedBlock:^{
        NSDictionary *results = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], @"error", [[request error] localizedDescription], @"msg", nil];
        [object performSelector:selector withObject:results];
    }];
    
    [request startAsynchronous];
}

- (void)logout {
    self.user = nil;
    [self saveSession];
    // Reset GuideBookmarks static object.
    [GuideBookmarks reset];
}

- (void)getUserLikesForObject:(id)object withSelector:(SEL)selector {
    NSString *url =	[NSString stringWithFormat:@"http://%@/api/0.1/likes", [Config host]];	
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];    
    [request setRequestMethod:@"POST"];
    [request setPostValue:user.session forKey:@"sessionid"];
    
    [request setCompletionBlock:^{
        NSDictionary *results = [[request responseString] JSONValue];
        [self checkSession:results];
        [object performSelector:selector withObject:results];
    }];
    [request setFailedBlock:^{
        NSDictionary *results = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], @"error", [[request error] localizedDescription], @"msg", nil];
        [object performSelector:selector withObject:results];
    }];
    
    [request startAsynchronous];
}

- (void)like:(NSNumber *)guideid forObject:(id)object withSelector:(SEL)selector {
    [TestFlight passCheckpoint:@"Like"];

    NSString *url =	[NSString stringWithFormat:@"http://%@/api/0.1/likes/add", [Config host]];	
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];    
    [request setRequestMethod:@"POST"];
    [request setPostValue:guideid forKey:@"guideid"];
    [request setCompletionBlock:^{
        NSDictionary *results = [[request responseString] JSONValue];
        [self checkSession:results];
        [object performSelector:selector withObject:results];
    }];
    [request setFailedBlock:^{
        NSDictionary *results = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], @"error", [[request error] localizedDescription], @"msg", nil];
        [object performSelector:selector withObject:results];
    }];
    
    [request startAsynchronous];
}

- (void)unlike:(NSNumber *)guideid forObject:(id)object withSelector:(SEL)selector {
    [TestFlight passCheckpoint:@"Unlike"];

    NSString *url =	[NSString stringWithFormat:@"http://%@/api/0.1/likes/remove", [Config host]];	
    
    __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];    
    [request setRequestMethod:@"POST"];
    [request setPostValue:guideid forKey:@"guideid"];
    
    [request setCompletionBlock:^{
        NSDictionary *results = [[request responseString] JSONValue];
        [self checkSession:results];
        [object performSelector:selector withObject:results];
    }];
    [request setFailedBlock:^{
        NSDictionary *results = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], @"error", [[request error] localizedDescription], @"msg", nil];
        [object performSelector:selector withObject:results];
    }];
    
    [request startAsynchronous];
}

@end
