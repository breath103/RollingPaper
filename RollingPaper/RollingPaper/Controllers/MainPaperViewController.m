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
#import "NotificationsViewController.h"
#import "PaperSettingsViewController.h"
#import "UIImageView+Vingle.h"
#import "AppSettingsViewController.h"
#import <QuartzCore/QuartzCore.h>

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
    
    [[_profileImageView layer] setCornerRadius:1.5f];
    [_profileImageView setClipsToBounds:YES];
    
    [_participatingTabButton setImage:[UIImage imageNamed:@"main_btn_editing_click"]
                             forState:UIControlStateNormal|UIControlStateSelected];
    [_sendedTabButton setImage:[UIImage imageNamed:@"main_btn_received_click"]
                        forState:UIControlStateNormal|UIControlStateSelected];
    [_receivedTabButton setImage:[UIImage imageNamed:@"main_btn_sent_click"]
                      forState:UIControlStateNormal|UIControlStateSelected];
    
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
        NSLog(@"%@",error);
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
    int i = 0;
    for (UIButton *button in _tabButtons) {
        if (i== index) {
            [button setSelected:YES];
        } else {
            [button setSelected:NO];
        }
        i++;
    }

    [_paperScrollView setContentOffset:CGPointMake([_paperScrollView getWidth]*index, 0)
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
    [self.navigationController setNavigationBarHidden:YES
                                             animated:NO];
    [_profileImageView setImageWithURL:[[User currentUser] picture] withFadeIn:0.1f];
    [self refreshPaperList];
}

- (IBAction)onTouchAddPaper:(id)sender
{
    PaperSettingsViewController *controller = [[PaperSettingsViewController alloc]init];
    [self.navigationController pushViewController:controller
                                         animated:TRUE];
}

- (IBAction)onTouchRefresh:(id)sender
{
    [self refreshPaperList];
}

- (IBAction)onTouchProfile:(id)sender
{
    [[self navigationController] pushViewController:[[AppSettingsViewController alloc]init]
                                           animated:YES];
}

- (IBAction)onTouchNotificationsButton:(id)sender
{
    NotificationsViewController *controller = [[NotificationsViewController alloc]init];
    [[self navigationController] pushViewController:controller animated:YES];
}


#pragma UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    CGFloat width = [scrollView frame].size.width;
//    CGFloat x     = [scrollView contentOffset].x;
//    [UIView animateWithDuration:0.1f animations:^{
//        int index = 0;
//        for (UIView *view in _buttonUnderlines) {
//            if (index == (NSInteger)((x + width*0.5)/width)) {
//                [view setAlpha:1.0f];
//            } else {
//                [view setAlpha:0.2f];
//            }
//            index++;
//        }
//    }];
//    
//    int index = 0;
//    for (UIButton *button in _tabButtons) {
//        if (index == (NSInteger)((x + width*0.5)/width)) {
//            [button setSelected:YES];
//        } else {
//            [button setSelected:NO];
//        }
//        index++;
//    }
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
    [[self navigationController] pushViewController:[[PaperViewController alloc]initWithEntity:paper]
                                           animated:YES];
}
- (void)paperListViewController:(PaperListViewController *)controller settingTouched:(RollingPaper *)paper
{
    [[self navigationController] pushViewController:[[PaperSettingsViewController alloc]initWithPaper:paper]
                                           animated:TRUE];
}
@end
