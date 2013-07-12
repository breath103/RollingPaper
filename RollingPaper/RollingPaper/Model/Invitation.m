#import "Invitation.h"

@implementation Invitation

- (void)setAttributesWithDictionary:(NSDictionary *)dictionary
{
    _id = dictionary[@"id"];
    _senderId = dictionary[@"sender_id"];
    _paperId = dictionary[@"paper_id"];
    _friendFacebookId = dictionary[@"friend_facebook_id"];
    _receiverName = dictionary[@"receiver_name"];
    _receiverPicture = dictionary[@"receiver_picture"];
    _createdAt = dictionary[@"created_at"];
    _updatedAt = dictionary[@"updated_at"];
}

@end
