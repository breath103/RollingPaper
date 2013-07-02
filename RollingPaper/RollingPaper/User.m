#import "User.h"
#import "FlowithAgent.h"

@implementation User
- (void)setAttributesWithDictionary:(NSDictionary *) d
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
    return @{@"id"       : self.id,
             @"username" : self.username,
             @"email"    : self.email,
             @"picture"  : self.picture,
             @"birthday" : self.birthday,
             @"picture" : self.picture,
             @"facebook_id"           : self.facebook_id,
             @"facebook_accesstoken" : self.facebook_accesstoken};
}
@end


@implementation User(Networking)
-(void) getParticipaitingPapers : (void (^)(NSArray *papers)) callback
                        failure : (void (^)(NSError *error)) failure
{
    [[FlowithAgent sharedAgent] getPath:[NSString stringWithFormat:@"users/%d/participating_papers.json",_id.integerValue]
    parameters:@{}
    success:^(AFHTTPRequestOperation *operation, id responseObject) {
        callback(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}
@end







