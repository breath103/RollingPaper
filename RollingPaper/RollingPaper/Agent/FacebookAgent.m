#import "FacebookAgent.h"

@implementation FacebookAgent

+ (FacebookAgent *)sharedAgent {
	static FacebookAgent *sharedAgent = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedAgent = [[FacebookAgent alloc]init];
	});
	return sharedAgent;
}
- (NSArray *)permissions{
    return @[@"user_photos",@"publish_stream", @"publish_actions",@"email",
             @"user_likes",@"user_birthday",@"user_education_history",@"user_hometown",
             @"read_stream",@"user_about_me",@"read_friendlists",@"offline_access"];
}
- (void)openSession : (void(^)(FBSession *session, FBSessionState status, NSError *error)) handler{
    [FBSession openActiveSessionWithPermissions:[self permissions]
                                   allowLoginUI:YES
                              completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                  handler(session,status,error);
                              }];
}

@end
