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
// BACKGROUND METHOD
-(void) getBackgroundList:(void (^)(BOOL isCaschedResponse, NSArray * backgroundList))callback
                  failure:(void (^)(NSError* error))failure;
/////////////////////

// USER
//-(void) getUserWithFacebookID : (NSString*) facebook_id
//                      success : (void (^)(User* user))success
//                      failure : (void (^)(NSError* error))failure ;
// -CONNECTION USERS
-(void) getUsersWhoAreMyFacebookFriends : (void (^)(BOOL isCachedResponse,NSArray* users))success
                                failure : (void (^)(NSError* error))failure;
-(void) inviteUsers : (NSArray*) users
            toPaper : (RollingPaper*) paper;
-(void) inviteFacebookFreinds : (NSArray*) facebook_friends
                      toPaper : (RollingPaper*) paper
                      success : (void (^)(void))success
                      failure : (void (^)(NSError* error))failure;


// PAPER
-(void) createPaper : (RollingPaper*) paper
            success : (void (^)(RollingPaper* paper))success
            failure : (void (^)(NSError* error))failure;
-(void) updatePaper : (RollingPaper*) paper
            success : (void (^)(RollingPaper* paper))success
            failure : (void (^)(NSError* error))failure;
-(void) getPaperParticipants : (RollingPaper*) paper
                     success : (void (^)(BOOL isCachedResponse,NSArray* participants))success
                     failure : (void (^)(NSError* error))failure;
-(void) quitPaper : (RollingPaper*) paper
          success : (void (^)())success
          failure : (void (^)(NSError* error))failure;

//Contents

-(void) insertSoundContent : (SoundContent*) soundContent
                     sound : (NSData*) sound
                   success : (void (^)(SoundContent* insertedSoundContent))success
                   failure : (void (^)(NSError* error))failure;

-(void) updateSoundContent : (SoundContent*) entity
                   success : (void (^)(SoundContent* updatedSoundContent))success
                   failure : (void (^)(NSError* error))failure;

-(void) deleteSoundContent : (SoundContent*) imageContent
                   success : (void (^)())success
                   failure : (void (^)(NSError* error))failure;

// NOTICE
-(void) getNoticeList : (void (^)(BOOL isCaschedResponse, NSArray * noticeList))success
              failure : (void (^)(NSError* error))failure;


// KAKAO
-(void) sendApplicationLinkToKakao;

@end
