//
//  FlowithAgent.m
//  RollingPaper
//
//  Created by 이상현 on 13. 1. 27..
//  Copyright (c) 2013년 상현 이. All rights reserved.
//

#import "FlowithAgent.h"
#import <SYCache.h>
#import <AFNetworking.h>

#define SubAddressToRequestURL(x) ([SERVER_HOST stringByAppendingString:x])
#define SubAddressToNSURLRequest(x) ToNSURLRequest(SubAddressToRequestURL(x))

@implementation FlowithAgent

+ (FlowithAgent *)sharedAgent {
	static FlowithAgent *sharedAgent = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedAgent = [[FlowithAgent alloc]init];
	});
	return sharedAgent;
    
}

-(void) setUserInfo : (NSDictionary*) dict{
    [[NSUserDefaults standardUserDefaults] setObject:dict
                                              forKey:@"userinfo"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+(NSDictionary*) getUserInfo {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"userinfo"];
}
+(NSNumber*) getUserIdx{
    return [[self  getUserInfo] objectForKey:@"idx"];
}
+(UIImage*) getImageFromPictrueURL{
    return [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[[self getUserInfo] objectForKey:@"picture"]]]];
}
-(void) handleRequestFailure : (NSURLRequest *) request
                    response : (NSHTTPURLResponse *)response
                       error : (NSError *) error{
    
}
-(void) getImageFromURL : (NSString*)url
               useCache : (BOOL)useCache
               response : (void(^)(BOOL isCachedResponse,UIImage* image)) response{
    if(url){
        if(useCache){
            
        }
    }
}

-(void) getBackgroundList : (void (^)(BOOL isCaschedResponse, NSArray * backgroundList))callback{
    NSArray* backgroundList = [[SYCache sharedCache]objectForKey:@"getBackgroundList"];
    if(backgroundList){
        callback(TRUE,backgroundList);
    }
    
    NSURLRequest *urlRequest =  SubAddressToNSURLRequest(@"/paper/backgroundList");
    AFJSONRequestOperation* request = [AFJSONRequestOperation JSONRequestOperationWithRequest:
                                            urlRequest
    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [[SYCache sharedCache] removeObjectForKey:@"getBackgroundList"];
        [[SYCache sharedCache] setObject:JSON forKey:@"getBackgroundList"];
        callback(FALSE,JSON);
    }
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [self handleRequestFailure:request response:response error:error];
        NSLog(@"%@",error);
        NSLog(@"%@",JSON);
    }];
    [request start];
}
@end
