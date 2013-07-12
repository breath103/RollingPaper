#import "SoundContent.h"
#import "FlowithAgent.h"

@implementation SoundContent
- (void)setAttributesWithDictionary:(NSDictionary *)dictionary
{
    [super setAttributesWithDictionary:dictionary];
    _sound = dictionary[@"sound"];
}

- (NSDictionary *)toDictionary
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:[super toDictionary]];
    if (_sound)
        dictionary[@"sound"] = _sound;
    return dictionary;
}
@end



@implementation SoundContent (Networking)
- (NSString *)RestAPIGetPath
{
    return [NSString stringWithFormat:@"sound_contents/%d.json",self.id.integerValue];
}
- (NSString *)RestAPIPostPath
{
    return [NSString stringWithFormat:@"sound_contents.json"];
}
- (NSString *)RestAPIPutPath
{
    return [NSString stringWithFormat:@"sound_contents/%d.json",self.id.integerValue];
}
- (NSString *)RestAPIDeletePath
{
    return [NSString stringWithFormat:@"sound_contents/%d.json",self.id.integerValue];
}
- (void)saveToServer:(void(^)()) success
             failure:(void(^)(NSError *error)) failure
{
    if ([self id]) {
        [[FlowithAgent sharedAgent] putPath:[self RestAPIPutPath]
                                 parameters:[self toDictionary]
                                    success:^(AFHTTPRequestOperation *operation, NSDictionary *contents) {
                                        [self setAttributesWithDictionary:contents];
                                        success();
                                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                        failure(error);
                                    }];
    } else {
        NSURLRequest *request =
        [[FlowithAgent sharedAgent] multipartFormRequestWithMethod:@"POST"
                                                              path:[self RestAPIPostPath]
                                                        parameters:[self toDictionary]
                                         constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                             [formData appendPartWithFileData:[self soundData]
                                                                         name:@"sound"
                                                                     fileName:@"sound1.wav"
                                                                     mimeType:@"audio/wav"];
                                             [self setSoundData:nil];
                                         }];
        [[FlowithAgent sharedAgent] enqueueHTTPRequestOperation:[[FlowithAgent sharedAgent] HTTPRequestOperationWithRequest:request
            success:^(AFHTTPRequestOperation *operation, NSDictionary * imageContent) {
                [self setAttributesWithDictionary:imageContent];
                success();
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                failure(error);
            }]];
    }
}
- (void)deleteFromServer:(void(^)()) success
                 failure:(void(^)(NSError *error)) failure
{
    if ([self id]) {
        [[FlowithAgent sharedAgent] deletePath:[self RestAPIDeletePath]
        parameters:@{}
        success:^(AFHTTPRequestOperation *operation, NSDictionary *contents) {
            success();
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            failure(error);
        }];
    }
}
@end