#import "RollingPaperCreator.h"
#import "FlowithAgent.h"
#import <QuartzCore/QuartzCore.h>
#import "PaperViewController.h"
#import "UECoreData.h"
#import <JSONKit.h>
#import "FlowithAgent.h"
#import "PaperBackgroundPicker.h"
#import <UIImageView+AFNetworking.h>
#import "User.h"
#import "UIAlertViewBlockDelegate.h"
#import "PaperParticipantsListController.h"
#import "UIImageView+Vingle.h"
#import "UserTableViewController.h"

@implementation RollingPaperCreator
- (id)initForCreating
{
    self = [self init];
    if (self) {
        _controllerType = PAPER_CONTROLLER_TYPE_CREATING;
        _entity = [[RollingPaper alloc]init];
    }
    return self;
}

- (id)initForEditing:(RollingPaper *)aEntity
{
    self = [self init];
    if (self) {
        self.entity = aEntity;
        if([[[FlowithAgent sharedAgent] getUserIdx] isEqualToNumber:[_entity creatorId]]) {
            _controllerType = PAPER_CONTROLLER_TYPE_EDITING_CREATOR;
        }
        else {
            _controllerType = PAPER_CONTROLLER_TYPE_EDITING_PARTICIPANTS;
        }
    }
    return self;
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
    
    self.datePicker.minimumDate = [NSDate date];
    self.receiveDate.inputView = self.datePicker;
    self.receiveTime.inputView = self.timePicker;

    switch (_controllerType) {
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
        default: break;
    }
}
- (void)initScrollView
{
    [_scrollView addSubview:self.contentContainer];
    _scrollView.contentSize = self.contentContainer.frame.size;
}
- (void)initPaperCellPreview
{
    UIImage* mask_image = [ UIImage imageNamed:@"paper_cell_bg"];
    CGSize size = self.paperCellImage.frame.size;
    CALayer* maskLayer = [CALayer layer];
    maskLayer.frame = CGRectMake(0,0,size.width,size.height);
    maskLayer.contents = (__bridge id)[mask_image CGImage];
    self.paperCellImage.layer.mask = maskLayer;
    [self.paperCellImage setNeedsDisplay];
}

- (void)onTouchNext
{
    [self onTouchSend:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    
    [self.navigationController setNavigationBarHidden:FALSE
                                             animated:TRUE];
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

- (void)setSelectedBackgroundName:(NSString *)selectedBackgroundName
{
    _selectedBackgroundName = selectedBackgroundName;
    if (selectedBackgroundName) {
        [_paperCellImage setImageWithURL:selectedBackgroundName
                              withFadeIn:0.1f
                                 success:^(BOOL isCached, UIImage *image) {
                                     _paperCellImage.image = NULL;
                                     _paperCellImage.backgroundColor = [UIColor colorWithPatternImage:image];
                                     [_paperCellImage setNeedsDisplay];
                                 } failure:^(NSError *error) {
                                     
                                 }];
    }
}

-(void) hideKeyboard
{
    [self.view endEditing:TRUE];
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


- (void)deleteAllParticipants
{
    for(UIView* view in self.participantsContainer.subviews){
        if(view != [self.participantsContainer.subviews objectAtIndex:0])
            [view removeFromSuperview];
    }
}
- (void)addParticipantsView:(User *)participant
{
    CGSize buttonSize = CGSizeMake(270, 37);
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    if( (self.participantsContainer.subviews.count-1) == 0)
        [button setBackgroundImage:[UIImage imageNamed:@"userlist_top"] forState:UIControlStateNormal];
    else
        [button setBackgroundImage:[UIImage imageNamed:@"userlist_center"] forState:UIControlStateNormal];
    
    button.frame = CGRectMake(0, buttonSize.height * (self.participantsContainer.subviews.count-1),
                              buttonSize.width, buttonSize.height);
    [button setTitle:[participant username] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    UIImageView* profileView = [[UIImageView alloc] initWithFrame:CGRectMake(12.5, 10, 19, 19)];
    [button addSubview:profileView];
    [self.participantsContainer addSubview:button];
   
    [profileView setImageWithURL:[NSURL URLWithString:participant.picture]];
    
    
    UIViewSetHeight(self.participantsContainer,
                    self.participantsContainer.subviews.count * buttonSize.height);
    UIViewSetY([self.participantsContainer.subviews objectAtIndex:0],
               (self.participantsContainer.subviews.count-1) * buttonSize.height);
    
    float delta = buttonSize.height * self.participantsContainer.subviews.count;
    
    CGRect rect = [[self bottomViewsContainer] frame];
    self.scrollView.contentSize = CGSizeMake([self scrollView].frame.size.width,
                                             rect.origin.y + rect.size.height);
    UIViewSetHeight(self.contentContainer, 667 + delta);
    UIViewSetY(self.bottomViewsContainer, 486+delta);
}

- (void)syncViewToPaper
{
    if (_entity) {
        _entity.creatorId    = [FlowithAgent sharedAgent].getUserIdx;
        _entity.title        = self.titleText.text;
        _entity.width        = @(1440);
        _entity.height       = @(960);
        _entity.notice       = self.noticeInput.text;
        _entity.background   = self.selectedBackgroundName;
        _entity.receive_time = [self buildRequestDate];
    }
}

- (void)syncPaperToView
{
    if (_entity) {
        _titleText.text    = _entity.title;
        _noticeInput.text  = _entity.notice;
    
        NSDate* receiveDate = [NSDate dateWithTimeIntervalSince1970:[[[NSNumberFormatter new]numberFromString:[_entity receive_time]] longLongValue] ];
        _receiveDate.text = [self dateToString:receiveDate];
        _receiveTime.text = [self timeToString:receiveDate];
        [self setSelectedBackgroundName:[_entity background]];
        [[FBRequest requestForGraphPath:[_entity friend_facebook_id]]
        startWithCompletionHandler:^(FBRequestConnection *connection, id<FBGraphUser> result, NSError *error) {
             [_receiverName setText:[result name]];
        }];
        
        [self deleteAllParticipants];
        for (User *user in [_entity participants]) {
            [self addParticipantsView:user];
        }
    }
}

- (BOOL)confirmInputs
{
    if([[_titleText text] length] <= 0){
        [[[UIAlertView alloc]initWithTitle:@"경고"
                                   message:@"제목을 입력해주세요"
                                  delegate:nil
                         cancelButtonTitle:@"확인"
                         otherButtonTitles:nil] show];
        return NO;
    }
    return YES;
}
- (IBAction)onTouchPrevious:(id)sender {
    if(self.controllerType == PAPER_CONTROLLER_TYPE_EDITING_CREATOR){
        [self syncViewToPaper];
        [_entity saveToServer:^{
            [[self navigationController] popViewControllerAnimated:YES];
        } failure:^(NSError *error) {
            [[[UIAlertView alloc] initWithTitle:@"에러"
                                        message:[error localizedDescription]
                                       delegate:nil
                              cancelButtonTitle:@"확인"
                              otherButtonTitles:nil] show];
        }];
    }
    else{
        [[self navigationController] popViewControllerAnimated:YES];
    }
}

- (IBAction)onTouchNext:(id)sender
{
    [self onTouchSend:NULL];
}

- (IBAction)onTouchSend:(id)sender
{
    if ([self confirmInputs]) {
        [self syncViewToPaper];
        [_entity saveToServer:^{
            PaperViewController* paperViewController = [[PaperViewController alloc] initWithEntity:self.entity];
            NSMutableArray *controllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
            [controllers removeLastObject];
            [controllers addObject:paperViewController];
            [[self navigationController] setViewControllers:controllers animated:YES];
        } failure:^(NSError *error) {
            [[[UIAlertView alloc] initWithTitle:@"실패"
                                        message:@"롤링페이퍼 서버에 페이퍼 만들기 요청이 실패하였습니다.\n인터넷 연결상태를 확인해주세요"
                                       delegate:nil
                              cancelButtonTitle:nil
                              otherButtonTitles:@"확인", nil] show];
        }];
    } else {
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
            } failure:^(NSError *error) {
                [[[UIAlertView alloc] initWithTitle:@"에러"
                                            message:@"서버와의 통신에 실패했습니다.\n인터넷 연결 상태를 확인해주세요"
                                           delegate:nil
                                  cancelButtonTitle:nil
                                  otherButtonTitles:@"확인", @"취소",nil] show];
            }];
       }
       else{
           NSLog(@"취소");
       }
    } cancelButtonTitle:nil
    otherButtonTitles:@"확인", @"취소",nil] show];
}
-(void) navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    if ([viewController isKindOfClass:[PaperViewController class]]) {
        [[self view] removeFromSuperview];
        [self removeFromParentViewController];
    }
}


- (IBAction)onTouchPickFriend:(id)sender
{
    _receivingFriendPicker = [[FBFriendSearchPickerController alloc] init];
    [_receivingFriendPicker setTitle:@"친구 선택"];
    [_receivingFriendPicker setDelegate:self];
    [_receivingFriendPicker setAllowsMultipleSelection:NO];
    [_receivingFriendPicker loadData];
    [_receivingFriendPicker clearSelection];
    [self presentViewController:_receivingFriendPicker
                       animated:YES
                     completion:^{}];
}

- (BOOL)friendPickerViewController:(FBFriendSearchPickerController *)friendPicker
                 shouldIncludeUser:(id<FBGraphUser>)user
{
    return [friendPicker delegateFriendPickerViewController:friendPicker
                                          shouldIncludeUser:user];
}

- (IBAction)onHideKeyboard:(id)sender {
    [[self view] endEditing:TRUE];
}

- (NSString *)dateToString:(NSDate *)date{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
                                                                   fromDate:date]; // Get necessary date components
    return [NSString stringWithFormat:@"%d-%02d-%02d",components.year,components.month,components.day];
}
- (NSString *)timeToString:(NSDate *)date{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit
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
    _invitingFreindPicker = [[FBFriendSearchPickerController alloc] init];
    [_invitingFreindPicker setTitle:@"친구 초대"];
    [_invitingFreindPicker setDelegate:self];
    [_invitingFreindPicker setAllowsMultipleSelection:YES];
    [_invitingFreindPicker loadData];
    [_invitingFreindPicker clearSelection];
    [self presentViewController:_invitingFreindPicker
                       animated:YES
                     completion:^{}];
}

- (IBAction)onTouchPickBackground:(id)sender
{
    PaperBackgroundPicker *picker = [[PaperBackgroundPicker alloc]initWithInitialBackgroundName:[self selectedBackgroundName]
                                                                                       Delegate:self];
    [self presentViewController:picker
                       animated:TRUE
                     completion:^{
                     }];
}
- (IBAction)onTouchUserList:(id)sender
{
    UserTableViewController *userTableViewController = [[UserTableViewController alloc]init];
    [[self navigationController] pushViewController:userTableViewController animated:YES];
    
    [userTableViewController setUsers:[_entity invitations]];
}

#pragma mark FacebookDate/Time handling

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
- (NSString *)buildRequestDate {
    return [NSString stringWithFormat:@"%@ %@",self.receiveDate.text,self.receiveTime.text];
}


-(void) fillReceiverDataInputsWithFacebookUser : (id<FBGraphUser>) user {
    FBRequest* request = [FBRequest requestWithGraphPath:[user id]
                                              parameters:@{@"fields":@"email,birthday,name"}
                                              HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id<FBGraphUser> result, NSError *error) {
        if ([result birthday]) {
            self.receiveDate.text = [self dateToFormatString:[self facebookBirthDayToCurrentBirthDay:[result birthday]]];
            self.receiveTime.text = @"00:00:00";
        }
    }];
    _receiverName.text = user.name;
    _entity.friend_facebook_id = user.id;
}


#pragma mark FBFriendSearchPickerControllerDelegate

- (void)facebookViewControllerDoneWasPressed : (FBFriendSearchPickerController *)sender{
    if (_controllerType == PAPER_CONTROLLER_TYPE_CREATING) {
        if (_receivingFriendPicker == sender) {
            id<FBGraphUser> user = [self.receivingFriendPicker.selection objectAtIndex:0];
            [self fillReceiverDataInputsWithFacebookUser:user];
            [self dismissViewControllerAnimated:YES completion:^{
            }];
        }
        else if (_invitingFreindPicker == sender) {
            [[User currentUser] inviteFriends:[_invitingFreindPicker selection]
            toPaper:_entity
            success:^{
                [self syncPaperToView];
                [self dismissViewControllerAnimated:YES completion:^{}];
            } failure:^(NSError *error) {
              [[[UIAlertView alloc] initWithTitle:@"에러"
                                          message:[error localizedDescription]
                                         delegate:nil
                                cancelButtonTitle:@"확인"
                                otherButtonTitles:nil] show];
            }];
        }
    } else { //방 편집모드
        if (_receivingFriendPicker == sender) {
            id<FBGraphUser> user = [self.receivingFriendPicker.selection objectAtIndex:0];
            [self fillReceiverDataInputsWithFacebookUser:user];
            [self dismissViewControllerAnimated:YES completion:^{
            }];
        } else if(_invitingFreindPicker == sender) {
            [[User currentUser] inviteFriends:[_invitingFreindPicker selection]
            toPaper:_entity
            success:^{
                [self syncPaperToView];
                [self dismissViewControllerAnimated:YES completion:^{}];
            } failure:^(NSError *error) {
                [[[UIAlertView alloc] initWithTitle:@"에러"
                                            message:[error localizedDescription]
                                           delegate:nil
                                  cancelButtonTitle:@"확인"
                                  otherButtonTitles:nil] show];
            }];
        }
    }
}
- (void)facebookViewControllerCancelWasPressed:(FBFriendSearchPickerController *)sender {
    [self dismissViewControllerAnimated:YES completion:^{}];
}


#pragma mark PaperBackgroundPickerDelegate
-(void) paperBackgroundPicker:(PaperBackgroundPicker *)picker
            didPickBackground:(NSString *)backgroundName
{
    self.selectedBackgroundName = backgroundName;
    [self dismissViewControllerAnimated:TRUE
                             completion:^{
                                 
                             }];
}
-(void) paperBackgroundPickerDidCancelPicking:(PaperBackgroundPicker *)picker
{
    [self dismissViewControllerAnimated:TRUE
                             completion:^{
                                 
                             }];
}
@end
