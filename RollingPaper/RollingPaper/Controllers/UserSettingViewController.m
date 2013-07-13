#import "UserSettingViewController.h"
#import "FlowithAgent.h"
#import "NoticeTableController.h"

@implementation UserSettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}
-(void) viewDidAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = FALSE;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setUserImageView:nil];
    [super viewDidUnload];
}
- (IBAction)onTouchShowNotice:(id)sender {
    NoticeTableController* noticeTableController = [[NoticeTableController alloc] init];
    [self.navigationController pushViewController:noticeTableController
                                         animated:TRUE];
}

- (IBAction)onTouchFeedbackButton:(id)sender {
//    [TestFlight openFeedbackView];
}

- (IBAction)onTouchLogout:(id)sender {
    [[FlowithAgent sharedAgent] setUserInfo:NULL];
    [self.navigationController popToRootViewControllerAnimated:TRUE];
    
}
@end
