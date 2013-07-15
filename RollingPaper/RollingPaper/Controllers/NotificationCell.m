#import "NotificationCell.h"
#import "UIImageView+Vingle.h"
#import "Notification.h"

@implementation NotificationCell
- (void)setNotification:(Notification *)notification
{
    [_pictureView setImageWithURL:[notification picture] withFadeIn:0.1f];
    [_textView setText:[notification text]];
}
@end
