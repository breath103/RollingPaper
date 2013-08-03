#import <UIKit/UIKit.h>
#import "NotificationCell.h"

@interface NotificationsViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,NotificationCellDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSArray *items;
@property (nonatomic,assign,getter = isInLoading) BOOL inLoading;
@property (nonatomic,assign) BOOL hasMoreItems;
- (IBAction)onTouchBack:(id)sender;
- (void)loadItems;
@end
