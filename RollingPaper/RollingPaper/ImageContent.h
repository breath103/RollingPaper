#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Content.h"

@interface ImageContent : Content
@property (nonatomic, strong) NSData * imageData;
@property (nonatomic, strong) NSString * image;
@end

@interface ImageContent (Networking)
- (void)saveToServer:(void(^)()) success
             failure:(void(^)(NSError* error)) failure;
- (void)deleteFromServer:(void(^)()) success
                 failure:(void(^)(NSError* error)) failure;
@end
