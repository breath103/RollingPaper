#import "RollingPaperListController.h"
#import "FlowithAgent.h"
#import "BlockSupport/NSObject+block.h"
#import "RollingPaper.h"
#import "UECoreData.h"
#import "PaperViewController.h"
#import "RollingPaperCreator.h"
#import "macro.h"
#import "CGPointExtension.h"
#import <QuartzCore/QuartzCore.h>
#import "UELib/UEUI.h"
#import "UserSettingViewController.h"
#import <JSONKit.h>
#import "UIAlertViewBlockDelegate.h"
#import "LoginViewController.h"
#import "User.h"
#import "UIImageView+Vingle.h"

@implementation RollingPaperListController

- (id)init
{
    self = [super init];
    if (self) {
        paperCellControllers = [NSMutableArray new];
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"롤링페이퍼"];
}
- (void)viewDidUnload
{
    [self setPaperScrollView:nil];
    [super viewDidUnload];
}


-(void) removeAllPaperViews
{
    for(PaperCellController* controller in paperCellControllers){
        [UIView animateWithDuration:0.3f animations:^{
            controller.view.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [controller.view removeFromSuperview];
        }];
        [controller removeFromParentViewController];
    }
    [paperCellControllers removeAllObjects];
}

-(void) refreshPaperList
{
    [self removeAllPaperViews];
    
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
        [self createPaperViewsFromArray:papers];
    } failure:failureBlock];
    
    [currentUser getReceivedPapers:^(NSArray *papers) {
        [self createReceivedPapers:papers];
    } failure:failureBlock];
}

- (void)createPaperViewsFromArray:(NSArray *)papers
{
    int topBorder    = 21;
    int heightMargin = 13;
    int index        = 0;
    float cellContainerWidth = self.paperScrollView.frame.size.width;
    for(RollingPaper* paper in papers){
        PaperCellController* cellController = [[PaperCellController alloc] initWithEntity:paper
                                                                                 delegate:self];
        float viewHeight = cellController.view.frame.size.height;
        float viewWidth  = cellController.view.frame.size.width;
        UIViewSetOrigin(cellController.view, CGPointMake(cellContainerWidth/2 - viewWidth/2,
                                                         topBorder +  (heightMargin + viewHeight) * index++));
        [paperCellControllers addObject:cellController];

        [self addChildViewController:cellController];
        [self.paperScrollView addSubview:cellController.view];
        self.paperScrollView.contentSize = CGSizeMake(self.paperScrollView.frame.size.width * 2,
                                                      topBorder + (heightMargin + viewHeight) * index);
    }
}

- (void)createReceivedPapers:(NSArray *)papers
{
    int topBorder    = 21;
    int heightMargin = 13;
    int index        = 0;
    float cellContainerWidth = self.paperScrollView.frame.size.width;
    for(RollingPaper* paper in papers){
        PaperCellController* cellController = [[PaperCellController alloc] initWithEntity:paper
                                                                                 delegate:self];
        float viewHeight = cellController.view.frame.size.height;
        float viewWidth  = cellController.view.frame.size.width;
        UIViewSetOrigin(cellController.view, CGPointMake(cellContainerWidth/2 - viewWidth/2 + _paperScrollView.frame.size.width,
                                                         topBorder +  (heightMargin + viewHeight) * index++));
        [paperCellControllers addObject:cellController];
        
        [self addChildViewController:cellController];
        [self.paperScrollView addSubview:cellController.view];
        self.paperScrollView.contentSize = CGSizeMake(self.paperScrollView.frame.size.width * 2,
                                                      topBorder + (heightMargin + viewHeight) * index);
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
    [self.navigationItem setRightBarButtonItem:rightBarButton
                                     animated:TRUE];

    UIButton* profileImageView = [UIButton buttonWithType:UIButtonTypeCustom];
    profileImageView.frame = CGRectMake(0, 0, 24,24);
    UIBarButtonItem* leftBarButton = [[UIBarButtonItem alloc]initWithCustomView:profileImageView];
    [profileImageView addTarget:self action:@selector(onTouchProfile:)
               forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:leftBarButton
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

- (void)PaperCellTouched:(PaperCellController *)paper
{
    PaperViewController *paperViewController = [[PaperViewController alloc] initWithEntity:paper.entity];
    [self.navigationController pushViewController:paperViewController animated:TRUE];
}
- (void)paperCellSettingTouched:(PaperCellController *)paper
{
    RollingPaperCreator *paperSettingView = [[RollingPaperCreator alloc] initForEditing:paper.entity];
    [self.navigationController pushViewController : paperSettingView
                                         animated : TRUE];
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
    UserSettingViewController* settingViewController = [[UserSettingViewController alloc] initWithDefaultNib];
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
@end
