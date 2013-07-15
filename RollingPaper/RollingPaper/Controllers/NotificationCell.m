#import "NotificationCell.h"
#import "UIImageView+Vingle.h"
#import "Notification.h"

@implementation NotificationCell
- (void)setNotification:(Notification *)notification
{
    [_pictureView setImageWithURL:[notification picture] withFadeIn:0.1f];
    [_textView setText:[notification text]];
    [_detailButton setHidden:YES];
}
- (IBAction)onTouchDetailButton:(id)sender {
    [[self delegate] notificationCell:self
                    touchDetailButton:sender];
}
@end
