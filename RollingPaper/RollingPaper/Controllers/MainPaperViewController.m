#import "MainPaperViewController.h"
#import "FlowithAgent.h"
#import "RollingPaper.h"
#import "UECoreData.h"
#import "PaperViewController.h"
#import "RollingPaperCreator.h"
#import "CGPointExtension.h"
#import <QuartzCore/QuartzCore.h>
#import "UserSettingViewController.h"
#import <JSONKit.h>
#import "UIAlertViewBlockDelegate.h"
#import "LoginViewController.h"
#import "User.h"
#import "UIImageView+Vingle.h"

@implementation MainPaperViewController

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"롤링페이퍼"];
    
    _participatingPaperList = [[PaperListViewController alloc]init];
    [_participatingPaperList setDelegate:self];
    [self addChildViewController:_participatingPaperList];
    _sendedPaperList = [[PaperListViewController alloc]init];
    [_sendedPaperList setDelegate:self];
    [self addChildViewController:_sendedPaperList];
    _receivedPaperList = [[PaperListViewController alloc]init];
    [_receivedPaperList setDelegate:self];
    [self addChildViewController:_receivedPaperList];

    
    int index = 0;
    for (UIViewController *childViewController in [self childViewControllers]) {
        [[childViewController view] setLeft:(index++) * [_paperScrollView getWidth]];
        [_paperScrollView addSubview:[childViewController view]];
    }
    [_paperScrollView setContentSize:CGSizeMake([_paperScrollView getWidth] * 3, [_paperScrollView getHeight])];
}
- (void)viewDidUnload
{
    [self setPaperScrollView:nil];
    [super viewDidUnload];
}

-(void) refreshPaperList
{
    id failureBlock = ^(NSError *error) {
        [[[UIAlertViewBlock alloc] initWithTitle:@"경고"
                                         message:@"서버로부터 페이퍼 리스트를 받아오는데 실패했습니다"
                                   blockDelegate:^(UIAlertView *alertView, int clickedButtonIndex) {
                                       if(clickedButtonIndex == 1){
                                           [self refreshPaperList];
                                       }
                                   }
                               cancelButtonTitle:@"확인"
                               otherButtonTitles:@"재시도",nil] show];
    };
    
    User* currentUser = [[FlowithAgent sharedAgent] getCurrentUser];
    
    [currentUser getParticipaitingPapers:^(NSArray *papers) {
        [_participatingPaperList setPapers:papers];
        [[_participatingPaperList tableView] reloadData];
    } failure:failureBlock];
    [currentUser getSendedPapers:^(NSArray *papers) {
        [_sendedPaperList setPapers:papers];
        [[_sendedPaperList tableView] reloadData];
    } failure:failureBlock];
    [currentUser getReceivedPapers:^(NSArray *papers) {
        [_receivedPaperList setPapers:papers];
        [[_receivedPaperList tableView] reloadData];
    } failure:failureBlock];
}

- (void)selectTab:(NSInteger) index
{
    [_paperScrollView setContentOffset:CGPointMake([_paperScrollView getWidth] * index, 0)
                              animated:YES];
}

- (IBAction)onTouchTabButton:(UIButton *)sender {
    if (sender == _participatingTabButton) {
        [self selectTab:0];
    } else if (sender == _receivedTabButton) {
        [self selectTab:1];
    } else if (sender == _sendedTabButton) {
        [self selectTab:2];
    }
}
- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:FALSE
                                             animated:TRUE];
    UIButton* plusButton = [UIButton buttonWithType:UIButtonTypeCustom];
    plusButton.frame = CGRectMake(0, 0, 24,24);
    [plusButton setImage:[UIImage imageNamed:@"plus"]
                forState:UIControlStateNormal];
    [plusButton addTarget:self action:@selector(onTouchAddPaper:)
         forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* rightBarButton = [[UIBarButtonItem alloc]initWithCustomView:plusButton];
    [[self navigationItem] setRightBarButtonItem:rightBarButton
                                        animated:TRUE];
    UIButton* profileImageView = [UIButton buttonWithType:UIButtonTypeCustom];
    profileImageView.frame = CGRectMake(0, 0, 24,24);
    UIBarButtonItem* leftBarButton = [[UIBarButtonItem alloc]initWithCustomView:profileImageView];
    [profileImageView addTarget:self action:@selector(onTouchProfile:)
               forControlEvents:UIControlEventTouchUpInside];
    [[self navigationItem] setLeftBarButtonItem:leftBarButton
                                       animated:TRUE];
    
    [[[UIImageView alloc]init]setImageWithURL:[[User currentUser] picture]
    success:^(BOOL isCached, UIImage *image) {
        [profileImageView setImage:image forState:UIControlStateNormal];
        [profileImageView hideToTransparent];
        [profileImageView fadeIn:0.3f];
    } failure:^(NSError *error) {
        
    }];
    [self refreshPaperList];
}

- (IBAction)onTouchAddPaper:(id)sender
{
    RollingPaperCreator* controller = [[RollingPaperCreator alloc]initForCreating];
    [self.navigationController pushViewController:controller
                                         animated:TRUE];
}

- (IBAction)onTouchRefresh:(id)sender
{
    [self refreshPaperList];
}

- (IBAction)onTouchProfile:(id)sender
{
    UserSettingViewController* settingViewController = [[UserSettingViewController alloc] init];
    [self.navigationController pushViewController:settingViewController
                                         animated:TRUE];
}


#pragma UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat width = [scrollView frame].size.width;
    CGFloat x     = [scrollView contentOffset].x;
    [_pageControl setCurrentPage:(x + width*0.5)/width];
}

#pragma Rotation
-(BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)paperListViewController:(PaperListViewController *)controller backgroundToched:(RollingPaper *)paper
{
    
}
- (void)paperListViewController:(PaperListViewController *)controller settingTouched:(RollingPaper *)paper
{
    RollingPaperCreator* paperSettingView = [[RollingPaperCreator alloc] initForEditing:paper];
    [self.navigationController pushViewController:paperSettingView
                                         animated:TRUE];

}
@end
