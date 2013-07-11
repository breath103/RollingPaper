#import "RollingPaper.h"
#import "Content.h"
#import "FlowithAgent.h"
#import "UECoreData.h"
#import "ImageContent.h"
#import "SoundContent.h"
#import "User.h"
#import "Invitation.h"

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
    _createdAt = d[@"created_at"];
    _updatedAt = d[@"updated_at"];
    
    _participants = [User fromArray:d[@"participants"]];
    _invitations  = [Invitation fromArray:d[@"invitations"]];
}

- (NSDictionary *)toDictionary
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:@{
                                       @"creator_id"         : self.creatorId,
                                       @"title"              : self.title,
                                       @"width"              : self.width,
                                       @"height"             : self.height,
                                       @"notice"             : self.notice,
                                       @"background"         : self.background,
                                       @"friend_facebook_id" : self.friend_facebook_id,
                                       @"receive_time"       : self.receive_time,
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
    [FBWebDialogs presentFeedDialogModallyWithSession:[FBSession activeSession]
    parameters:@{
     @"name" : [self title],
     @"description" : [self notice],
     @"link" : [self webViewURL],
     @"picture" : @"https://photos-2.dropbox.com/t/0/AAD98gDYQvXuR5ilF9SDE_Gx3CdcRs35e6pAPueuGeB1tA/12/38281474/png/1024x768/3/1373061600/0/2/logo3.png/KCRsKl14p0JGsSEWdGh_5lz2zEWkzXqGmZhPnSXv8co",
     @"to" : [self friend_facebook_id]
     }
    handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
        NSLog(@"%@",resultURL);
    }];
}
@end


