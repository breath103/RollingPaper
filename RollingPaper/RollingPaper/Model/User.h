#import <Foundation/Foundation.h>
#import "FlowithObject.h"
@class RollingPaper;

@interface User : FlowithObject
@property(nonatomic, strong) NSString *birthday;
@property(nonatomic, strong) NSString *email;
@property(nonatomic, strong) NSString *facebook_accesstoken;
@property(nonatomic, strong) NSString *facebook_id;
@property(nonatomic, strong) NSNumber *id;
@property(nonatomic, strong) NSString *username;
@property(nonatomic, strong) NSString *picture;
@end

@interface User (Networking)
+(User *)currentUser;
-(void)getParticipaitingPapers:(void (^)(NSArray *papers)) callback
                       failure:(void (^)(NSError *error)) failure;
-(void)getReceivedPapers:(void (^)(NSArray *papers)) callback
                 failure:(void (^)(NSError *error)) failure;
-(void)getSendedPapers:(void (^)(NSArray *papers)) callback
                failure:(void (^)(NSError *error)) failure;
-(void)getNotifications:(void (^)(NSArray *notifications)) callback
                failure:(void (^)(NSError *error)) failure;
-(void)inviteFriends:(NSArray *)facebook_friends
             toPaper:(RollingPaper *)paper
             success:(void (^)()) callback
             failure:(void (^)(NSError *error)) failure;
-(void)setAPNKey:(NSString *)key
         success:(void (^)()) success
         failure:(void (^)(NSError *error)) failure;
@end
