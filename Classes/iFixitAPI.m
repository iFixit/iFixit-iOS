//
//  iFixitAPI.m
//  iFixit
//
//  Created by David Patierno on 8/6/10.
//  Copyright 2010 iFixit. All rights reserved.
//

#import "iFixitAPI.h"
#import "iFixitAppDelegate.h"
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
	
	BGNetRequest *bgnr = [BGNetRequest initWithUrl:url];
	[bgnr pushHandler:[MTHandler initForObject:object withSelector:selector]];
    [bgnr pushHandler:[MTHandler initForObject:self withSelector:@selector(gotSites:)]];
	[self performSelectorInBackground:@selector(get:) withObject:bgnr];
}

- (void)gotSites:(BGNetRequest *)bgnr {
	NSArray *sites = [bgnr.data JSONValue];
	
	MTHandler *handler = [bgnr popHandler];
	[handler.object performSelector:handler.selector withObject:sites];	
}

- (void)getGuide:(NSInteger)guideid forObject:(id)object withSelector:(SEL)selector {
	NSString *url =	[NSString stringWithFormat:@"http://%@/api/0.1/guide/%d", [Config host], guideid];	

	BGNetRequest *bgnr = [BGNetRequest initWithUrl:url];
	[bgnr pushHandler:[MTHandler initForObject:object withSelector:selector]];
	[bgnr pushHandler:[MTHandler initForObject:self withSelector:@selector(gotGuide:)]];

	[self performSelectorInBackground:@selector(get:) withObject:bgnr];
}

- (void)gotGuide:(BGNetRequest *)bgnr {
	NSDictionary *data = [bgnr.data JSONValue];
	
	Guide *guide = data ? [Guide guideWithDictionary:data] : nil;

	MTHandler *handler = [bgnr popHandler];
	[handler.object performSelector:handler.selector withObject:guide];
}

- (void)getAreas:(NSString *)parent forObject:(id)object withSelector:(SEL)selector {
	if (!parent)
		parent = @"";
    
    // On iPhone and iPod touch, only show leaf nodes with viewable guides.
    NSString *requireGuides = @"";
    if (![iFixitAppDelegate isIPad])
        requireGuides = @"?requireGuides=yes";
	
	NSString *url =	[NSString stringWithFormat:@"http://%@/api/0.1/areas/%@%@", [Config host], parent, requireGuides];	
	
	BGNetRequest *bgnr = [BGNetRequest initWithUrl:url];
	[bgnr pushHandler:[MTHandler initForObject:object withSelector:selector]];
    [bgnr pushHandler:[MTHandler initForObject:self withSelector:@selector(gotAreas:)]];
	[self performSelectorInBackground:@selector(get:) withObject:bgnr];
}

- (void)gotAreas:(BGNetRequest *)bgnr {
	NSDictionary *areas = [bgnr.data JSONValue];
	
	MTHandler *handler = [bgnr popHandler];
	[handler.object performSelector:handler.selector withObject:areas];	
}

- (void)getDevice:(NSString *)device forObject:(id)object withSelector:(SEL)selector {
    device = [device stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
	NSString *url =	[NSString stringWithFormat:@"http://%@/api/0.1/device/%@", [Config host], device];	
    
	BGNetRequest *bgnr = [BGNetRequest initWithUrl:url];
	[bgnr pushHandler:[MTHandler initForObject:object withSelector:selector]];
    [bgnr pushHandler:[MTHandler initForObject:self withSelector:@selector(gotDevice:)]];
	[self performSelectorInBackground:@selector(get:) withObject:bgnr];
}

- (void)gotDevice:(BGNetRequest *)bgnr {
	NSDictionary *data = [bgnr.data JSONValue];

	MTHandler *handler = [bgnr popHandler];
	[handler.object performSelector:handler.selector withObject:data];	
}

- (void)getGuides:(NSString *)type forObject:(id)object withSelector:(SEL)selector {
	if (!type)
		type = @"featured";
	
	NSString *url =	[NSString stringWithFormat:@"http://%@/api/0.1/guides/%@?limit=9", [Config host], type];	
	
	BGNetRequest *bgnr = [BGNetRequest initWithUrl:url];
	[bgnr pushHandler:[MTHandler initForObject:object withSelector:selector]];
    [bgnr pushHandler:[MTHandler initForObject:self withSelector:@selector(gotGuides:)]];
	[self performSelectorInBackground:@selector(get:) withObject:bgnr];
}

- (void)gotGuides:(BGNetRequest *)bgnr {
	NSArray *guides = [bgnr.data JSONValue];
	
	MTHandler *handler = [bgnr popHandler];
	[handler.object performSelector:handler.selector withObject:guides];	
}

- (void)getSearchResults:(NSString *)search forObject:(id)object withSelector:(SEL)selector {
    search = [search stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    search = [search stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
    search = [search stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
	
    NSString *url =	[NSString stringWithFormat:@"http://%@/api/0.1/search/%@?filter=device&limit=50", [Config host], search];	
	
	BGNetRequest *bgnr = [BGNetRequest initWithUrl:url];
	[bgnr pushHandler:[MTHandler initForObject:object withSelector:selector]];
    [bgnr pushHandler:[MTHandler initForObject:self withSelector:@selector(gotSearchResults:)]];
	[self performSelectorInBackground:@selector(get:) withObject:bgnr];

}

- (void)gotSearchResults:(BGNetRequest *)bgnr {
	NSDictionary *results = [bgnr.data JSONValue];
	
	MTHandler *handler = [bgnr popHandler];
	[handler.object performSelector:handler.selector withObject:results];	
}

- (void)loginWithLogin:(NSString *)login andPassword:(NSString *)password forObject:(id)object withSelector:(SEL)selector {
    [TestFlight passCheckpoint:@"Login"];

    NSString *url =	[NSString stringWithFormat:@"https://%@/api/0.1/login", [Config host]];	

    BGNetRequest *bgnr = [BGNetRequest initWithUrl:url];
	[bgnr pushHandler:[MTHandler initForObject:object withSelector:selector]];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
    request.tag = RequestActionLogin;

    // ONLY USE THIS LINE IN DEV MODE
    [request setValidatesSecureCertificate:NO];
    
    [request setRequestMethod:@"POST"];
    [request setUserInfo:[NSDictionary dictionaryWithObject:bgnr forKey:@"bgnr"]];
    [request setPostValue:login forKey:@"login"];
    [request setPostValue:password forKey:@"password"];
    [request setDelegate:self];
    [request startAsynchronous];
}

- (void)registerWithLogin:(NSString *)login andPassword:(NSString *)password andName:(NSString *)name forObject:(id)object withSelector:(SEL)selector {
    [TestFlight passCheckpoint:@"Register"];

    NSString *url =	[NSString stringWithFormat:@"https://%@/api/0.1/register", [Config host]];	
    
    BGNetRequest *bgnr = [BGNetRequest initWithUrl:url];
	[bgnr pushHandler:[MTHandler initForObject:object withSelector:selector]];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
    request.tag = RequestActionRegister;
    
    // ONLY USE THIS LINE IN DEV MODE
    [request setValidatesSecureCertificate:NO];
    
    [request setRequestMethod:@"POST"];
    [request setUserInfo:[NSDictionary dictionaryWithObject:bgnr forKey:@"bgnr"]];
    [request setPostValue:login forKey:@"login"];
    [request setPostValue:password forKey:@"password"];
    [request setPostValue:name forKey:@"username"];
    [request setDelegate:self];
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
    
    BGNetRequest *bgnr = [BGNetRequest initWithUrl:url];
	[bgnr pushHandler:[MTHandler initForObject:object withSelector:selector]];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
    request.tag = RequestActionGetLikes;
    
    // ONLY USE THIS LINE IN DEV MODE
    [request setValidatesSecureCertificate:NO];
    
    [request setRequestMethod:@"POST"];
    [request setUserInfo:[NSDictionary dictionaryWithObject:bgnr forKey:@"bgnr"]];
    [request setPostValue:user.session forKey:@"sessionid"];
    [request setDelegate:self];
    [request startAsynchronous];
}

- (void)like:(NSNumber *)guideid forObject:(id)object withSelector:(SEL)selector {
    [TestFlight passCheckpoint:@"Like"];

    NSString *url =	[NSString stringWithFormat:@"http://%@/api/0.1/likes/add", [Config host]];	
    
    BGNetRequest *bgnr = [BGNetRequest initWithUrl:url];
	[bgnr pushHandler:[MTHandler initForObject:object withSelector:selector]];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
    request.tag = RequestActionLike;
    
    // ONLY USE THIS LINE IN DEV MODE
    [request setValidatesSecureCertificate:NO];
    
    [request setRequestMethod:@"POST"];
    [request setUserInfo:[NSDictionary dictionaryWithObject:bgnr forKey:@"bgnr"]];
    [request setPostValue:guideid forKey:@"guideid"];
    [request setDelegate:self];
    [request startAsynchronous];
}

- (void)unlike:(NSNumber *)guideid forObject:(id)object withSelector:(SEL)selector {
    [TestFlight passCheckpoint:@"Unlike"];

    NSString *url =	[NSString stringWithFormat:@"http://%@/api/0.1/likes/remove", [Config host]];	
    
    BGNetRequest *bgnr = [BGNetRequest initWithUrl:url];
	[bgnr pushHandler:[MTHandler initForObject:object withSelector:selector]];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
    request.tag = RequestActionLike;
    
    // ONLY USE THIS LINE IN DEV MODE
    [request setValidatesSecureCertificate:NO];
    
    [request setRequestMethod:@"POST"];
    [request setUserInfo:[NSDictionary dictionaryWithObject:bgnr forKey:@"bgnr"]];
    [request setPostValue:guideid forKey:@"guideid"];
    [request setDelegate:self];
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request {	
    NSDictionary *results = [[request responseString] JSONValue];
    
    switch (request.tag) {
        case RequestActionLogin:
        case RequestActionRegister:
            // Save the sessionid here locally.
            if ([results respondsToSelector:@selector(objectForKey:)]) {
                if (![results objectForKey:@"error"]) {
                    self.user = [User userWithDictionary:results];
                    [self saveSession];
                }
            }
            break;
            
        case RequestActionGetLikes:
        case RequestActionLike:
        case RequestActionUnlike:
            // Check for invalid sessionid
            if ([results valueForKey:@"error"] && [[results valueForKey:@"msg"] isEqual:@"Invalid login"]) {
                self.user = nil;
                [self saveSession];
            }
            break;
            
        default:
            break;
    }
    
    BGNetRequest *bgnr = [request.userInfo objectForKey:@"bgnr"];
	MTHandler *handler = [bgnr popHandler];
	[handler.object performSelector:handler.selector withObject:results];
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    NSDictionary *results = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1], @"error", [[request error] localizedDescription], @"msg", nil];
    BGNetRequest *bgnr = [request.userInfo objectForKey:@"bgnr"];
	MTHandler *handler = [bgnr popHandler];
	[handler.object performSelector:handler.selector withObject:results];
}

/**
  * Background handler for HTTP GET requests.
  */
- (void)get:(BGNetRequest *)bgnr {
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	UIApplication* app = [UIApplication sharedApplication];
	app.networkActivityIndicatorVisible = YES;
	openConnections++;
	
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];  
	[request setURL:[NSURL URLWithString:bgnr.url]];
		
    NSError *err = nil;
	NSData *data = [NSURLConnection sendSynchronousRequest:request
												returningResponse:nil
															error:&err];

	[request release];

	MTHandler *handler = [bgnr popHandler];
	bgnr.data = err ? nil : [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
	[handler.object performSelectorOnMainThread:handler.selector withObject:bgnr waitUntilDone:NO];

	if (--openConnections <= 0) {
		openConnections = 0;
		app.networkActivityIndicatorVisible = NO;
	}
	
	[pool drain];
	
}

@end
