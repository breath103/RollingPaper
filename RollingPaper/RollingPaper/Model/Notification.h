#import "FlowithObject.h"

typedef enum NotificationType{
    NotificationTypeUnknown
} NotificationType;

@interface Notification : FlowithObject
@property (nonatomic,assign) NotificationType type;
@end
