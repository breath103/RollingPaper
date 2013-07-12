#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>
#import <AFNetworking/AFNetworking.h>

#define SERVER_IP   (@"www.fbdiary.net:8001")
#define SERVER_HOST ([@"http://" stringByAppendingString:SERVER_IP])

@class RollingPaper;
@class ImageContent;
@class SoundContent;
@class User;

@interface FlowithAgent : AFHTTPClient

+(FlowithAgent*) sharedAgent;

- (void) setCurrentUser : (User*) user;
- (void) setUserInfo : (NSDictionary*) dict;
- (User *) getCurrentUser;
- (NSDictionary*) getUserInfo;
- (NSNumber*) getUserIdx;

-(void) joinWithFacebook:(id<FBGraphUser>) me
             accessToken:(NSString*) accesstoken
                 success:(void(^)(NSDictionary* response)) success
                 failure:(void(^)(NSError* error)) error;


// USER
//-(void) getUserWithFacebookID : (NSString*) facebook_id
//                      success : (void (^)(User* user))success
//                      failure : (void (^)(NSError* error))failure ;
// -CONNECTION USERS
-(void) quitPaper : (RollingPaper*) paper
          success : (void (^)())success
          failure : (void (^)(NSError* error))failure;
// KAKAO
-(void) sendApplicationLinkToKakao;

@end
