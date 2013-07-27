#import "Notification.h"

@implementation Notification

- (void)setAttributesWithDictionary:(NSDictionary *)dictionary
{
    _id = dictionary[@"id"];
    _notificationType = dictionary[@"notification_type"];
    _senderId = dictionary[@"sender_id"];
    _picture = dictionary[@"picture"];
    _text = dictionary[@"text"];
    _sourceId = dictionary[@"source_id"];
}

+ (Notification *)fromAPNDictionary:(NSDictionary *)dictionary
{
    Notification *notification = [[Notification alloc]init];
    [notification setId:dictionary[@"id"]];
    [notification setNotificationType:dictionary[@"type"]];
    [notification setSourceId:dictionary[@"source_id"]];
    return notification;
}

@end
