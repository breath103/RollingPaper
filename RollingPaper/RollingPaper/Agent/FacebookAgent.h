#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>

@interface FacebookAgent : NSObject

+(FacebookAgent*) sharedAgent;
-(NSArray*) permissions;
-(void) openSession : (void(^)(FBSession *session, FBSessionState status, NSError *error)) handler;

@end
