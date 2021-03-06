#import <UIKit/UIKit.h>
#import "PaperListViewController.h"

@interface MainPaperViewController : UIViewController<UIScrollViewDelegate,PaperListViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *paperScrollView;
@property (weak, nonatomic) IBOutlet UIButton *profileButton;

@property (nonatomic,strong) NSArray *participatingPapers;
@property (nonatomic,strong) NSArray *receivedPapers;
@property (nonatomic,strong) NSArray *sendedPapers;

@property (weak, nonatomic) IBOutlet UIButton *participatingTabButton;
@property (weak, nonatomic) IBOutlet UIButton *receivedTabButton;
@property (weak, nonatomic) IBOutlet UIButton *sendedTabButton;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *tabButtons;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *buttonUnderlines;

@property (nonatomic,strong) PaperListViewController *participatingPaperList;
@property (nonatomic,strong) PaperListViewController *sendedPaperList;
@property (nonatomic,strong) PaperListViewController *receivedPaperList;

@property (nonatomic, weak) IBOutlet UIImageView *profileImageView;

- (IBAction)onTouchAddPaper:(id)sender;
- (IBAction)onTouchRefresh:(id)sender;
- (IBAction)onTouchProfile:(id)sender;
- (void) refreshPaperList;
- (IBAction)onTouchTabButton:(id)sender;
- (IBAction)onTouchNotificationsButton:(id)sender;

@end
