#import "User.h"
#import "FlowithAgent.h"
#import "RollingPaper.h"
#import "Notification.h"

@implementation User
- (void)setAttributesWithDictionary:(NSDictionary *)d
{
    _birthday             = [d objectForKey:@"birthday"];
    _email                = [d objectForKey:@"email"];
    _facebook_accesstoken = [d objectForKey:@"facebook_accesstoken"];
    _facebook_id          = [d objectForKey:@"facebook_id"];
    _id                   = [d objectForKey:@"id"];
    _username             = [d objectForKey:@"username"];
    _picture              = [d objectForKey:@"picture"];
}
-(NSDictionary*) toDictionary
{
    return @{@"id"                   : self.id,
             @"username"             : self.username,
             @"email"                : self.email,
             @"picture"              : self.picture,
             @"birthday"             : self.birthday,
             @"picture"              : self.picture,
             @"facebook_id"          : self.facebook_id,
             @"facebook_accesstoken" : self.facebook_accesstoken};
}
@end


@implementation User(Networking)
+ (User *)currentUser
{
    return [[FlowithAgent sharedAgent] getCurrentUser];
}
- (void)setAPNKey:(NSString *)key
          success:(void (^)())success
          failure:(void (^)(NSError *))failure
{
    [[FlowithAgent sharedAgent] postPath:[NSString stringWithFormat:@"users/%d/apn_key.json",_id.integerValue]
    parameters:@{@"apn_key" : key}
    success:^(AFHTTPRequestOperation *operation, NSDictionary *updatedUser) {
        success();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}

-(void) getParticipaitingPapers : (void (^)(NSArray *papers)) callback
                        failure : (void (^)(NSError *error)) failure
{
    [[FlowithAgent sharedAgent] getPath:[NSString stringWithFormat:@"users/%d/participating_papers.json",_id.integerValue]
    parameters:@{}
    success:^(AFHTTPRequestOperation *operation, NSArray *papers) {
        callback([RollingPaper fromArray:papers]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}

-(void) getSendedPapers : (void (^)(NSArray *papers)) callback
                failure : (void (^)(NSError *error)) failure
{
    [[FlowithAgent sharedAgent] getPath:[NSString stringWithFormat:@"users/%d/sended_papers.json",_id.integerValue]
                             parameters:@{}
                                success:^(AFHTTPRequestOperation *operation, NSArray *papers) {
                                    callback([RollingPaper fromArray:papers]);
                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    failure(error);
                                }];
}


- (void)getReceivedPapers:(void (^)(NSArray *papers)) callback
                  failure:(void (^)(NSError *error)) failure
{
    [[FlowithAgent sharedAgent] getPath:[NSString stringWithFormat:@"users/%d/received_papers.json",_id.integerValue]
    parameters:@{}
    success:^(AFHTTPRequestOperation *operation, NSArray *papers) {
        callback([RollingPaper fromArray:papers]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}

- (void)getNotifications:(void (^)(NSArray *notifications)) callback
                 failure:(void (^)(NSError *error)) failure
{
    [[FlowithAgent sharedAgent] getPath:[NSString stringWithFormat:@"users/%d/notifications.json",_id.integerValue]
    parameters:@{}
    success:^(AFHTTPRequestOperation *operation, NSArray *papers) {
        callback([Notification fromArray:papers]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}

- (void)inviteFriends:(NSArray *)facebook_friends
              toPaper:(RollingPaper *)paper
              success:(void (^)())success
              failure:(void (^)(NSError *error))failure
{
    [[FlowithAgent sharedAgent] postPath:[NSString stringWithFormat:@"users/%d/invite_friends.json",[_id integerValue]]
    parameters:@{@"paper_id" : [paper id],
                 @"friends"  : facebook_friends}
    success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}
@end







