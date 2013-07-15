#import <UIKit/UIKit.h>
#import "NotificationCell.h"

@interface NotificationsViewController : UITableViewController<NotificationCellDelegate>
@property (nonatomic,strong) NSArray *items;
@property (nonatomic,assign,getter = isInLoading) BOOL inLoading;
@property (nonatomic,assign) BOOL hasMoreItems;
- (void)loadItems;
@end
