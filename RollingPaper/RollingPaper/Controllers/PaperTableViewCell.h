#import <UIKit/UIKit.h>
@class RollingPaper;
@class PaperTableViewCell;

@protocol PaperTableViewCellDelegate  <NSObject>
- (void)paperTableViewCell:(PaperTableViewCell *)cell touchBackground:(UIView *)view;
- (void)paperTableViewCell:(PaperTableViewCell *)cell settingTouched:(UIButton *)button;
@end

@interface PaperTableViewCell : UITableViewCell

@property (nonatomic,strong) RollingPaper *paper;
@property (nonatomic,weak) id<PaperTableViewCellDelegate> delegate;
@property (strong,nonatomic) IBOutlet UILabel *ddayLabel;
@property (strong,nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *indicatorForNew;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (nonatomic,strong) NSTimer* ddayUpdatingTimer;

- (IBAction)onSettingTouched:(id)sender;

@end
