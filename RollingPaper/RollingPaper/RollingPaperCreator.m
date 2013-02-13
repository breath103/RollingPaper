//
//  RollingPaperCreatorController.m
//  RollingPaper
//
//  Created by 이상현 on 12. 11. 17..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import "RollingPaperCreator.h"
#import "FlowithAgent.h"
#import "NSObject+block.h"
#import <QuartzCore/QuartzCore.h>
#import "PaperViewController.h"
#import "UECoreData.h"
#import "UELib/UEImageLibrary.h"
#import <JSONKit.h>
#import "FlowithAgent.h"

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
-(void) initPaperCellPreview{
    UIImage* mask_image = [ UIImage imageNamed:@"paper_cell_bg"];
    CGSize size = self.paperCellImage.frame.size;
    CALayer* maskLayer = [CALayer layer];
    maskLayer.frame = CGRectMake(0,0,size.width,size.height);
    maskLayer.contents = (__bridge id)[mask_image CGImage];
    self.paperCellImage.layer.mask = maskLayer;
    [self.paperCellImage setNeedsDisplay];
}
-(void) _addButtonShadow : (UIButton*) button{
    button.layer.cornerRadius = 4;
    button.layer.shadowColor = [UIColor blackColor].CGColor;
    button.layer.shouldRasterize = TRUE;
    button.layer.shadowRadius = 1.0f;
    button.layer.shadowOpacity = 0.5;
    button.layer.shadowOffset  = CGSizeMake(3,3);
    button.layer.rasterizationScale = [UIScreen mainScreen].scale;
}
-(void) initScrollView{
    [self.scrollView addSubview:self.contentContainer];
    self.scrollView.contentSize = self.contentContainer.frame.size;
    [[FlowithAgent sharedAgent] getBackgroundList:^(BOOL isCaschedResponse,
                                                    NSArray *backgroundList){
        int i = 0;
        CGSize buttonSize = CGSizeMake(44, 44);
        int buttonRow = 5;
        int buttonColl = 1;
        float widthOffset = (self.paperBackgroundsScroll.frame.size.width - buttonSize.width * buttonRow) / (buttonRow+1);
        float heightOffset = (self.paperBackgroundsScroll.frame.size.height - buttonSize.height * buttonColl) / (buttonColl + 1);
        for(NSString* background in backgroundList)
        {
            [[FlowithAgent sharedAgent]getBackground:background
                                            response:^(BOOL isCachedResponse, UIImage *image){
                                                UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
                                                button.frame = CGRectMake(widthOffset + (widthOffset+buttonSize.width) * i , heightOffset ,
                                                                          buttonSize.width , buttonSize.height);
                                                [button setTitle:background
                                                        forState:UIControlStateDisabled];
                                                [self _addButtonShadow:button];
                                                button.backgroundColor = [UIColor colorWithPatternImage:image];
                                                [button addTarget:self
                                                           action:@selector(onBackgroundButtonTouched:)
                                                 forControlEvents:UIControlEventTouchUpInside];
                                                
                                                [self.paperBackgroundsScroll addSubview:button];
                                                if(i == 0){
                                                    [self onBackgroundButtonTouched:button];
                                                }
                                            }];
            
            i++;
        }
        CGSize contentSize = self.paperBackgroundsScroll.contentSize;
        contentSize.width = (buttonSize.width + widthOffset) * backgroundList.count + widthOffset;
        contentSize.height = self.paperBackgroundsScroll.frame.size.height;
        self.paperBackgroundsScroll.contentSize = contentSize;
        NSLog(@"%@",self.paperBackgroundsScroll);
        
        
        if(self.controllerType !=PAPER_CONTROLLER_TYPE_CREATING){
            for(UIButton* button in self.paperBackgroundsScroll.subviews){
                if([button isKindOfClass:UIButton.class] &&
                   [[button titleForState:UIControlStateDisabled] compare:self.entity.background] == NSOrderedSame){
                    [self onBackgroundButtonTouched:button];
                    break;
                }
            }
        }
    }failure:^(NSError *error) {
        [[[UIAlertView alloc]initWithTitle:@"경고"
                                   message:@"서버로부터 종이 배경들을 받아오는대 실패했습니다"
                                  delegate:NULL
                         cancelButtonTitle:@"확인"
                         otherButtonTitles:NULL, nil] show];

    }];
}
- (void)onBackgroundButtonTouched : (UIButton*) sender{
    self.paperCellImage.image = NULL;//image;
    self.selectedBackgroundButton = sender;
    [UIView animateWithDuration:0.2f animations:^{
        self.paperCellImage.backgroundColor = sender.backgroundColor;
    } completion:^(BOOL finished) {
        
    }];
}
- (void)deleteAllParticipants{
    for(UIView* view in self.participantsContainer.subviews){
        if(view != [self.participantsContainer.subviews objectAtIndex:0])
            [view removeFromSuperview];
    }
}
- (void)createNewParticipnatsCell : (NSDictionary<FBGraphUser>*) user{
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
    [[FlowithAgent sharedAgent] getImageFromURL:profileURL
                                        success:^(BOOL isCachedResponse, UIImage *image) {
                                            profileView.image = image;
                                            [profileView setNeedsDisplay];
                                        }];
    
    UIViewSetHeight(self.participantsContainer,
                    self.participantsContainer.subviews.count * buttonSize.height);
    UIViewSetY([self.participantsContainer.subviews objectAtIndex:0],
               (self.participantsContainer.subviews.count-1) * buttonSize.height);
    
    float delta = buttonSize.height * self.participantsContainer.subviews.count;
    
    CGSize contentSize = self.scrollView.contentSize;
    contentSize.height = 748 + delta;
    self.scrollView.contentSize = contentSize;
    UIViewSetHeight(self.contentContainer, 748 + delta);
    UIViewSetY(self.bottomViewsContainer, 486+delta);
}
- (void)addParticipantsView : (NSDictionary*) participant{
    CGSize buttonSize = CGSizeMake(270, 37);
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    if( (self.participantsContainer.subviews.count-1) == 0)
        [button setBackgroundImage:[UIImage imageNamed:@"userlist_top"] forState:UIControlStateNormal];
    else
        [button setBackgroundImage:[UIImage imageNamed:@"userlist_center"] forState:UIControlStateNormal];
    
    button.frame = CGRectMake(0, buttonSize.height * (self.participantsContainer.subviews.count-1),
                              buttonSize.width, buttonSize.height);
    [button setTitle:[participant objectForKey:@"name"] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    UIImageView* profileView = [[UIImageView alloc] initWithImage:NULL];
    profileView.frame = CGRectMake(12.5, 10, 19, 19);
    [button addSubview:profileView];
    [self.participantsContainer addSubview:button];
   
    [[FlowithAgent sharedAgent] getImageFromURL:[participant objectForKey:@"picture"]
                                        success:^(BOOL isCachedResponse, UIImage *image) {
                                            profileView.image = image;
                                            [profileView setNeedsDisplay];
                                        }];
    
    UIViewSetHeight(self.participantsContainer,
                    self.participantsContainer.subviews.count * buttonSize.height);
    UIViewSetY([self.participantsContainer.subviews objectAtIndex:0],
               (self.participantsContainer.subviews.count-1) * buttonSize.height);
    
    float delta = buttonSize.height * self.participantsContainer.subviews.count;
    
    CGSize contentSize = self.scrollView.contentSize;
    contentSize.height = 748 + delta;
    self.scrollView.contentSize = contentSize;
    UIViewSetHeight(self.contentContainer, 748 + delta);
    UIViewSetY(self.bottomViewsContainer, 486+delta);
}
- (void)syncViewToPaper{
    if(self.entity){
        NSLog(@"%@",self.entity);
        self.entity.title          = self.titleText.text;
        self.entity.notice         = self.noticeInput.text;
        self.entity.target_email   = self.emailInput.text;
        self.entity.receiver_name  = self.receiverName.text;
        self.entity.receiver_fb_id = self.receiverFacebookID;
        self.entity.receive_tel    = @"";
        self.entity.receive_time   = [self buildRequestDate];
        self.entity.background     = [self.selectedBackgroundButton titleForState:UIControlStateDisabled];
        self.entity.width          = [NSNumber numberWithInt:1440];
        self.entity.height         = [NSNumber numberWithInt:960];
        
        NSLog(@"%@",self.entity);
        
    }
}
- (void)syncPaperToView{
    if(self.entity){
        self.receiverName.text = self.entity.receiver_name;
        self.titleText.text    = self.entity.title;
        self.noticeInput.text  = self.entity.notice;
    
        NSDate* receiveDate = [NSDate dateWithTimeIntervalSince1970: [[NSNumberFormatter new]numberFromString:self.entity.receive_time].longLongValue ];
        self.receiveDate.text = [self dateToString:receiveDate];
        self.receiveTime.text = [self timeToString:receiveDate];
        self.emailInput.text  = self.entity.target_email;
     
        [[FlowithAgent sharedAgent] getPaperParticipants:self.entity
            success:^(BOOL isCachedResponse, NSArray *participants) {
                [self deleteAllParticipants];
                for(NSDictionary* user in participants){
                    [self addParticipantsView:user];
                }
            } failure:^(NSError *error) {
                NSLog(@"%@",error);
            }];
        
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
    
    self.datePicker.minimumDate = [NSDate date];
    self.receiveDate.inputView = self.datePicker;
    self.receiveTime.inputView = self.timePicker;
    
    
    
    NSLog(@"%@",self.entity);
    switch (self.controllerType) {
        case PAPER_CONTROLLER_TYPE_CREATING:{
            self.titleLabel.text = @"RollingPaper 만들기";
            [self.finishButton setTitle:@"완료" forState:UIControlStateNormal];
            [self.finishButton addTarget:self
                                  action:@selector(onTouchSend:)
                        forControlEvents:UIControlEventTouchUpInside];
        }break;
        case PAPER_CONTROLLER_TYPE_EDITING_CREATOR:{
            [self syncPaperToView];
            self.titleLabel.text = @"RollingPaper 편집";
            [self.finishButton setTitle:@"지우기" forState:UIControlStateNormal];
            [self.finishButton addTarget:self
                                  action:@selector(onTouchQuit:)
                        forControlEvents:UIControlEventTouchUpInside];
        }break;
        case PAPER_CONTROLLER_TYPE_EDITING_PARTICIPANTS:{
            [self syncPaperToView];
            self.titleLabel.text = @"RollingPaper 편집";
            [self.finishButton setTitle:@"나가기" forState:UIControlStateNormal];
            [self.finishButton addTarget:self
                                  action:@selector(onTouchQuit:)
                        forControlEvents:UIControlEventTouchUpInside];
        }break;
        default:
            break;
    }
}

- (id) initForCreating{
    self = [self initWithDefaultNib];
    if(self){
        self.controllerType = PAPER_CONTROLLER_TYPE_CREATING;
        self.entity = (RollingPaper*)[[UECoreData sharedInstance] insertNewObject : @"RollingPaper"];
    }
    return self;
}
- (id) initForEditing : (RollingPaper*) aEntity{
    self = [self initWithDefaultNib];
    if(self){
        self.entity = aEntity;
        if([[[FlowithAgent sharedAgent] getUserIdx] compare:self.entity.creator_idx] == NSOrderedSame)
        {
            self.controllerType = PAPER_CONTROLLER_TYPE_EDITING_CREATOR;
        }
        else{
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
              NSLog(@"%@",paper);
              self.entity = paper;
              [self.listController refreshPaperList];
              [self.navigationController popViewControllerAnimated:TRUE];
        } failure:^(NSError *error) {
            NSLog(@"%@",error);
            [[[UIAlertView alloc] initWithTitle:@"에러" message:@"서버와 통신 실패" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles: nil] show];
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
    if([self confirmInputs])
    {
        [self syncViewToPaper];
        [[FlowithAgent sharedAgent] createPaper:self.entity
                                        success:^(RollingPaper *createdPaper) {
                                            NSLog(@"%@",createdPaper);
                                            
                                            self.entity = createdPaper;
                                            if(self.invitingFreindPicker &&
                                               self.invitingFreindPicker.selection.count > 0){
                                                
                                                /*
                                                NSMutableArray* facebook_friends = [NSMutableArray new];
                                                for (id<FBGraphUser> user in self.invitingFreindPicker.selection) [facebook_friends addObject: [user id]];
                                                ASIFormDataRequest* request = [NetworkTemplate requestForInviteFacebookFriends:facebook_friends
                                                                                                                       ToPaper:[createdEntity objectForKey:@"idx"]
                                                                                                                      withUser:[[FlowithAgent sharedAgent] getUserIdx].stringValue];
                                                [request setCompletionBlock:^{
                                                    NSLog(@"%@",request.responseString);
                                                    [self createPaperRequestSuccess : createdEntity];
                                                }];
                                                [request startAsynchronous];
                                                 */
                                            }
                                            else{
                                            }
                                            [self createPaperRequestSuccess];
                                        }failure:^(NSError *error) {
                                            NSLog(@"%@",error);
                                            [[[UIAlertView alloc] initWithTitle:@"실패"
                                                                        message:@"롤링페이퍼 서버에 페이퍼 만들기 요청이 실패하였습니다.\n인터넷 연결상태를 확인해주세요"
                                                                       delegate:nil
                                                              cancelButtonTitle:nil
                                                              otherButtonTitles:@"확인", nil] show];
                                        }];
            /*
            ASIFormDataRequest* request = [NetworkTemplate requestForCreateRollingPaperWithUserIdx : [[FlowithAgent sharedAgent] getUserIdx].stringValue
                                                                                             title : titleText.text
                                                                                      target_email : emailInput.text
                                                                                            notice : noticeInput.text
                                                                                      receiverFBid : receiverFacebookID
                                                                                      receiverName : receiverName.text
                                                                                      receieveTime : [self buildRequestDate]
                                                                                        background : [self.selectedBackgroundButton titleForState:UIControlStateDisabled]];
            [request setCompletionBlock:^{
                NSDictionary* createdEntity = parseJSON(request.responseString);
                if([createdEntity objectForKey:@"error"])
                {
                    [[[UIAlertView alloc] initWithTitle:@"실패"
                                                message:[NSString stringWithFormat: @"롤링페이퍼 서버에 페이퍼 만들기 요청이 실패하였습니다.\n%@",[createdEntity objectForKey:@"error"]]
                                               delegate:nil
                                      cancelButtonTitle:nil
                                      otherButtonTitles:@"확인", nil] show];
                }
                else{
                    NSLog(@"%@",createdEntity);
                    if(self.invitingFreindPicker &&
                       self.invitingFreindPicker.selection.count > 0){
                        NSMutableArray* facebook_friends = [NSMutableArray new];
                        for (id<FBGraphUser> user in self.invitingFreindPicker.selection) [facebook_friends addObject: [user id]];
                        ASIFormDataRequest* request = [NetworkTemplate requestForInviteFacebookFriends:facebook_friends
                                                                                               ToPaper:[createdEntity objectForKey:@"idx"]
                                                                                              withUser:[[FlowithAgent sharedAgent] getUserIdx].stringValue];
                        [request setCompletionBlock:^{
                            NSLog(@"%@",request.responseString);
                            [self createPaperRequestSuccess : createdEntity];
                        }];
                        [request startAsynchronous];
                    }
                    else{
                        [self createPaperRequestSuccess : createdEntity];
                    }
                }
            }];
            [request setFailedBlock:^{
                NSLog(@"%@",@"fail");
                [[[UIAlertView alloc] initWithTitle:@"실패"
                                            message:@"롤링페이퍼 서버에 페이퍼 만들기 요청이 실패하였습니다.\n인터넷 연결상태를 확인해주세요"
                                           delegate:nil
                                  cancelButtonTitle:nil
                                  otherButtonTitles:@"확인", nil] show];
            }];
            [request startAsynchronous];
             */
    }
    else{
        NSLog(@"입력폼에 문제가 있음");
    }
}
-(IBAction)onTouchQuit:(UIButton*)sender{
    [[[UIAlertView alloc] initWithTitle:@"경고"
                                message:@"이 롤링페이퍼를 지우시겠습니까?"
                               delegate:self
                      cancelButtonTitle:nil
                      otherButtonTitles:@"확인", @"취소",nil] show];
}
-(void) alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 0)
    {
        [[FlowithAgent sharedAgent] quitPaper:self.entity
          success:^{
            [self.navigationController popViewControllerAnimated:TRUE];
            if(self.listController)
                [self.listController refreshPaperList];
        } failure:^(NSError *error) {
            [[[UIAlertView alloc] initWithTitle:@"에러"
                                        message:@"서버와의 통신에 실패했습니다.\n인터넷 연결 상태를 확인해주세요"
                                       delegate:self
                              cancelButtonTitle:nil
                              otherButtonTitles:@"확인", @"취소",nil] show];
            NSLog(@"%@",error);
        }];
    }
    else{
        NSLog(@"취소");
    }
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
- (BOOL)friendPickerViewController:(FBFriendSearchPickerController*)friendPicker
                 shouldIncludeUser:(id<FBGraphUser>)user{
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

- (IBAction)onTouchInvite:(id)sender {
    //if(!friendPickerController){
    self.invitingFreindPicker = [[FBFriendSearchPickerController alloc] init];
    self.invitingFreindPicker.title    = @"친구 선택";
    self.invitingFreindPicker.delegate = self;
    self.invitingFreindPicker.allowsMultipleSelection = TRUE;
    [self.invitingFreindPicker  loadData];
    [self.invitingFreindPicker clearSelection];
    //}
    [self presentViewController:self.invitingFreindPicker 
                       animated:YES
                     completion:^{}];
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
-(void) facebookViewControllerDoneWasPressed : (FBFriendSearchPickerController*)sender{
    if(self.controllerType == PAPER_CONTROLLER_TYPE_CREATING)
    {
        if(self.receivingFriendPicker == sender){
            for (id<FBGraphUser> user in self.receivingFriendPicker.selection) {
                FBRequest* request = [FBRequest requestForGraphPath:[user id]];
                [request startWithCompletionHandler:^(FBRequestConnection *connection, id<FBGraphUser> result, NSError *error) {
                    NSLog(@"%@",result);
                    if([result birthday]){
                        self.receiveDate.text = [self dateToFormatString:[self facebookBirthDayToCurrentBirthDay:[result birthday]]];
                        self.receiveTime.text = @"00:00:00";
                    }
                    else{
                        
                    }
                }];
                self.receiverFacebookID = user.id;
                receiverName.text = user.name;
            }
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
            for (id<FBGraphUser> user in self.receivingFriendPicker.selection) {
                FBRequest* request = [FBRequest requestForGraphPath:[user id]];
                [request startWithCompletionHandler:^(FBRequestConnection *connection, id<FBGraphUser> result, NSError *error) {
                    NSLog(@"%@",result);
                    if([result birthday]){
                        self.receiveDate.text = [self dateToFormatString:[self facebookBirthDayToCurrentBirthDay:[result birthday]]];
                        self.receiveTime.text = @"00:00:00";
                    }
                    else{
                        
                    }
                }];
                self.receiverFacebookID = user.id;
                receiverName.text = user.name;
            }
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
        else if(self.invitingFreindPicker == sender){
            //방 만들기 모드에서 같이 만들 친구 초대할때
            NSMutableArray* facebook_friends = [NSMutableArray new];
            for (id<FBGraphUser> user in self.invitingFreindPicker.selection)
                [facebook_friends addObject: [user id]];
            /*
            ASIFormDataRequest* request = [NetworkTemplate requestForInviteFacebookFriends:facebook_friends
                                                                                   ToPaper:self.entity.idx.stringValue
                                                                                  withUser:[[FlowithAgent sharedAgent] getUserIdx].stringValue];
            [request setCompletionBlock:^{
                NSLog(@"%@",request.responseString);
                [self syncPaperToView];
                [self dismissViewControllerAnimated:YES completion:^{
                    
                }];
            }];
            [request setFailedBlock:^{
                NSLog(@"%@",request);
            }];
            [request startAsynchronous];
             */
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
