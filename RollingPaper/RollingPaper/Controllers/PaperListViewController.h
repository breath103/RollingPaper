#import <UIKit/UIKit.h>
#import "PaperTableViewCell.h"

@class PaperListViewController;

@protocol PaperListViewControllerDelegate <NSObject>
- (void)paperListViewController:(PaperListViewController *)controller
                 settingTouched:(RollingPaper *)paper;
- (void)paperListViewController:(PaperListViewController *)controller
               backgroundToched:(RollingPaper *)paper;
@end

@interface PaperListViewController : UITableViewController<PaperTableViewCellDelegate>
@property (nonatomic, weak) id<PaperListViewControllerDelegate> delegate;
@property (nonatomic, strong) NSArray *papers;
@end
