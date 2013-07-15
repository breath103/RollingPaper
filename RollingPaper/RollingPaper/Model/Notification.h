#import "FlowithObject.h"

//typedef enum NotificationType{
//    NotificationTypeInvitationReceived,
//    NotificationTypePaperEditingEnded,
//    NotificationTypePaperNeedsToBeSended,
//    NotificationTypePaperReceived,
//    NotificationTypePaperOpened,
//    NotificationTypePaperCommented,
//    NotificationTypePaperDeleted,
//    NotificationTypeUnknown,
//} NotificationType;

@interface Notification : FlowithObject
@property (nonatomic, strong) NSNumber *id;
@property (nonatomic, strong) NSString *notificationType;
@property (nonatomic, strong) NSNumber *senderId;
@property (nonatomic, strong) NSString *picture;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSNumber *sourceId;
@end
