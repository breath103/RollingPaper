#import <UIKit/UIKit.h>
@class Notification;
@class NotificationCell;

@protocol NotificationCellDelegate <NSObject>
- (void)notificationCell:(NotificationCell *)cell
       touchDetailButton:(UIButton *)button;
@end

@interface NotificationCell : UITableViewCell
@property (nonatomic, weak) id<NotificationCellDelegate> delegate;
@property (nonatomic, strong) Notification *notification;
@property (nonatomic, weak) IBOutlet UIImageView *pictureView;
@property (nonatomic, weak) IBOutlet UILabel *textView;
@property (weak, nonatomic) IBOutlet UIButton *detailButton;
- (IBAction)onTouchDetailButton:(id)sender;
@end
