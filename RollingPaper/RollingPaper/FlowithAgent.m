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
//        sharedAgent = [[FlowithAgent alloc]initWithBaseURL:[NSURL URLWithString:@"http://10.0.1.97:3000/api"]];
//        sharedAgent = [[FlowithAgent alloc]initWithBaseURL:[NSURL URLWithString:@"http://172.30.1.7:3000/api"]];
        sharedAgent = [[FlowithAgent alloc]initWithBaseURL:[NSURL URLWithString:@"http://rollingpaper-production.herokuapp.com/api"]];
//        sharedAgent = [[FlowithAgent alloc]initWithBaseURL:[NSURL URLWithString:@"http://0.0.0.0:3000/api"]];
	});
	return sharedAgent;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [self setDefaultHeader:@"User-Agent"
                         value:[self defaultUserAgentString]];
        [self setDefaultHeader:@"Accept"
                         value:[self defaultAcceptHeader]];
    }
    return self;
}

- (NSString *)defaultUserAgentString
{
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleExecutableKey]
    ? : [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleIdentifierKey];
    
    NSString *version = @"1.0.0";
    NSString *deviceModel = [[UIDevice currentDevice] model];
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    
    return [NSString stringWithFormat:@"%@ iOS/%@ (%@; iOS %@)", appName, version, deviceModel, systemVersion];
}

- (NSString *)defaultAcceptHeader
{
    NSString *apiVersion = @"v1";
    return [NSString stringWithFormat:@"application/vnd.flowith-%@+json",apiVersion];
}



-(void) setCurrentUser : (User*) user{
    [self setUserInfo:[user toDictionary]];
}
-(void) setUserInfo : (NSDictionary*) dict{
    if(dict){
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
    else{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userinfo"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
- (User *)getCurrentUser
{
    return [[User alloc]initWithDictionary:[self getUserInfo]];
}
-(NSDictionary*) getUserInfo {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"userinfo"];
}
-(NSNumber*) getUserIdx{
    return [self getUserInfo][@"id"];
}
-(UIImage*) getImageFromPictrueURL{
    return [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[[self getUserInfo] objectForKey:@"picture"]]]];
}

-(void) handleRequestFailure : (NSURLRequest *) request
                    response : (NSHTTPURLResponse *)response
                       error : (NSError *) error{
    
}


-(void) joinWithFacebook:(id<FBGraphUser>) me
             accessToken:(NSString*) accesstoken
                 success:(void(^)(NSDictionary* response)) success
                 failure:(void(^)(NSError* error)) failure
{
    NSString* birthdayString = [me objectForKey:@"birthday"];
    NSArray* dateComponent = [birthdayString componentsSeparatedByString:@"/"];
    birthdayString = [NSString stringWithFormat:@"%@-%@-%@",
                      [dateComponent objectAtIndex:2],
                      [dateComponent objectAtIndex:0],
                      [dateComponent objectAtIndex:1]];
    [self postPath:@"users/authorize.json"
    parameters:@{
        @"facebook_id":me[@"id"],
        @"facebook_accesstoken":accesstoken,
        @"username":me[@"name"],
        @"email":me[@"email"],
        @"birthday":birthdayString,
        @"picture":me[@"picture"][@"data"][@"url"]
    } success:^(AFHTTPRequestOperation *operation, NSDictionary* userInfo){
        User* user = [[User alloc]initWithDictionary:userInfo];
        [self setCurrentUser:user];
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound];
        success(userInfo);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
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

-(void) getReceivedPapers : (void (^)(BOOL isCachedResponse,NSArray* paperArray))callback
                  failure : (void (^)(NSError *))failure{
    /* /users/:id([0-9]+)/getParticipatingPapers.json */
    NSString* url = [NSString stringWithFormat:@"/user/%d/received_papers.json",[[self getUserIdx] integerValue]];
    
    NSArray* cachedResponse = [[SYCache sharedCache]objectForKey:url];
    if(cachedResponse){
        callback(TRUE,cachedResponse);
    }
    AFJSONRequestOperation* request = [AFJSONRequestOperation JSONRequestOperationWithRequest:SubAddressToNSURLRequest(url)
    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSDictionary* responseDict = JSON;
        NSArray* papers = [responseDict objectForKey:@"papers"];
        if(papers){
            [[SYCache sharedCache] removeObjectForKey:url];
            [[SYCache sharedCache] setObject:papers forKey:url];
            callback(FALSE,papers);
        }
        else{
            failure( [[NSError alloc] initWithDomain:[responseDict objectForKey:@"error"] code:666 userInfo:NULL] );
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"%@",error);
        failure(error);
    }];
    [request start];
}
-(void) getSendedPapers : (void (^)(BOOL isCachedResponse,NSArray* paperArray))callback
                failure : (void (^)(NSError *))failure{
    NSString* url = [NSString stringWithFormat:@"/user/%lld/sended_papers.json",self.getUserIdx.longLongValue];
    
    NSArray* cachedResponse = [[SYCache sharedCache]objectForKey:url];
    if(cachedResponse){
        callback(TRUE,cachedResponse);
    }
    
    /* /user/:id([0-9]+)/getParticipatingPapers.json */
    AFJSONRequestOperation* request =
    [AFJSONRequestOperation JSONRequestOperationWithRequest:SubAddressToNSURLRequest(url)
    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSDictionary* responseDict = JSON;
        NSArray* papers = [responseDict objectForKey:@"papers"];
        if(papers){
            [[SYCache sharedCache] removeObjectForKey:url];
            [[SYCache sharedCache] setObject:papers forKey:url];
            callback(FALSE,papers);
        }
        else{
            failure( [[NSError alloc] initWithDomain:[responseDict objectForKey:@"error"] code:666 userInfo:NULL] );
        }
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

-(void) getPaperParticipants : (RollingPaper*) paper
                     success : (void (^)(BOOL isCachedResponse,NSArray* participants))success
                     failure : (void (^)(NSError* error))failure{
    NSString* url = [NSString stringWithFormat:@"/paper/%@/participants.json",paper.id.stringValue];
    
    NSArray* cachedResponse = [[SYCache sharedCache]objectForKey:url];
    if(cachedResponse){
        success(TRUE,[User fromArray:cachedResponse]);
    }
    
    AFJSONRequestOperation* request =
    [AFJSONRequestOperation JSONRequestOperationWithRequest:SubAddressToNSURLRequest(url)
                                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSArray* participantsArray = JSON;
        [[SYCache sharedCache] removeObjectForKey:url];
        [[SYCache sharedCache] setObject:participantsArray forKey:url];
        success(FALSE,[User fromArray:participantsArray]);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
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
    NSDictionary *params = @{@"paper_idx":paper.id,
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
                                                                  path:[NSString stringWithFormat:@"/paper/%@.json",paper.id.stringValue]
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


-(void) getNoticeList : (void (^)(BOOL isCaschedResponse, NSArray * noticeList))success
              failure : (void (^)(NSError* error))failure{
    NSString* methodName = @"getNoticeList";
    NSArray* noticeList = [[SYCache sharedCache]objectForKey:methodName];
    
    if(noticeList){
        success(TRUE,[Notice fromArray:noticeList]);
    }
    
    NSURLRequest *urlRequest =  SubAddressToNSURLRequest(@"/notice.json");
    AFJSONRequestOperation* request = [AFJSONRequestOperation JSONRequestOperationWithRequest:urlRequest
                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                [[SYCache sharedCache] setObject:JSON forKey:methodName];
                                success(FALSE, [Notice fromArray:JSON] );
                            }
                            failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                failure(error);
                            }];
    [request start];
}

-(void) sendApplicationLinkToKakao{
    //TODO FIXME
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
