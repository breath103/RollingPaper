#import <UIKit/UIKit.h>

@class RollingPaper;

@interface PaperTableViewCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UILabel* ddayLabel;
@property (nonatomic, strong) IBOutlet UILabel* titleLabel;
@property (nonatomic, weak) IBOutlet UIImageView *indicatorForNew;
@property (nonatomic, weak) IBOutlet UIImageView *backgroundImage;
@property (nonatomic, strong) RollingPaper *paper;
@end
