#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FlowithObject.h"

@interface RollingPaper : FlowithObject
@property (nonatomic, strong) NSNumber *id;
@property (nonatomic, readonly, strong) NSString *createdAt;
@property (nonatomic, readonly, strong) NSString *updatedAt;
@property (nonatomic, strong) NSNumber *creatorId;
@property (nonatomic, strong) NSNumber *width;
@property (nonatomic, strong) NSNumber *height;
@property (nonatomic, strong) NSString *notice;
@property (nonatomic, strong) NSString *background;
@property (nonatomic, strong) NSString *friend_facebook_id;
@property (nonatomic, strong) NSString *receive_time;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSNumber *is_new;
@property (nonatomic, strong) NSString *is_sended;

//connection
@property (nonatomic, strong) NSArray *participants;
@property (nonatomic, strong) NSSet *contents;
@end


@interface RollingPaper (NetworkingHelper)
-(void) getContents:(void (^)(NSArray* imageContents,NSArray* soundContents))success
            failure:(void (^)(NSError *))failure;
- (void)saveToServer:(void(^)()) success
             failure:(void(^)(NSError* error)) failure;
- (NSString*) webViewURL;
- (void)presentFacebookDialog;
@end



