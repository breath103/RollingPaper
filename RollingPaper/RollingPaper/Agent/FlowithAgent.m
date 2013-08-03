#import "FlowithAgent.h"
#import <AFNetworking/AFNetworking.h>
#import <JSONKit/JSONKit.h>
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
        sharedAgent = [[FlowithAgent alloc]initWithBaseURL:[NSURL URLWithString:@"http://www.fbdiary.net//api"]];
        sharedAgent = [[FlowithAgent alloc]initWithBaseURL:[NSURL URLWithString:@"http://192.168.1.2:3000/api"]];
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



- (void)setCurrentUser:(User *)user{
    [self setUserInfo:[user toDictionary]];
}
- (void)setUserInfo:(NSDictionary *)dict{
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
        user = [[User alloc]initWithDictionary:[self getUserInfo]];
    }
    else{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userinfo"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        user = nil;
    }
}
static User *user = nil;
- (User *)getCurrentUser
{
    if (!user && [self getUserInfo]){
        [self setUserInfo:[self getUserInfo]];
    }
    return user;
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
