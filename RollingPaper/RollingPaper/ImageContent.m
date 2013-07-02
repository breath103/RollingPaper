#import "ImageContent.h"
#import "FlowithAgent.h"
#import "PaperclipImageUploader.h"

@implementation ImageContent
- (void)setAttributesWithDictionary:(NSDictionary *)dictionary
{
    [super setAttributesWithDictionary:dictionary];
    _image = dictionary[@"image"];
}

- (NSDictionary *)toDictionary
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:[super toDictionary]];
    dictionary[@"image"] = _image;
    return dictionary;
}
@end

@implementation ImageContent (Networking)
- (NSString *)RestAPIGetPath
{
    return [NSString stringWithFormat:@"papers/%d/image_contents/%d",self.paper_id.integerValue,self.id.integerValue];
}
- (NSString *)RestAPIPostPath
{
    return [NSString stringWithFormat:@"papers/%d/image_contents",self.paper_id.integerValue];
}
- (NSString *)RestAPIPutPath
{
    return [NSString stringWithFormat:@"papers/%d/image_contents/%d",self.paper_id.integerValue,self.id.integerValue];
}
- (NSString *)RestAPIDeletePath
{
    return [NSString stringWithFormat:@"papers/%d/image_contents/%d",self.paper_id.integerValue,self.id.integerValue];
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
        NSMutableDictionary *entityDictionary = [NSMutableDictionary dictionaryWithDictionary:[self toDictionary]];
        [entityDictionary removeObjectForKey:@"image"];
//        NSURLRequest *request =
//        [[FlowithAgent sharedAgent] multipartFormRequestWithMethod:@"POST"
//                                                              path:[self RestAPIPostPath]
//                                                        parameters:entityDictionary
//                                         constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//                                             [formData appendPartWithFileData:[self image]
//                                                                         name:@"image"
//                                                                     fileName:@"image1.png"
//                                                                     mimeType:@"image/png"];
//                                         }];
        NSURLRequest *request = [PaperclipImageUploader uploadRequestForImage:[self image]
                                                           ofImageContentType:PaperclipImageTypePng
                                                             withImageQuality:1.0f
                                                    forAttachedAttributeNamed:@"image"
                                                                 onModelNamed:@"image_content"
                                                          withOtherAttributes:entityDictionary
                                                                        toUrl:[NSURL URLWithString:[self RestAPIPostPath]
                                                                                     relativeToURL:[[FlowithAgent sharedAgent] baseURL]]];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]initWithRequest:request];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"%@",responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@",error);
        }];
        [operation start];

        
//        [[FlowithAgent sharedAgent] enqueueHTTPRequestOperation:[[FlowithAgent sharedAgent] HTTPRequestOperationWithRequest:request
//        success:^(AFHTTPRequestOperation *operation, NSDictionary * imageContent) {
//            [self setAttributesWithDictionary:imageContent];
//            success();
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            failure(error);
//        }]];
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