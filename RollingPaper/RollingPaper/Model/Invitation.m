#import "Invitation.h"
#import "FlowithAgent.h"

@implementation Invitation

- (void)setAttributesWithDictionary:(NSDictionary *)dictionary
{
    _id = dictionary[@"id"];
    _senderId = dictionary[@"sender_id"];
    _paperId = dictionary[@"paper_id"];
    _friendFacebookId = dictionary[@"friend_facebook_id"];
    _receiverName = dictionary[@"receiver_name"];
    _receiverPicture = dictionary[@"receiver_picture"];
    _createdAt = dictionary[@"created_at"];
    _updatedAt = dictionary[@"updated_at"];
}

@end

@implementation Invitation (Networking)

- (void)accept:(void(^)()) success
       failure:(void(^)(NSError* error)) failure
{
    [[FlowithAgent sharedAgent] postPath:[NSString stringWithFormat:@"invitations/%d/accept.json",_id.integerValue]
    parameters:@{}
    success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}
- (void)reject:(void(^)()) success
       failure:(void(^)(NSError* error)) failure
{
    [[FlowithAgent sharedAgent] deletePath:[NSString stringWithFormat:@"invitations/%d/reject.json",_id.integerValue]
    parameters:@{}
    success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success();
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}

@end
