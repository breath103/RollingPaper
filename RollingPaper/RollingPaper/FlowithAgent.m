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
#import <JSONKit.h>
#import "RollingPaper.h"
#import "ImageContent.h"
#import "SoundContent.h"
#import "UECoreData.h"
#import "Notice.h"

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
    NSMutableDictionary* mutableDict = [dict mutableCopy];
    for( NSString* key in dict.allKeys)
    {
        if([dict objectForKey:key] == [NSNull null]){
            [mutableDict removeObjectForKey:key];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:mutableDict
                                              forKey:@"userinfo"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
-(NSDictionary*) getUserInfo {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"userinfo"];
}
-(NSNumber*) getUserIdx{
    return [[self  getUserInfo] objectForKey:@"idx"];
}
-(UIImage*) getImageFromPictrueURL{
    return [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[[self getUserInfo] objectForKey:@"picture"]]]];
}
-(void) handleRequestFailure : (NSURLRequest *) request
                    response : (NSHTTPURLResponse *)response
                       error : (NSError *) error{
    
}

-(void) getProfileImage : (void(^)(BOOL isCachedResponse,UIImage* image)) success{
    [self getImageFromURL:[[self getUserInfo] objectForKey:@"picture" ]
                  success:success];
}
-(void) getImageFromURL : (NSString*)url
                success : (void(^)(BOOL isCachedResponse,UIImage* image)) success{
    UIImage* image = [[SYCache sharedCache] imageForKey:url];
    if(image)
        success(TRUE,image);
    
    if(url){
        AFImageRequestOperation* imageRequest =
        [AFImageRequestOperation imageRequestOperationWithRequest : ToNSURLRequest([[self getUserInfo] objectForKey:@"picture"])
          imageProcessingBlock : ^UIImage *(UIImage *image) {
              return image ;
        } success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            [[SYCache sharedCache] removeObjectForKey:url];
            [[SYCache sharedCache] setImage:image forKey:url];
            success(FALSE,image);
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            NSLog(@"fail : %@",error);
        }];
        [imageRequest start];
    }
}


-(void) getBackgroundList : (void (^)(BOOL isCaschedResponse, NSArray * backgroundList))callback
                  failure : (void (^)(NSError* error))failure{
    NSArray* backgroundList = [[SYCache sharedCache]objectForKey:@"getBackgroundList"];
    if(backgroundList){
        callback(TRUE,backgroundList);
    }
    
    NSURLRequest *urlRequest =  SubAddressToNSURLRequest(@"/paper_backgroundList.json");
    AFJSONRequestOperation* request = [AFJSONRequestOperation JSONRequestOperationWithRequest:
                                            urlRequest
    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [[SYCache sharedCache] setObject:JSON forKey:@"getBackgroundList"];
        callback(FALSE,[JSON objectForKey:@"backgrounds"]);
    }
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        failure(error);
    }];
    [request start];
}
-(void) getBackground : (NSString*) background
             response : (void(^)(BOOL isCachedResponse,UIImage* image)) callback{
    UIImage* image = [[SYCache sharedCache] imageForKey:background];
    if(image)
        callback(TRUE,image);
    else{
        NSString* requestURL = [NSString stringWithFormat:@"%@/background/%@",SERVER_HOST,background];
        NSURLRequest *urlRequest = ToNSURLRequest(requestURL);
        AFImageRequestOperation* imageRequest = [AFImageRequestOperation imageRequestOperationWithRequest:urlRequest
                                                                                     imageProcessingBlock:^UIImage* (UIImage* originalImage) {
                                                                                         return originalImage;
                                                                                     } success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                                                         [[SYCache sharedCache] setImage:image forKey:background];
                                                                                         callback(FALSE,image);
                                                                                     } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                                                         [self handleRequestFailure:request response:response error:error];
                                                                                     }];
        [imageRequest start];
    }
}

-(void) getParticipaitingPapers : (void (^)(BOOL isCachedResponse,NSArray* paperArray))callback
                        failure : (void (^)(NSError *))failure{
    NSArray* cachedResponse = [[SYCache sharedCache]objectForKey:@"getParticipaitingPapers"];
    if(cachedResponse){
        callback(TRUE,cachedResponse);
    }
    
    /* /user/:id([0-9]+)/getParticipatingPapers.json */
    NSString* url = [NSString stringWithFormat:@"/user/%lld/getParticipatingPapers.json",
                                                self.getUserIdx.longLongValue];
    AFJSONRequestOperation* request =
    [AFJSONRequestOperation JSONRequestOperationWithRequest:SubAddressToNSURLRequest(url) success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSArray* paperArray = JSON;
        [[SYCache sharedCache] removeObjectForKey:@"getParticipaitingPapers"];
        [[SYCache sharedCache] setObject:paperArray forKey:@"getParticipaitingPapers"];
        callback(FALSE,paperArray);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"%@",error);
        failure(error);
    }];
    [request start];
}
-(void) getReceivedPapers : (void (^)(BOOL isCachedResponse,NSArray* paperArray))callback
                  failure : (void (^)(NSError *))failure{
    NSArray* cachedResponse = [[SYCache sharedCache]objectForKey:@"getParticipaitingPapers"];
    if(cachedResponse){
        callback(TRUE,cachedResponse);
    }
    
    /* /user/:id([0-9]+)/getParticipatingPapers.json */
    NSString* url = [NSString stringWithFormat:@"/user/%lld/getParticipatingPapers.json",
                     self.getUserIdx.longLongValue];
    AFJSONRequestOperation* request =
    [AFJSONRequestOperation JSONRequestOperationWithRequest:SubAddressToNSURLRequest(url) success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSArray* paperArray = JSON;
        [[SYCache sharedCache] removeObjectForKey:@"getParticipaitingPapers"];
        [[SYCache sharedCache] setObject:paperArray forKey:@"getParticipaitingPapers"];
        callback(FALSE,paperArray);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"%@",error);
        failure(error);
    }];
    [request start];
}
-(void) getSendedPapers : (void (^)(BOOL isCachedResponse,NSArray* paperArray))callback
                failure : (void (^)(NSError *))failure{
    NSArray* cachedResponse = [[SYCache sharedCache]objectForKey:@"getParticipaitingPapers"];
    if(cachedResponse){
        callback(TRUE,cachedResponse);
    }
    
    /* /user/:id([0-9]+)/getParticipatingPapers.json */
    NSString* url = [NSString stringWithFormat:@"/user/%lld/getParticipatingPapers.json",
                     self.getUserIdx.longLongValue];
    AFJSONRequestOperation* request =
    [AFJSONRequestOperation JSONRequestOperationWithRequest:SubAddressToNSURLRequest(url) success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSArray* paperArray = JSON;
        [[SYCache sharedCache] removeObjectForKey:@"getParticipaitingPapers"];
        [[SYCache sharedCache] setObject:paperArray forKey:@"getParticipaitingPapers"];
        callback(FALSE,paperArray);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"%@",error);
        failure(error);
    }];
    [request start];
}



-(void) createPaper : (RollingPaper*) paper
            success : (void (^)(RollingPaper* paper))success
            failure : (void (^)(NSError* error))failure{
    NSURL *url = [NSURL URLWithString:SERVER_HOST];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    // new version of creating paper
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                        self.getUserIdx,@"creator_idx" ,
                                        paper.title,@"title",
                                        paper.target_email,@"target_email",
                                        paper.notice,@"notice",
                                        paper.width,@"width"       ,
                                        paper.height, @"height"      ,
                                        paper.receiver_fb_id, @"receiver_fb_id",
                                        paper.receiver_name,@"receiver_name" ,
                                        paper.receive_time,@"receive_time"  ,
                                        paper.receive_tel,@"receive_tel"   ,
                                        paper.background,@"background"    , nil];
    [httpClient postPath:@"/paper.json"
              parameters:params
                 success:^(AFHTTPRequestOperation *operation, NSData* responseObject){
                     NSDictionary* jsonDict = [responseObject objectFromJSONData];
                     if([jsonDict objectForKey:@"success"])
                     {
                         RollingPaper* paper = (RollingPaper*)[[UECoreData sharedInstance] insertNewObject : @"RollingPaper"
                                                                                                  initWith : [jsonDict objectForKey:@"success"]];
                         NSLog(@"%@",jsonDict);
                         NSLog(@"%@",paper);
                         success(paper);
                     }else{
                         failure([NSError errorWithDomain:[jsonDict objectForKey:@"error"] code:666 userInfo:NULL]);
                     }
                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     failure(error);
                 }];
}
-(void) updatePaper : (RollingPaper*) paper
            success : (void (^)(RollingPaper* paper))success
            failure : (void (^)(NSError* error))failure{
    NSURL *url = [NSURL URLWithString:SERVER_HOST];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    [paper valueForKey:NULL];
    // [paper dictionaryWithValuesForKeys: [paper d]];
    // new version of creating paper
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            self.getUserIdx,@"creator_idx" ,
                            paper.title,@"title",
                            paper.target_email,@"target_email",
                            paper.notice,@"notice",
                            paper.width,@"width"       ,
                            paper.height, @"height"      ,
                            paper.receiver_fb_id, @"receiver_fb_id",
                            paper.receiver_name,@"receiver_name" ,
                            paper.receive_time,@"receive_time"  ,
                            paper.receive_tel,@"receive_tel"   ,
                            paper.background,@"background"    , nil];
    [httpClient putPath: [NSString stringWithFormat:@"paper/%lld.json",paper.idx.longLongValue]
              parameters:params
                 success:^(AFHTTPRequestOperation *operation, NSData* responseObject){
                     success(paper);
                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     failure(error);
                 }];
}

-(void) getContentsOfPaper : (RollingPaper*) paper
                 afterTime : (long long) timestamp
                   success : (void (^)(BOOL isCachedResponse,NSArray* imageContents,NSArray* soundContents))success
                   failure : (void (^)(NSError *))failure{
    /*
    NSArray* cachedResponse = [[SYCache sharedCache]objectForKey:@"getParticipaitingPapers"];
    if(cachedResponse){
        callback(TRUE,cachedResponse);
    }
    */
    NSURL *url = [NSURL URLWithString:SERVER_HOST];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            paper.idx,@"paper_idx",
                            [NSNumber numberWithLongLong:timestamp].stringValue, @"after_time",
                            nil];
    [httpClient postPath:@"/paper/contents"
              parameters:params
                 success:^(AFHTTPRequestOperation *operation, NSData* responseObject){
                     NSDictionary* contentsDictionary = [responseObject objectFromJSONData];
                     success(FALSE,[ImageContent contentsWithDictionaryArray:[contentsDictionary objectForKey:@"image"]],
                                    [SoundContent contentsWithDictionaryArray:[contentsDictionary objectForKey:@"sound"]]);
                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     failure(error);
                 }];
}
-(void) getPaperParticipants : (RollingPaper*) paper
                     success : (void (^)(BOOL isCachedResponse,NSArray* participants))success
                     failure : (void (^)(NSError* error))failure{
    //"/paper/:id/participants.json"
    NSString* url = [NSString stringWithFormat:@"/paper/%@/participants.json",
                     paper.idx.stringValue];
    
    NSArray* cachedResponse = [[SYCache sharedCache]objectForKey:url];
    if(cachedResponse){
        success(TRUE,cachedResponse);
    }
    
    AFJSONRequestOperation* request =
    [AFJSONRequestOperation JSONRequestOperationWithRequest:SubAddressToNSURLRequest(url) success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSArray* participantsArray = JSON;
        [[SYCache sharedCache] removeObjectForKey:url];
        [[SYCache sharedCache] setObject:participantsArray forKey:url];
        success(FALSE,participantsArray);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"%@",error);
        failure(error);
    }];
    [request start];
}
-(void) getNoticeList : (void (^)(BOOL isCaschedResponse, NSArray * noticeList))success
              failure : (void (^)(NSError* error))failure{
    NSString* methodName = @"getNoticeList";
    NSArray* noticeList = [[SYCache sharedCache]objectForKey:methodName];
    
    if(noticeList){
        success(TRUE,[Notice entitiesWithDictionaryArray:noticeList]);
    }
    
    NSURLRequest *urlRequest =  SubAddressToNSURLRequest(@"/notice.json");
    AFJSONRequestOperation* request = [AFJSONRequestOperation JSONRequestOperationWithRequest:urlRequest
                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                [[SYCache sharedCache] setObject:JSON forKey:methodName];
                                NSLog(@"%@",JSON);
                                success(FALSE, [Notice entitiesWithDictionaryArray:JSON] );
                            }
                            failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                failure(error);
                            }];
    [request start];
}


@end
