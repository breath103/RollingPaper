#import <UIKit/UIKit.h>

@interface NotificationsViewController : UITableViewController
@property (nonatomic,strong) NSArray *items;
@property (nonatomic,assign,getter = isInLoading) BOOL inLoading;
@property (nonatomic,assign) BOOL hasMoreItems;
- (void)loadItems;
@end
