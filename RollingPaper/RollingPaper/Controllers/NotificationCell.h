#import <UIKit/UIKit.h>
@class Notification;

@interface NotificationCell : UITableViewCell
@property (nonatomic, strong) Notification *notification;
@property (nonatomic, weak) IBOutlet UIImageView *pictureView;
@property (nonatomic, weak) IBOutlet UILabel *textView;
@end
