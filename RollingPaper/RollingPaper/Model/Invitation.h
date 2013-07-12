#import "FlowithObject.h"

@interface Invitation : FlowithObject

@property (nonatomic, strong) NSNumber *id;
@property (nonatomic, strong) NSNumber *senderId;
@property (nonatomic, strong) NSNumber *paperId;
@property (nonatomic, strong) NSString *friendFacebookId;
@property (nonatomic, strong) NSString *receiverName;
@property (nonatomic, strong) NSString *receiverPicture;
@property (nonatomic, readonly, strong) NSString *createdAt;
@property (nonatomic, readonly, strong) NSString *updatedAt;

@end
