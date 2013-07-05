#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FlowithObject.h"

@class Content;

@interface RollingPaper : FlowithObject

@property (nonatomic, strong) NSNumber *id;
@property (nonatomic, strong) NSString *createdTime;
@property (nonatomic, strong) NSNumber *creatorId;
@property (nonatomic, strong) NSNumber *width;
@property (nonatomic, strong) NSNumber *height;
@property (nonatomic, strong) NSString *notice;
@property (nonatomic, strong) NSDate   *update_time;
@property (nonatomic, strong) NSString *background;
@property (nonatomic, strong) NSString *friend_facebook_id;
@property (nonatomic, strong) NSString *receive_time;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSNumber *is_new;
@property (nonatomic, strong) NSString *is_sended;
@property (nonatomic, strong) NSNumber *participants_count;
@property (nonatomic, strong) NSSet    *contents;

@end

@interface RollingPaper (CoreDataGeneratedAccessors)
- (void)addContentsObject:(Content *)value;
- (void)removeContentsObject:(Content *)value;
- (void)addContents:(NSSet *)values;
- (void)removeContents:(NSSet *)values;
@end

@interface RollingPaper (NetworkingHelper)
-(void) getContents:(void (^)(NSArray* imageContents,NSArray* soundContents))success
            failure:(void (^)(NSError *))failure;
- (void)saveToServer:(void(^)()) success
             failure:(void(^)(NSError* error)) failure;
- (NSString*) webViewURL;
@end



