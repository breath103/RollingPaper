#import <UIKit/UIKit.h>
#import "PaperCellController.h"
@interface RollingPaperListController : UIViewController<PaperCellDelegate>
{
    @private
    NSMutableArray* paperCellControllers;
}
@property (weak, nonatomic) IBOutlet UIScrollView *paperScrollView;
@property (weak, nonatomic) IBOutlet UIButton *profileButton;
- (IBAction)onTouchAddPaper:(id)sender;
- (IBAction)onTouchRefresh:(id)sender;
- (IBAction)onTouchProfile:(id)sender;
- (void) refreshPaperList;
+ (RollingPaperListController*) getInstance;
@end
