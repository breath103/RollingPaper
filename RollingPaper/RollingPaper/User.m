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
//    _name                 = [d objectForKey:@"name"];
    _picture              = [d objectForKey:@"picture"];
}
- (id)initWithDictionary : (NSDictionary*) dict{
    self = [self init];
    if (self) {
        [self setAttributesWithDictionary:dict];
    }
    return self;
}
-(NSDictionary*) toDictionary
{
    return @{@"id" : self.id,
             @"name" : self.name,
             @"email" : self.email,
             @"picture" : self.picture,
             @"birthday" : self.birthday,
             @"facebook_id" : self.facebook_id,
             @"facebook_accesstoken" : self.facebook_accesstoken};
}
+(NSArray*) fromArray:(NSArray *) array
{
    NSMutableArray* users = [[NSMutableArray alloc]initWithCapacity:[array count]];
    for(NSDictionary* dictionary in array){
        [users addObject:[[User alloc] initWithDictionary:dictionary]];
    }
    return users;
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







