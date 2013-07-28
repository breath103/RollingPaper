#import "RollingPaper.h"
#import "Content.h"
#import "FlowithAgent.h"
#import "UECoreData.h"
#import "ImageContent.h"
#import "SoundContent.h"
#import "User.h"
#import "Invitation.h"
#import <FacebookSDK/FacebookSDK.h>

#define NilToBlank(x) (!x?@"":x)

@implementation RollingPaper
- (void) setAttributesWithDictionary:(NSDictionary *)d
{
    self.id                 = d[@"id"];
    self.creatorId          = d[@"creator_id"];
    self.title              = d[@"title"];
    self.width              = d[@"width"];
    self.height             = d[@"height"];
    self.notice             = d[@"notice"];
    self.background         = d[@"background"];
    self.receive_time       = d[@"receive_time"];
    self.friend_facebook_id = d[@"friend_facebook_id"];
    self.recipient_name     = d[@"recipient_name"];
    self.thumbnail          = d[@"thumbnail"];
    _createdAt = d[@"created_at"];
    _updatedAt = d[@"updated_at"];
    
    _participants = [User fromArray:d[@"participants"]];
    _invitations  = [Invitation fromArray:d[@"invitations"]];
}

- (NSDictionary *)toDictionary
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:@{
                                       @"creator_id"         : NilToBlank(self.creatorId),
                                       @"title"              : NilToBlank(self.title),
                                       @"width"              : NilToBlank(self.width),
                                       @"height"             : NilToBlank(self.height),
                                       @"notice"             : NilToBlank(self.notice),
                                       @"background"         : NilToBlank(self.background),
                                       @"friend_facebook_id" : NilToBlank(self.friend_facebook_id),
                                       @"recipient_name"     : NilToBlank(self.recipient_name),
                                       @"receive_time"       : NilToBlank(self.receive_time),
                                       }];
    if (_id)
        dictionary[@"id"] = _id;
    return dictionary;
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [self init];
    if (self) {
        [self setAttributesWithDictionary:dictionary];
    }
    return self;
}

+ (NSArray *)fromArray:(NSArray *)array
{
    NSMutableArray *result = [[NSMutableArray alloc]initWithCapacity:[array count]];
    for(NSDictionary*dict in array){
        [result addObject:[[RollingPaper alloc]initWithDictionary:dict]];
    }
    return result;
}

- (NSDictionary *) recipientDictionary
{
    NSMutableDictionary *dict = [NSMutableDictionary new];
    if (_recipient_name)
        dict[@"name"] = _recipient_name;
    if (_friend_facebook_id)
        dict[@"id"] = _friend_facebook_id;
    return dict;
}
- (void) setRecipient:(id<FBGraphUser>)recipient
{
    [self setRecipient_name:recipient[@"name"]];
    [self setFriend_facebook_id:recipient[@"id"]];
}

- (NSString *) validate
{
//    if(![_title length] > 0) return @"제목을 입력해주세요";
//    if(![_width integerValue] > 0) return @"너비를 지정해주세요";
//    if(![_height integerValue] > 0) return @"높이를 지정해주세요";
//    if(!_notice) return @"공지사항을 입력해주세요";
//    if(!(_receive_time && _recipient_name && _friend_facebook_id) ) return @"받는사람 정보를 입력해주세요";
    return nil;
}


@end


#define NullToNSNull(x) ( (x)?(x):[NSNull null] )

@implementation RollingPaper(NetworkingHelper)
- (void)getContents:(void (^)(NSArray *images, NSArray *sounds))success failure:(void (^)(NSError *))failure
{
    [[FlowithAgent sharedAgent] getPath:[NSString stringWithFormat:@"papers/%d/contents.json",_id.integerValue]
    parameters:@{}
    success:^(AFHTTPRequestOperation *operation, NSDictionary *contents) {
        success([ImageContent fromArray:contents[@"image"]],
                [SoundContent fromArray:contents[@"sound"]]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}

- (void)getParticipants:(void (^)(NSArray *participants))success
                failure:(void (^)(NSError *error))failure
{
    [[FlowithAgent sharedAgent] getPath:[NSString stringWithFormat:@"papers/%d/participants.json",_id.integerValue]
    parameters:@{}
    success:^(AFHTTPRequestOperation *operation, NSArray *participants) {
        _participants = [User fromArray:participants];
        success(_participants);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}

- (void)getInvitations:(void (^)(NSArray *invitations))success
               failure:(void (^)(NSError *error))failure
{
    [[FlowithAgent sharedAgent] getPath:[NSString stringWithFormat:@"papers/%d/invitations.json",_id.integerValue]
    parameters:@{}
    success:^(AFHTTPRequestOperation *operation, NSArray *invitations) {
        _invitations = [Invitation fromArray:invitations];
        success(_invitations);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}

- (void)reload:(void(^)()) success
       failure:(void(^)(NSError* error)) failure
{
    if ([self id]) {
        [[FlowithAgent sharedAgent] getPath:[NSString stringWithFormat:@"papers/%d.json",[[self id] integerValue]]
        parameters:@{}
        success:^(AFHTTPRequestOperation *operation, NSDictionary* paper){
            [self setAttributesWithDictionary:paper];
            success();
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            failure(error);
        }];
    }
}
- (void)saveToServer:(void(^)()) success
             failure:(void(^)(NSError* error)) failure
{
    if ([self id]) { //UPDATE
        [[FlowithAgent sharedAgent] putPath:[NSString stringWithFormat:@"papers/%d.json",[[self id] integerValue]]
        parameters:[self toDictionary]
        success:^(AFHTTPRequestOperation *operation, NSDictionary* paper){
            [self setAttributesWithDictionary:paper];
            success();
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            failure(error);
        }];
    } else { //POST
        [[FlowithAgent sharedAgent] postPath:@"papers.json"
        parameters:[self toDictionary]
        success:^(AFHTTPRequestOperation *operation, NSDictionary* paper){
            [self setAttributesWithDictionary:paper];
            success();
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            failure(error);
        }];
    }
}
- (NSString*) webViewURL{
    return [NSString stringWithFormat:@"http://rollingpaper-production.herokuapp.com/papers/%lld",self.id.longLongValue ];
}
- (void)presentFacebookDialog
{
    NSDictionary *dict = @{
                           @"name" : [self title],
                           @"description" : [self notice],
                           @"link" : [self webViewURL],
                           @"picture" : @"https://photos-2.dropbox.com/t/0/AAD98gDYQvXuR5ilF9SDE_Gx3CdcRs35e6pAPueuGeB1tA/12/38281474/png/1024x768/3/1373061600/0/2/logo3.png/KCRsKl14p0JGsSEWdGh_5lz2zEWkzXqGmZhPnSXv8co",
                           @"to" : [self friend_facebook_id]
                           };
    NSLog(@"%@",dict);
    [FBWebDialogs presentFeedDialogModallyWithSession:[FBSession activeSession]
    parameters:dict
    handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
        NSLog(@"%@",resultURL);
    }];
}
@end


