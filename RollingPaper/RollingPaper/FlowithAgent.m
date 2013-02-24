#import "FlowithAgent.h"
#import <SYCache.h>
#import <AFNetworking.h>
#import <JSONKit.h>
#import "RollingPaper.h"
#import "ImageContent.h"
#import "SoundContent.h"
#import "UECoreData.h"
#import "Notice.h"
#import <FacebookSDK/FacebookSDK.h>
#import "KakaoLinkCenter.h"
#import "User.h"

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


-(void) setCurrentUser : (User*) user{
    [self setUserInfo:[user toDictionary]];
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


-(void) joinWithUser : (User*) user
            password : (NSString*) password
             success : (void(^)(User* user)) success
             failure : (void(^)(NSError* error)) failure{
    NSURL *url = [NSURL URLWithString:SERVER_HOST];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    NSDictionary *params = @{ @"name"     : user.name ,
                              @"email"    : user.email,
                              @"password" : password,
                              @"pictrue"  : user.picture,
                              @"birthday" : user.birthday,
                              @"phone"    : user.phone };
    [httpClient postPath:@"/user/joinWithFacebook.json"
              parameters:params
                 success:^(AFHTTPRequestOperation *operation, NSData* responseObject){
                     NSDictionary* jsonDict = [responseObject objectFromJSONData];
                     NSString* result = [jsonDict objectForKey:@"result"];
                     NSLog(@"%@",jsonDict);
                     if([result isEqualToString:@"join"]){
                         success( [[User alloc] initWithDict:[jsonDict objectForKey:@"user"]] );
                     }
                     else{
                         failure( [jsonDict objectForKey:@"reason"] );
                     }
                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     failure(error);
                 }];
}

-(void) joinWithFacebook :(id<FBGraphUser>) me
             accessToken : (NSString*) accesstoken
                 success : (void(^)(NSDictionary* response)) success
                 failure : (void(^)(NSError* error)) failure{
    NSURL *url = [NSURL URLWithString:SERVER_HOST];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];

    //생일부분이 mysql에는 yyyy-mm-dd 으로 넣어야 하는데 올때는 mm/dd/yyyy로온다. 이걸 재정렬
    NSString* birthdayString = [me objectForKey:@"birthday"];
    NSArray* dateComponent = [birthdayString componentsSeparatedByString:@"/"];
    birthdayString = [NSString stringWithFormat:@"%@-%@-%@",
                      [dateComponent objectAtIndex:2],
                      [dateComponent objectAtIndex:0],
                      [dateComponent objectAtIndex:1]];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            [me id],@"facebook_id" ,
                            [me objectForKey:@"name"],@"name",
                            [me objectForKey:@"email"],@"email",
                            birthdayString,@"birthday",
                            [[((NSDictionary*)[me objectForKey:@"picture"])objectForKey:@"data"] objectForKey:@"url"],@"picture",
                            accesstoken,@"facebook_accesstoken",
                            nil];
    [httpClient postPath:@"/user/joinWithFacebook.json"
              parameters:params
                 success:^(AFHTTPRequestOperation *operation, NSData* responseObject){
                     
                   
     
                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     failure(error);
                 }];
   
}


-(void) loginWithEmail : (NSString*) email
              password : (NSString*) password
               success : (void(^)(User* user)) success
               failure : (void(^)(NSError* error)) failure{
    NSURL *url = [NSURL URLWithString:SERVER_HOST];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    NSDictionary *params = @{@"email" : email,
                             @"password" : password };
    [httpClient postPath:@"/user/signin.json"
              parameters:params
                 success:^(AFHTTPRequestOperation *operation, NSData* responseObject){
                     NSDictionary* jsonDict = [responseObject objectFromJSONData];
                     NSString* result = [jsonDict objectForKey:@"result"];
                     NSLog(@"%@",jsonDict);
                     if([result isEqualToString:@"signin"]){
                         success( [[User alloc] initWithDict:[jsonDict objectForKey:@"user"]] );
                     }
                     else{
                         failure( [jsonDict objectForKey:@"reason"] );
                     }
                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     failure(error);
                 }];
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
   //         [[SYCache sharedCache] removeObjectForKey:url];
    //        [[SYCache sharedCache] setImage:image forKey:url];
            success(FALSE,image);
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            NSLog(@"fail : %@",error);
        }];
        [imageRequest start];
    }
}


-(void) getBackgroundList : (void (^)(BOOL isCaschedResponse, NSArray * backgroundList))callback
                  failure : (void (^)(NSError* error))failure{
    NSDictionary* cashedResponse = [[SYCache sharedCache]objectForKey:@"getBackgroundList"];
    if(cashedResponse){
        callback(TRUE,[cashedResponse objectForKey:@"backgrounds"]);
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
                        }
                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
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
-(void) getUsersWhoAreMyFacebookFriends : (void (^)(BOOL isCachedResponse,NSArray* users))success
                                failure : (void (^)(NSError* error))failure {
    NSURL *url = [NSURL URLWithString:SERVER_HOST];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    NSURLRequest *request = [httpClient requestWithMethod:@"GET"
                                                     path:[NSString stringWithFormat:@"/user/%lld/getUsersWhoAreMyFacebookFriend.json",self.getUserIdx.longLongValue]
                                               parameters:NULL];
    [[AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                        success(false,[JSON objectForKey:@"friends"]);
                                                     } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                        failure(error);
                                                     }] start];
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
    // new version of creating paper
    
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithDictionary:[paper dictionaryForUpdateRequest]];
    NSLog(@"%@",params);
    [httpClient putPath: [NSString stringWithFormat:@"/paper/%lld.json",paper.idx.longLongValue]
              parameters:params
                 success:^(AFHTTPRequestOperation *operation, NSData* responseObject){
                     NSLog(@"%@",responseObject);
                     success(paper);
                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     failure(error);
                 }];
}

-(void) getContentsOfPaper : (RollingPaper*) paper
                 afterTime : (long long) timestamp
                   success : (void (^)(BOOL isCachedResponse,NSArray* imageContents,NSArray* soundContents))success
                   failure : (void (^)(NSError *))failure{
    NSString* url = [NSString stringWithFormat:@"/paper/%@.json",
                     paper.idx.stringValue];
    NSURLRequest* urlRequest = SubAddressToNSURLRequest(url);
    [[AFJSONRequestOperation JSONRequestOperationWithRequest:urlRequest
    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSDictionary* contentsDictionary = [JSON objectForKey:@"contents"];
        NSLog(@"%@",contentsDictionary);
        success(FALSE,[ImageContent contentsWithDictionaryArray:[contentsDictionary objectForKey:@"image"]],
                [SoundContent contentsWithDictionaryArray:[contentsDictionary objectForKey:@"sound"]]);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        failure(error);
    }] start];
}

-(void) getUserWithFacebookID : (NSString*) facebook_id
                      success : (void (^)(User* user))success
                      failure : (void (^)(NSError* error))failure{
    NSURL *url = [NSURL URLWithString:SERVER_HOST];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    [[AFJSONRequestOperation
     JSONRequestOperationWithRequest:[httpClient requestWithMethod:@"GET"
                                                              path:[NSString stringWithFormat:@"user/findWithFacebookID/%@.json",facebook_id]
                                                        parameters:NULL]
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
         NSDictionary* resultDict = JSON;
         if([resultDict objectForKey:@"user"]){
             success( [[User alloc] initWithDict:[resultDict objectForKey:@"user"]] );
         }else{
             failure( [NSError errorWithDomain:@"There is No User" code:100 userInfo:nil]);
         }
     } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
         failure(error);
     }] start];
}


-(void) getPaperParticipants : (RollingPaper*) paper
                     success : (void (^)(BOOL isCachedResponse,NSArray* participants))success
                     failure : (void (^)(NSError* error))failure{
    NSString* url = [NSString stringWithFormat:@"/paper/%@/participants.json",paper.idx.stringValue];
    
    NSArray* cachedResponse = [[SYCache sharedCache]objectForKey:url];
    if(cachedResponse){
        success(TRUE,[User userWithDictArray:cachedResponse]);
    }
    
    AFJSONRequestOperation* request =
    [AFJSONRequestOperation JSONRequestOperationWithRequest:SubAddressToNSURLRequest(url)
                                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSArray* participantsArray = JSON;
        [[SYCache sharedCache] removeObjectForKey:url];
        [[SYCache sharedCache] setObject:participantsArray forKey:url];
        success(FALSE,[User userWithDictArray:participantsArray]);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"%@",error);
        failure(error);
    }];
    [request start];
}
-(void) inviteUsers : (NSArray*) users
            toPaper : (RollingPaper*) paper{
    NSLog(@"NEED TO IMPLEMENT !!!!!!");
}
-(void) inviteFacebookFreinds : (NSArray*) facebook_friends
                      toPaper : (RollingPaper*) paper
                      success : (void (^)(void))success
                      failure : (void (^)(NSError* error))failure{
    
    NSURL *url = [NSURL URLWithString:SERVER_HOST];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    // new version of creating paper
    NSDictionary *params = @{@"paper_idx":paper.idx,
                             @"user_idx" :[self getUserIdx],
                             @"facebook_friends" : [facebook_friends JSONString]};
    [httpClient postPath:@"/paper/inviteWithFacebookID"
              parameters:params
                 success:^(AFHTTPRequestOperation *operation, NSData* responseObject){
                     NSLog(@"%@",[responseObject objectFromJSONData]);
                     if(responseObject){
                         success();
                     }
                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     failure(error);
                 }];
   
}
-(void) quitPaper : (RollingPaper*) paper
          success : (void (^)())success
          failure : (void (^)(NSError* error))failure{
    NSURL *url = [NSURL URLWithString:SERVER_HOST];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    NSURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST"
                                                                  path:[NSString stringWithFormat:@"/paper/%@.json",paper.idx.stringValue]
                                                            parameters:@{@"user_idx": self.getUserIdx }
                                             constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {}];
    [[AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                         NSString* errorString = [JSON objectForKey:@"error"];
                                                         if(errorString){
                                                             failure( [NSError errorWithDomain:errorString code:0 userInfo:NULL] );
                                                         }
                                                         else{
                                                             success();
                                                         }
                                                     } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                         failure(error);
                                                     }] start];
}



-(void) insertImageContent : (ImageContent*) imageContent
                     image : (NSData*) image
                   success : (void (^)(ImageContent* insertedImageContent))success
                   failure : (void (^)(NSError* error))failure{
    NSURL *url = [NSURL URLWithString:SERVER_HOST];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    NSURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST"
            path:@"/paper/addContent/image"
            parameters:@{@"user_idx" : [self getUserIdx],
                         @"paper_idx" : imageContent.paper_idx,
                         @"x" : imageContent.x,
                         @"y" : imageContent.y,
                         @"width" :imageContent.width,
                         @"height" : imageContent.height,
                         @"rotation" : imageContent.rotation}
            constructingBodyWithBlock: ^(id <AFMultipartFormData> formData) {
                [formData appendPartWithFileData:image
                                            name:@"image"
                                        fileName:@"photo1.png"
                                        mimeType:@"image/png"];
    }];
    [[AFJSONRequestOperation JSONRequestOperationWithRequest:request
      success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
          NSDictionary* insertedImageDict = [JSON objectForKey:@"success"];
          if(insertedImageDict){
              success( [ImageContent contentWithDictionary:insertedImageDict] );
          }
          else{
              failure( [JSON objectForKey:@"error"] );
          }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        failure(error);
    }] start];
}

-(void) insertSoundContent : (SoundContent*) soundContent
                     sound : (NSData*) sound
                   success : (void (^)(SoundContent* insertedSoundContent))success
                   failure : (void (^)(NSError* error))failure{
    NSURL *url = [NSURL URLWithString:SERVER_HOST];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    NSURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST"
                    path:@"/paper/addContent/sound"
                    parameters:@{@"user_idx" : [self getUserIdx],
                                @"paper_idx" : soundContent.paper_idx,
                                @"x" : soundContent.x,
                                @"y" : soundContent.y,
                                @"width" :soundContent.width,
                                @"height" : soundContent.height,
                                @"rotation" : soundContent.rotation}
            constructingBodyWithBlock: ^(id <AFMultipartFormData> formData) {
                [formData appendPartWithFileData:sound
                                            name:@"sound"
                                        fileName:@"sound1.wav"
                                        mimeType:@"audio/wav"];
            }];
    [[AFJSONRequestOperation JSONRequestOperationWithRequest:request
            success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                NSDictionary* insertedSoundContent = [JSON objectForKey:@"success"];
                if(insertedSoundContent){
                    success( [SoundContent contentWithDictionary:insertedSoundContent] );
                }
                else{
                    failure( [JSON objectForKey:@"error"] );
                }
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                failure(error);
            }] start];
}



// 컨텐츠 수정 관련 리퀘스트
-(void) updateImageContent : (ImageContent*) entity
                   success : (void (^)(ImageContent* updatedImageContent))success
                   failure : (void (^)(NSError* error))failure{
    NSURL *url = [NSURL URLWithString:SERVER_HOST];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    [httpClient postPath:@"/paper/editContent/image"
              parameters:@{@"idx"      : entity.idx,
                           @"rotation" : entity.rotation,
                           @"width"    : entity.width,
                           @"height"   : entity.height,
                           @"x"        : entity.x,
                           @"y"        : entity.y,
                           @"image"    : entity.image}
                 success:^(AFHTTPRequestOperation *operation, NSData* responseObject){
                     NSDictionary* results = [responseObject objectFromJSONData];
                     NSDictionary* updatedDict = [results objectForKey:@"success"];
                     NSLog(@"%@",results);
                     ImageContent* updatedContent = [ImageContent contentWithDictionary:updatedDict];
                     NSLog(@"%@",updatedContent);
                     success(updatedContent);
                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     failure(error);
                 }];
}
-(void) updateSoundContent : (SoundContent*) entity
                   success : (void (^)(SoundContent* updatedSoundContent))success
                   failure : (void (^)(NSError* error))failure{
    NSURL *url = [NSURL URLWithString:SERVER_HOST];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    [httpClient postPath:@"/paper/editContent/sound"
              parameters:@{@"idx" : entity.idx,
                           @"rotation": entity.rotation,
                           @"width":entity.width,
                           @"height":entity.height,
                           @"x": entity.x,
                           @"y":entity.y,
                           @"sound":entity.sound}
                 success:^(AFHTTPRequestOperation *operation, NSData* responseObject){
                     NSDictionary* results = [responseObject objectFromJSONData];
                     NSDictionary* updatedDict = [results objectForKey:@"success"];
                     NSLog(@"%@",results);
                     SoundContent* updatedContent = [SoundContent contentWithDictionary:updatedDict];
                     NSLog(@"%@",updatedContent);
                     success(updatedContent);
                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     failure(error);
                 }];
}


-(void) deleteImageContent : (ImageContent*) imageContent
                   success : (void (^)())success
                   failure : (void (^)(NSError* error))failure{
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:SERVER_HOST]];
    [client postPath:@"/paper/deleteContent/image"
          parameters:@{@"user_idx"  : [self getUserIdx],
                       @"image_idx" : imageContent.idx}
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 success();
             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 failure(error);
             }];
}
-(void) deleteSoundContent : (SoundContent*) soundContent
                   success : (void (^)())success
                   failure : (void (^)(NSError* error))failure{
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:SERVER_HOST]];
    [client postPath:@"/paper/deleteContent/sound"
          parameters:@{@"user_idx"  : [self getUserIdx],
                       @"sound_idx" : soundContent.idx}
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 success();
             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 failure(error);
             }];
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

-(void) sendApplicationLinkToKakao{
    if(![KakaoLinkCenter canOpenKakaoLink])
        return;

    
    NSDictionary *metaInfoAndroid = [NSDictionary dictionaryWithObjectsAndKeys:
                                     @"android", @"os",
                                     @"phone", @"devicetype",
                                     @"http://210.122.0.119:8001/demo.html", @"installurl",
                                     @"example://example", @"executeurl",
                                     nil];
    
    NSDictionary *metaInfoIOS = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"ios", @"os",
                                 @"phone", @"devicetype",
                                 @"http://210.122.0.119:8001/demo.html", @"installurl",
                                 @"example://example", @"executeurl",
                                 nil];
    
    [KakaoLinkCenter openKakaoAppLinkWithMessage : @"롤링페이퍼에 초대합니다"
                                             URL : @"http://210.122.0.119:8001/demo.html"
                                     appBundleID : [[NSBundle mainBundle] bundleIdentifier]
                                      appVersion : [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]
                                         appName : [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"]
                                   metaInfoArray : @[metaInfoIOS,metaInfoAndroid]];
}

@end
