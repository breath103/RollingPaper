#import "RollingPaperCreator.h"
#import "FlowithAgent.h"
#import "NSObject+block.h"
#import <QuartzCore/QuartzCore.h>
#import "PaperViewController.h"
#import "UECoreData.h"
#import "UELib/UEImageLibrary.h"
#import <JSONKit.h>
#import "FlowithAgent.h"
#import "PaperBackgroundPicker.h"
#import <UIImageView+AFNetworking.h>
#import "User.h"
#import "UIAlertViewBlockDelegate.h"
#import "PaperParticipantsListController.h"
#import "UIImageView+Vingle.h"

@interface RollingPaperCreator ()

@end

@implementation RollingPaperCreator
@synthesize titleText;
@synthesize emailInput;
@synthesize noticeInput;
@synthesize receiverName;
@synthesize receiveTime;
@synthesize contentContainer;
@synthesize receiverFacebookID;


-(void) hideKeyboard{
    [self.view endEditing:TRUE];
}
-(void) initPaperCellPreview
{
    UIImage* mask_image = [ UIImage imageNamed:@"paper_cell_bg"];
    CGSize size = self.paperCellImage.frame.size;
    CALayer* maskLayer = [CALayer layer];
    maskLayer.frame = CGRectMake(0,0,size.width,size.height);
    maskLayer.contents = (__bridge id)[mask_image CGImage];
    self.paperCellImage.layer.mask = maskLayer;
    [self.paperCellImage setNeedsDisplay];
}
-(void) _addButtonShadow : (UIButton*) button
{
    button.layer.cornerRadius = 4;
    button.layer.shadowColor = [UIColor blackColor].CGColor;
    button.layer.shouldRasterize = TRUE;
    button.layer.shadowRadius = 1.0f;
    button.layer.shadowOpacity = 0.5;
    button.layer.shadowOffset  = CGSizeMake(3,3);
    button.layer.rasterizationScale = [UIScreen mainScreen].scale;
}

-(void) initScrollView
{
    [self.scrollView addSubview:self.contentContainer];
    self.scrollView.contentSize = self.contentContainer.frame.size;
}


#pragma PaperBackgroundPicker Delegate
-(void) paperBackgroundPickerDidCancelPicking:(PaperBackgroundPicker *)picker{
    [self dismissViewControllerAnimated:TRUE
     completion:^{
        
    }];
}


-(void) setPaperCellBackgroundWithName : (NSString*) backgroundName{
    self.selectedBackgroundName = backgroundName;
    [_paperCellImage setImageWithURL:backgroundName
    withFadeIn:0.1f
    success:^(BOOL isCached, UIImage *image) {
        _paperCellImage.image = NULL;
        _paperCellImage.backgroundColor = [UIColor colorWithPatternImage:image];
        [_paperCellImage setNeedsDisplay];
    } failure:^(NSError *error) {
        
    }];
}


-(void) paperBackgroundPicker:(PaperBackgroundPicker *)picker
            didPickBackground:(NSString*) backgroundName{
    [self setPaperCellBackgroundWithName:backgroundName];
    [self dismissViewControllerAnimated:TRUE
                             completion:^{
                                 
                             }];

}
/////

- (void)deleteAllParticipants{
    for(UIView* view in self.participantsContainer.subviews){
        if(view != [self.participantsContainer.subviews objectAtIndex:0])
            [view removeFromSuperview];
    }
}
- (void)createNewParticipnatsCell : (id<FBGraphUser>) user{
    CGSize buttonSize = CGSizeMake(270, 37);
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    if( (self.participantsContainer.subviews.count-1) == 0)
        [button setBackgroundImage:[UIImage imageNamed:@"userlist_top"] forState:UIControlStateNormal];
    else
        [button setBackgroundImage:[UIImage imageNamed:@"userlist_center"] forState:UIControlStateNormal];
    
    button.frame = CGRectMake(0, buttonSize.height * (self.participantsContainer.subviews.count-1),
                              buttonSize.width, buttonSize.height);
    [button setTitle:[user objectForKey:@"name"] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
   
    UIImageView* profileView = [[UIImageView alloc] initWithImage:NULL];
    profileView.frame = CGRectMake(12.5, 10, 19, 19);
    [button addSubview:profileView];
    [self.participantsContainer addSubview:button];

    NSString* profileURL =[[[user objectForKey:@"picture"] objectForKey:@"data"]objectForKey :@"url" ];

    [profileView setImageWithURL:[NSURL URLWithString:profileURL]];
    
    UIViewSetHeight(self.participantsContainer,
                    self.participantsContainer.subviews.count * buttonSize.height);
    UIViewSetY([self.participantsContainer.subviews objectAtIndex:0],
               (self.participantsContainer.subviews.count-1) * buttonSize.height);
    
    float delta = buttonSize.height * self.participantsContainer.subviews.count;
    
    CGSize contentSize = self.scrollView.contentSize;
    contentSize.height = 667 + delta;
    self.scrollView.contentSize = contentSize;
    UIViewSetHeight(self.contentContainer, 667 + delta);
    UIViewSetY(self.bottomViewsContainer, 486+delta);
}
- (void)addParticipantsView : (User*) participant{
    CGSize buttonSize = CGSizeMake(270, 37);
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    if( (self.participantsContainer.subviews.count-1) == 0)
        [button setBackgroundImage:[UIImage imageNamed:@"userlist_top"] forState:UIControlStateNormal];
    else
        [button setBackgroundImage:[UIImage imageNamed:@"userlist_center"] forState:UIControlStateNormal];
    
    button.frame = CGRectMake(0, buttonSize.height * (self.participantsContainer.subviews.count-1),
                              buttonSize.width, buttonSize.height);
    [button setTitle:participant.name forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    UIImageView* profileView = [[UIImageView alloc] initWithImage:NULL];
    profileView.frame = CGRectMake(12.5, 10, 19, 19);
    [button addSubview:profileView];
    [self.participantsContainer addSubview:button];
   
    [profileView setImageWithURL:[NSURL URLWithString:participant.picture]];
    
    
    UIViewSetHeight(self.participantsContainer,
                    self.participantsContainer.subviews.count * buttonSize.height);
    UIViewSetY([self.participantsContainer.subviews objectAtIndex:0],
               (self.participantsContainer.subviews.count-1) * buttonSize.height);
    
    float delta = buttonSize.height * self.participantsContainer.subviews.count;
    
    CGSize contentSize = self.scrollView.contentSize;
    contentSize.height = 667 + delta;
    self.scrollView.contentSize = contentSize;
    UIViewSetHeight(self.contentContainer, 667 + delta);
    UIViewSetY(self.bottomViewsContainer, 486+delta);
}
- (void)syncViewToPaper{
    if (self.entity) {
        self.entity.creatorId = [FlowithAgent sharedAgent].getUserIdx;
        self.entity.title            = self.titleText.text;
        self.entity.width            = @(1440);
        self.entity.height           = @(960);
        self.entity.notice           = self.noticeInput.text;
        self.entity.background       = self.selectedBackgroundName;
        self.entity.friend_facebook_id = self.receiverFacebookID;
        self.entity.receive_time     = [self buildRequestDate];
    }
}
- (void)syncPaperToView
{
    if (self.entity) {
        self.titleText.text    = self.entity.title;
        self.noticeInput.text  = self.entity.notice;
    
        NSDate* receiveDate = [NSDate dateWithTimeIntervalSince1970: [[NSNumberFormatter new]numberFromString:self.entity.receive_time].longLongValue ];
        self.receiveDate.text = [self dateToString:receiveDate];
        self.receiveTime.text = [self timeToString:receiveDate];
        [self setPaperCellBackgroundWithName:self.entity.background];

        //FIXME
//        [[FlowithAgent sharedAgent] getPaperParticipants:self.entity
//        success:^(BOOL isCachedResponse, NSArray *participants) {
//            [self deleteAllParticipants];
//            for(User* user in participants){
//                [self addParticipantsView:user];
//            }
//        } failure:^(NSError *error) {
//            NSLog(@"%@",error);
//        }];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    
    [self.navigationController setNavigationBarHidden:FALSE
                                             animated:TRUE];
    
    {
        UIButton* leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        leftButton.frame = CGRectMake(0, 0, 24,24);
        [leftButton setImage:[UIImage imageNamed:@"previousArrow"]
                    forState:UIControlStateNormal];
        [leftButton addTarget:self
                       action:@selector(onTouchPrevious:)
             forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem* leftBarButton = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
        [self.navigationItem setLeftBarButtonItem:leftBarButton
                                          animated:TRUE];
    }
    {
        /*
        UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        rightButton.frame = CGRectMake(0, 0, 24,24);
        [rightButton setImage:[UIImage imageNamed:@"nextArrow"] forState:UIControlStateNormal];
        [rightButton addTarget:self action:@selector(onTouchProfile:)
                   forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem* rightBarButton = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
        [self.navigationItem setRightBarButtonItem:rightBarButton
                                         animated:TRUE];
         */
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                        action:@selector(hideKeyboard)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:gestureRecognizer];
    
    [self initScrollView];
    [self initPaperCellPreview];
    
    //[self initParticipantsListController];
    
    self.datePicker.minimumDate = [NSDate date];
    self.receiveDate.inputView = self.datePicker;
    self.receiveTime.inputView = self.timePicker;
    
    switch (self.controllerType) {
        case PAPER_CONTROLLER_TYPE_CREATING:{
            self.title = @"RollingPaper 만들기";
            [self.finishButton setTitle:@"완료"
                               forState:UIControlStateNormal];
            [self.finishButton addTarget:self
                                  action:@selector(onTouchSend:)
                        forControlEvents:UIControlEventTouchUpInside];
        }break;
        case PAPER_CONTROLLER_TYPE_EDITING_CREATOR:{
            [self syncPaperToView];
            self.title = @"RollingPaper 편집";
            [self.finishButton setTitle:@"지우기"
                               forState:UIControlStateNormal];
            [self.finishButton addTarget:self
                                  action:@selector(onTouchQuit:)
                        forControlEvents:UIControlEventTouchUpInside];
        }break;
        case PAPER_CONTROLLER_TYPE_EDITING_PARTICIPANTS:{
            [self syncPaperToView];
            self.title = @"RollingPaper 편집";
            [self.finishButton setTitle:@"나가기"
                               forState:UIControlStateNormal];
            [self.finishButton addTarget:self
                                  action:@selector(onTouchQuit:)
                        forControlEvents:UIControlEventTouchUpInside];
        }break;
        default:
            break;
    }
}

- (id)initForCreating
{
    self = [self init];
    if (self) {
        self.controllerType = PAPER_CONTROLLER_TYPE_CREATING;
        _entity = [[RollingPaper alloc]init];
//        self.entity = (RollingPaper*)[[UECoreData sharedInstance] insertNewObject : @"RollingPaper"];
    }
    return self;
}
- (id)initForEditing:(RollingPaper*) aEntity{
    self = [self init];
    if (self) {
        self.entity = aEntity;
        if([[[FlowithAgent sharedAgent] getUserIdx] isEqualToNumber:self.entity.creatorId]) {
            self.controllerType = PAPER_CONTROLLER_TYPE_EDITING_CREATOR;
        }
        else {
            self.controllerType = PAPER_CONTROLLER_TYPE_EDITING_PARTICIPANTS;
        }
    }
    return self;
}
-(void) onTouchNext{
    [self onTouchSend:NULL];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTitleText :nil];
    [self setEmailInput :nil];
    [self setNoticeInput :nil];
    [self setReceiverName :nil];
    [self setReceiveTime :nil];
    [self setDatePicker:nil];
    [self setReceiveTime:nil];
    [self setReceiveDate:nil];
    [super viewDidUnload];
}
- (BOOL) confirmInputs{
    if(self.titleText.text.length <= 0){
        [[[UIAlertView alloc]initWithTitle:@"경고"
                                   message:@"제목을 입력해주세요"
                                  delegate:NULL
                         cancelButtonTitle:@"확인"
                         otherButtonTitles:NULL, nil] show];
        return FALSE;
    }
    return TRUE;
}
- (IBAction)onTouchPrevious:(id)sender {
    if(self.controllerType == PAPER_CONTROLLER_TYPE_EDITING_CREATOR){
        [self syncViewToPaper];
        [[FlowithAgent sharedAgent] updatePaper:self.entity
          success:^(RollingPaper *paper) {
              self.entity = paper;
              [self.listController refreshPaperList];
              [self.navigationController popViewControllerAnimated:TRUE];
        } failure:^(NSError *error) {
            NSLog(@"%@",error);
            [[[UIAlertView alloc] initWithTitle:@"에러"
                                        message:@"서버와 통신 실패"
                                       delegate:nil
                              cancelButtonTitle:@"확인"
                              otherButtonTitles:nil] show];
        }];
    }
    else{
        [self.navigationController popViewControllerAnimated:TRUE];
    }
}

- (IBAction)onTouchNext:(id)sender {
    [self onTouchSend:NULL];
}


- (void) createPaperRequestSuccess{
    //편집 뷰를 만든다음
    PaperViewController* paperViewController = [[PaperViewController alloc] initWithEntity:self.entity];
    
    self.navigationController.delegate = self;
    [self.navigationController pushViewController : paperViewController
                                         animated : TRUE];
    if(self.listController)
        [self.listController refreshPaperList];
}
- (IBAction)onTouchSend:(id)sender {
    if([self confirmInputs]) {
        [self syncViewToPaper];
        [_entity saveToServer:^{
            [self createPaperRequestSuccess];
        } failure:^(NSError *error) {
            [[[UIAlertView alloc] initWithTitle:@"실패"
                                        message:@"롤링페이퍼 서버에 페이퍼 만들기 요청이 실패하였습니다.\n인터넷 연결상태를 확인해주세요"
                                       delegate:nil
                              cancelButtonTitle:nil
                              otherButtonTitles:@"확인", nil] show];
        }];
       //  [_entity saveToServer:nil failure:nil];
//        if(self.invitingFreindPicker &&
//           self.invitingFreindPicker.selection.count > 0){
//            NSMutableArray* facebook_friends = [NSMutableArray new];
//            for (id<FBGraphUser> user in self.invitingFreindPicker.selection)
//                [facebook_friends addObject: [user id]];
//            [[FlowithAgent sharedAgent] inviteFacebookFreinds:facebook_friends toPaper:self.entity
//                                                      success:^{
//                                                          
//                                                      } failure:^(NSError *error) {
//                                                          
//                                                      }];
//        }
//        else{
//            //친구초대가 없는경우
//        }
    }
    else{
        NSLog(@"입력폼에 문제가 있음");
    }
}
-(IBAction)onTouchQuit:(UIButton*)sender{
    [[[UIAlertViewBlock alloc] initWithTitle:@"경고"
                                message:@"이 롤링페이퍼를 지우시겠습니까?"
                               blockDelegate:^(UIAlertView *alertView, int clickedButtonIndex) {
                                   if(clickedButtonIndex == 0) {
                                       [[FlowithAgent sharedAgent] quitPaper:self.entity
                                        success:^{
                                            [self.navigationController popViewControllerAnimated:TRUE];
                                            if(self.listController)
                                                [self.listController refreshPaperList];
                                        } failure:^(NSError *error) {
                                            [[[UIAlertView alloc] initWithTitle:@"에러"
                                                                        message:@"서버와의 통신에 실패했습니다.\n인터넷 연결 상태를 확인해주세요"
                                                                       delegate:nil
                                                              cancelButtonTitle:nil
                                                              otherButtonTitles:@"확인", @"취소",nil] show];
                                            NSLog(@"%@",error);
                                        }];
                                   }
                                   else{
                                       NSLog(@"취소");
                                   }
                               }
                      cancelButtonTitle:nil
                      otherButtonTitles:@"확인", @"취소",nil] show];
}
-(void) navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated{
    if([viewController isKindOfClass:PaperViewController.class]){
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }
}


- (IBAction)onTouchPickFriend:(id)sender {
    self.receivingFriendPicker= [[FBFriendSearchPickerController alloc] init];
    self.receivingFriendPicker.title    = @"친구 선택";
    self.receivingFriendPicker.delegate = self;
    self.receivingFriendPicker.allowsMultipleSelection = FALSE;
    [self.receivingFriendPicker loadData];
    [self.receivingFriendPicker clearSelection];
    [self presentViewController:self.receivingFriendPicker
                       animated:YES
                     completion:^{}];
}
- (BOOL)friendPickerViewController : (FBFriendSearchPickerController*)friendPicker
                 shouldIncludeUser : (id<FBGraphUser>)user{
    return [friendPicker delegateFriendPickerViewController:friendPicker
                                          shouldIncludeUser:user];
}
- (IBAction)onHideKeyboard:(id)sender {
    [self.view endEditing:TRUE];
}

-(NSString*) dateToString : (NSDate*) date{
    NSDateComponents* components = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
                                                             fromDate:date]; // Get necessary date components
    return [NSString stringWithFormat:@"%d-%02d-%02d",components.year,components.month,components.day];
}
-(NSString*) timeToString : (NSDate*) date{
    NSDateComponents* components = [[NSCalendar currentCalendar] components:NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit
                                         fromDate:date]; // Get necessary date components
    return [NSString stringWithFormat:@"%02d:%02d:%02d",components.hour,components.minute,components.second];
}


- (IBAction)onPickDate:(UIDatePicker *)sender {
    self.receiveDate.text = [self dateToString:sender.date];
}
-(IBAction)onPickTime:(UIDatePicker *)sender{
    self.receiveTime.text = [self timeToString:sender.date];
}
- (IBAction)onTouchReceiveDate:(id)sender {
    
}

- (IBAction)onTouchInvite:(id)sender
{
    self.participantsListController = [[PaperParticipantsListController alloc]initWithPaper:self.entity];
    [self.navigationController pushViewController:self.participantsListController animated:TRUE];
}

- (IBAction)onTouchPickBackground:(id)sender {
    PaperBackgroundPicker* picker = [[PaperBackgroundPicker alloc]initWithInitialBackgroundName:self.selectedBackgroundName
                                                                                       Delegate:self];
    [self presentViewController:picker
                       animated:TRUE
                     completion:^{
                         
                     }];

}
-(NSString*) dateToFormatString : (NSDate*) date{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    return [dateFormatter stringFromDate:date];
}
-(NSDate*) facebookDateToNSDate : (NSString*) str{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    return [dateFormatter dateFromString:str];
}
-(NSString*) facebookBirthdayToLocal : (NSString*) str{
    NSDate* date = [self facebookDateToNSDate:str];
    return [self dateToFormatString:date];
}
-(NSDate*) facebookBirthDayToCurrentBirthDay : (NSString* ) birthday{
    NSDate* fbBirthday = [self facebookDateToNSDate:birthday];
    
    NSDateComponents* todayComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
                                                                        fromDate:[NSDate date]];
    NSDateComponents* fbBirthdayComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
                                                                             fromDate:fbBirthday]; // Get necessary date components
    //우선 년도를 현재 년도로 잡는다.
    fbBirthdayComponents.year = todayComponents.year;
    if( (fbBirthdayComponents.month < todayComponents.month) ||
        (fbBirthdayComponents.month == todayComponents.month && fbBirthdayComponents.day < todayComponents.day) ){
        //현재년도로 옮겼을때 날짜가 현재날짜보다 앞이라면, 즉 이미 지난 날짜라면
        fbBirthdayComponents.year += 1;
    }
    return [[NSCalendar currentCalendar] dateFromComponents:fbBirthdayComponents];
}
-(NSString*) buildRequestDate{
    return [NSString stringWithFormat:@"%@ %@",self.receiveDate.text,self.receiveTime.text];
}
-(void) facebookViewControllerCancelWasPressed:(FBFriendSearchPickerController*)sender{
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}


-(void) fillReceiverDataInputsWithFacebookUser : (id<FBGraphUser>) user {
    FBRequest* request = [FBRequest requestWithGraphPath:[user id]
                                              parameters:@{@"fields":@"email,birthday,name"}
                                              HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id<FBGraphUser> result, NSError *error) {
        if([result birthday]){
            self.receiveDate.text = [self dateToFormatString:[self facebookBirthDayToCurrentBirthDay:[result birthday]]];
            self.receiveTime.text = @"00:00:00";
        }
    }];
    self.receiverFacebookID = user.id;
    receiverName.text = user.name;
    
    [[FlowithAgent sharedAgent] getUserWithFacebookID:[user id]
                                              success:^(User* user) {
                                                  if(user.email)
                                                      self.emailInput.text = user.email;
                                              } failure:^(NSError *error) {
                                                  NSLog(@"%@",error);
                                              }];

}


-(void) facebookViewControllerDoneWasPressed : (FBFriendSearchPickerController*)sender{
    if(self.controllerType == PAPER_CONTROLLER_TYPE_CREATING)
    {
        if(self.receivingFriendPicker == sender){
            id<FBGraphUser> user = [self.receivingFriendPicker.selection objectAtIndex:0];
            [self fillReceiverDataInputsWithFacebookUser:user];
            [self dismissViewControllerAnimated:YES completion:^{
            }];
        }
        else if(self.invitingFreindPicker == sender){
            //방 만들기 모드에서 같이 만들 친구 모을때
            [self deleteAllParticipants];
            for (id<FBGraphUser> user in self.invitingFreindPicker.selection)
                [self createNewParticipnatsCell:user];
            [self dismissViewControllerAnimated:TRUE completion:^{
            
            }];
        }
    }
    else{ //방 편집모드
        if(self.receivingFriendPicker == sender){
            id<FBGraphUser> user = [self.receivingFriendPicker.selection objectAtIndex:0];
            [self fillReceiverDataInputsWithFacebookUser:user];
            [self dismissViewControllerAnimated:YES completion:^{
            }];
        }
        else if(self.invitingFreindPicker == sender){
            //방 만들기 모드에서 같이 만들 친구 초대할때
            NSMutableArray* facebook_friends = [NSMutableArray new];
            for (id<FBGraphUser> user in self.invitingFreindPicker.selection)
                [facebook_friends addObject: [user id]];
            
            [[FlowithAgent sharedAgent]inviteFacebookFreinds:facebook_friends
                                                     toPaper:self.entity
            success:^{
                [self syncPaperToView];
                [self dismissViewControllerAnimated:YES completion:^{
                    
                }];
            } failure:^(NSError *error) {
                NSLog(@"%@",error);
            }];
        }
    }
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
