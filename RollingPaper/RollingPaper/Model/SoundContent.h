#import <Foundation/Foundation.h>
#import "Content.h"

@interface SoundContent : Content
@property (nonatomic, strong) NSData* soundData;
@property (nonatomic, strong) NSString *sound;
@end


@interface SoundContent (Networking)
- (void)saveToServer:(void(^)()) success
             failure:(void(^)(NSError* error)) failure;
- (void)deleteFromServer:(void(^)()) success
                 failure:(void(^)(NSError* error)) failure;
@end
