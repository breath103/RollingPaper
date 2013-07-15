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

@end
