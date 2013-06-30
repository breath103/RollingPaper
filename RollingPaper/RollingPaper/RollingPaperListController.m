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

static RollingPaperListController* g_instance = NULL;

@implementation RollingPaperListController

@synthesize paperScrollView;
+(RollingPaperListController*) getInstance
{
    return g_instance;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil
                           bundle:nibBundleOrNil];
    if (self) {
        paperCellControllers = [NSMutableArray new];
        g_instance = self;
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


-(void) removeAllPaperViews{
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
    User* currentUser = [[FlowithAgent sharedAgent] getCurrentUser];
    [currentUser getParticipaitingPapers:^(NSArray *papers) {
        [self createPaperViewsFromArray:papers];
    } failure:^(NSError *error) {
        [[[UIAlertViewBlock alloc] initWithTitle:@"경고"
                                         message:@"서버로부터 페이퍼 리스트를 받아오는데 실패했습니다"
                                   blockDelegate:^(UIAlertView *alertView, int clickedButtonIndex) {
                                       if(clickedButtonIndex == 1){
                                           [self refreshPaperList];
                                       }
                                   }
                               cancelButtonTitle:@"확인"
                               otherButtonTitles:@"재시도",nil] show];
    }];
}

-(NSMutableDictionary*) fetchAllRollingPaperWithIdxKey
{
    NSManagedObjectContext* managedObjectContext = [UECoreData sharedInstance].managedObjectContext;
    NSFetchRequest* fetchRequest = [NSFetchRequest new];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"RollingPaper"
                                                  inManagedObjectContext:[UECoreData sharedInstance].managedObjectContext];
    [fetchRequest setEntity:entityDesc];
    NSMutableArray *entities = [[managedObjectContext executeFetchRequest:fetchRequest error:NULL] mutableCopy];
    
    NSMutableDictionary* dict = [[NSMutableDictionary alloc]init];
    for(RollingPaper* rollingPaper in entities){
        [dict setObject:rollingPaper forKey:rollingPaper.id];
    }
    return dict;
}

-(void) createPaperViewsFromArray : (NSArray*) paperDictArray{
    int topBorder    = 21;
    int heightMargin = 13;
    int index        = 0;
    
    float cellContainerWidth = self.paperScrollView.frame.size.width;
    
    [self removeAllPaperViews];
    //NSMutableDictionary* storedPapers = [self fetchAllRollingPaperWithIdxKey];
    for(NSDictionary* p in paperDictArray){
        RollingPaper* entity = [[RollingPaper alloc]initWithDictionary:p];
        
//        if ([entity.is_sended isEqualToString:@"NONE"]) {
            PaperCellController* cellController = [[PaperCellController alloc] initWithEntity:entity
                                                                                     delegate:self];
            float viewHeight = cellController.view.frame.size.height;
            float viewWidth  = cellController.view.frame.size.width;
            UIViewSetOrigin(cellController.view, CGPointMake(cellContainerWidth/2 - viewWidth/2,
                                                             topBorder +  (heightMargin + viewHeight) * index++));
            [paperCellControllers addObject:cellController];

            [self addChildViewController:cellController];
            [self.paperScrollView addSubview:cellController.view];
            self.paperScrollView.contentSize = CGSizeMake(self.paperScrollView.frame.size.width,
                                                          topBorder + (heightMargin + viewHeight) * index);
//        } else if ([entity.is_sended compare:@"SENDED"] == NSOrderedSame) {
//        }
    }
}
- (void) viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:FALSE
                                             animated:TRUE];
    {
        UIButton* plusButton = [UIButton buttonWithType:UIButtonTypeCustom];
        plusButton.frame = CGRectMake(0, 0, 24,24);
        [plusButton setImage:[UIImage imageNamed:@"plus"]
                    forState:UIControlStateNormal];
        [plusButton addTarget:self action:@selector(onTouchAddPaper:)
             forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem* rightBarButton = [[UIBarButtonItem alloc]initWithCustomView:plusButton];
        [self.navigationItem setRightBarButtonItem:rightBarButton
                                         animated:TRUE];
    }
    /*
     [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
     [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], UITextAttributeTextColor,
     [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8],UITextAttributeTextShadowColor,
     [NSValue valueWithUIOffset:UIOffsetMake(0, 1)],
     UITextAttributeTextShadowOffset,
     [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:21.0], UITextAttributeFont, nil]];
     */
    {
        UIButton* profileImageView = [UIButton buttonWithType:UIButtonTypeCustom];
        profileImageView.frame = CGRectMake(0, 0, 24,24);
        UIBarButtonItem* leftBarButton = [[UIBarButtonItem alloc]initWithCustomView:profileImageView];
        [profileImageView addTarget:self action:@selector(onTouchProfile:)
                   forControlEvents:UIControlEventTouchUpInside];
        [self.navigationItem setLeftBarButtonItem:leftBarButton
                                         animated:TRUE];
        if([[FlowithAgent sharedAgent] getUserInfo]){
            [[FlowithAgent sharedAgent] getProfileImage:^(BOOL isCachedResponse, UIImage *image) {
                [profileImageView setImage:image forState:UIControlStateNormal];
                [profileImageView hideToTransparent];
                [profileImageView fadeIn:0.3f];
            }];
            [self refreshPaperList];
        }
        else{
            
            //이미 로그인 된것이 확인되서 들어왔는데 유저 정보가 없다고 뜨는 크리티컬한 에러거나, 로그아웃을 눌러서 이 페이지로 온경우
            /*
            [[[UIAlertView alloc] initWithTitle:@"error"
                                        message:@"유저 정보를 확인할 수 없습니다"
                                       delegate:NULL
                              cancelButtonTitle:NULL
                              otherButtonTitles:@"확인", nil] show];
            */
        //    [self.navigationController popViewControllerAnimated:TRUE];
            LoginViewController* loginMethodViewController = [[LoginViewController alloc] init];
            [self.navigationController pushViewController:loginMethodViewController
                                                 animated:TRUE];
        }
    }
}

-(void) PaperCellTouched : (PaperCellController *) paper
{
    PaperViewController* paperViewController = [[PaperViewController alloc] initWithEntity:paper.entity];
    [self.navigationController pushViewController:paperViewController animated:TRUE];
}
-(void) paperCellSettingTouched:(PaperCellController *)paper
{
    RollingPaperCreator* paperSettingView = [[RollingPaperCreator alloc] initForEditing:paper.entity];
    paperSettingView.listController = self;
    [self.navigationController pushViewController : paperSettingView
                                         animated : TRUE];
}

- (IBAction)onTouchAddPaper:(id)sender {
    RollingPaperCreator* controller = [[RollingPaperCreator alloc]initForCreating];
    controller.listController = self;
    [self.navigationController pushViewController:controller
                                         animated:TRUE];
}

- (IBAction)onTouchRefresh:(id)sender {
    [self refreshPaperList];
}

- (IBAction)onTouchProfile:(id)sender {
    UserSettingViewController* settingViewController = [[UserSettingViewController alloc] initWithDefaultNib];
    [self.navigationController pushViewController:settingViewController
                                         animated:TRUE];
}
@end
