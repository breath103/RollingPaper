#import <UIKit/UIKit.h>
#import "PaperCellController.h"
@interface RollingPaperListController : UIViewController<PaperCellDelegate,UIScrollViewDelegate>
{
    NSMutableArray* paperCellControllers;
}
@property (weak, nonatomic) IBOutlet UIScrollView *paperScrollView;
@property (weak, nonatomic) IBOutlet UIButton *profileButton;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
- (IBAction)onTouchAddPaper:(id)sender;
- (IBAction)onTouchRefresh:(id)sender;
- (IBAction)onTouchProfile:(id)sender;
- (void) refreshPaperList;
@end
