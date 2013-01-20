//
//  RollingPaperCreatorController.m
//  RollingPaper
//
//  Created by 이상현 on 12. 11. 17..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import "RollingPaperCreator.h"
#import "NetworkTemplate.h"
#import "UserInfo.h"
#import "NSObject+block.h"
#import "UserInfo.h"
#import <QuartzCore/QuartzCore.h>
#import "PaperViewController.h"
#import "UECoreData.h"

@interface RollingPaperCreator ()

@end

@implementation RollingPaperCreator
@synthesize titleText;
@synthesize emailInput;
@synthesize noticeInput;
@synthesize receiverName;
@synthesize friendPickerController;
@synthesize receiveTime;
@synthesize contentContainer;
@synthesize receiverFacebookID;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}


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
-(void) createBackgroundButton : (NSString*) background {
    
}
-(void) initScrollView{
    [self.scrollView addSubview:self.contentContainer];
    self.scrollView.contentSize = self.contentContainer.frame.size;
    
    ASIHTTPRequest* request = [NetworkTemplate requestForPaperBackgroundImageList];
    [request setCompletionBlock:^{
        NSArray* backgroundList = [parseJSON(request.responseString) objectForKey:@"backgrounds"];
        
        int i = 0;
        
        CGSize buttonSize = CGSizeMake(44, 44);
        int buttonRow = 5;
        int buttonColl = 1;
        float widthOffset = (self.paperBackgroundsScroll.frame.size.width - buttonSize.width * buttonRow) / (buttonRow+1);
        float heightOffset = (self.paperBackgroundsScroll.frame.size.height - buttonSize.height * buttonColl) / (buttonColl + 1);
        for(NSString* background in backgroundList)
        {
            ^(int i){
                [NetworkTemplate getBackgroundImage:background
                                        withHandler:^(UIImage *image) {
                                            UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
                                            button.frame = CGRectMake(widthOffset + (widthOffset+buttonSize.width) * i , heightOffset ,
                                                                      buttonSize.width , buttonSize.height);
                                            [button setTitle:background
                                                    forState:UIControlStateDisabled];
                                            button.layer.cornerRadius = 4;
                                            button.layer.shadowColor = [UIColor blackColor].CGColor;
                                            button.layer.shouldRasterize = TRUE;
                                            button.layer.shadowRadius = 1.0f;
                                            button.layer.shadowOpacity = 0.5;
                                            button.layer.shadowOffset  = CGSizeMake(3,3);
                                            button.layer.rasterizationScale = [UIScreen mainScreen].scale;
                                            button.backgroundColor = [UIColor colorWithPatternImage:image];
                                            [button addTarget:self
                                                       action:@selector(onBackgroundButtonTouched:)
                                             forControlEvents:UIControlEventTouchUpInside];
                                            
                                            [self.paperBackgroundsScroll addSubview:button];
                                            
                                            if(i == 0){
                                                [self onBackgroundButtonTouched:button];
                                            }
                                        }];    
            }(i);
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
                   [[button titleForState:UIControlStateDisabled] compare:self.entity.background] == NSOrderedSame)
                {
                    [self onBackgroundButtonTouched:button];
                    break;
                }
            }
        }
    }];
    [request setFailedBlock:^{
        NSLog(@"%@",request);
    }];
    [request startAsynchronous];
}
- (void)onBackgroundButtonTouched : (UIButton*) sender{
    self.paperCellImage.image = NULL;//image;
    self.selectedBackgroundButton = sender;
    [UIView animateWithDuration:0.2f animations:^{
        self.paperCellImage.backgroundColor = sender.backgroundColor;///[UIColor colorWithPatternImage:[sender imageForState:UIControlStateDisabled]];
    } completion:^(BOOL finished) {
        
    }];
}
- (void)syncPaperToView{
    if(self.entity){
        self.receiverName.text = self.entity.receiver_name;
        self.titleText.text = self.entity.title;
        self.noticeInput.text = self.entity.notice;
    
        NSDate* receiveDate = [NSDate dateWithTimeIntervalSince1970: [[NSNumberFormatter new]numberFromString:self.entity.receive_time].longLongValue ];
        self.receiveDate.text = [self dateToString:receiveDate];
        self.receiveTime.text = [self timeToString:receiveDate];
        self.emailInput.text = self.entity.target_email;
        
    }
}
- (void)addNewParticipants{
    float height = 33;
    CGSize contentSize = self.scrollView.contentSize;
    contentSize.height += height;
    self.scrollView.contentSize = contentSize;
    
    UIViewSetY(self.bottomViewsContainer, self.bottomViewsContainer.frame.origin.y + height);
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                        action:@selector(hideKeyboard)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:gestureRecognizer];
    
    [[NetworkTemplate requestForSearchingFacebookFriendUsingRollingPaper:[UserInfo getUserIdx].stringValue] startAsynchronous];
    
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
    
    
    [self addNewParticipants];
    [self addNewParticipants];
    [self addNewParticipants];
}

- (id) initForCreating{
    self = [self initWithDefaultNib];
    if(self){
        self.controllerType = PAPER_CONTROLLER_TYPE_CREATING;
        self.entity = NULL;
    }
    return self;
}
- (id) initForEditing : (RollingPaper*) aEntity{
    self = [self initWithDefaultNib];
    if(self){
        self.entity = aEntity;
        if([[UserInfo getUserIdx] compare:self.entity.creator_idx] == NSOrderedSame)
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
    [self.navigationController popViewControllerAnimated:TRUE];
}

- (IBAction)onTouchNext:(id)sender {
    [self onTouchSend:NULL];
}

- (IBAction)onTouchSend:(id)sender {
    if([self confirmInputs])
    {
        @autoreleasepool {
            ASIFormDataRequest* request = [NetworkTemplate requestForCreateRollingPaperWithUserIdx : [UserInfo getUserIdx].stringValue
                                                                                             title : titleText.text
                                                                                      target_email : emailInput.text
                                                                                            notice : noticeInput.text
                                                                                      receiverFBid : receiverFacebookID
                                                                                      receiverName : receiverName.text
                                                                                      receieveTime : [self buildRequestDate]
                                                                                        background : [self.selectedBackgroundButton titleForState:UIControlStateDisabled]];
            [request setCompletionBlock:^{
                
                NSDictionary* result = parseJSON(request.responseString);
                
                if([result objectForKey:@"error"])
                {
                    [[[UIAlertView alloc] initWithTitle:@"실패"
                                                message:[NSString stringWithFormat: @"롤링페이퍼 서버에 페이퍼 만들기 요청이 실패하였습니다.\n%@",[result objectForKey:@"error"]]
                                               delegate:nil
                                      cancelButtonTitle:nil
                                      otherButtonTitles:@"확인", nil] show];
                }
                else{
                    [self performBlockInMainThread:^{
                        
                        //서버로 부터 새로 만들어진 페이퍼의 엔티티 정보를 받아와서 이를 가지고 엔티티를 만들고,
                        RollingPaper* entity = (RollingPaper*)[[UECoreData sharedInstance] insertNewObject : @"RollingPaper"
                                                                                                  initWith : parseJSON(request.responseString)];
                        entity.is_new = [NSNumber numberWithBool:YES];
                        NSLog(@"%@",entity);
                        
                        //편집 뷰를 만든다음
                        PaperViewController* paperViewController = [[PaperViewController alloc] initWithEntity:entity];
                        
                        self.navigationController.delegate = self;
                        [self.navigationController pushViewController : paperViewController
                                                             animated : TRUE];
                        
                        if(self.listController)
                            [self.listController refreshPaperList];
                        
                    } waitUntilDone:TRUE];
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
        }
    }
    else{
        NSLog(@"입력폼에 문제가 있음");
    }
}
-(IBAction)onTouchQuit:(UIButton*)sender{
    [[[UIAlertView alloc] initWithTitle:@"경고"
                                message:@"이 종이에서 나가시겠습니까?"
                               delegate:self
                      cancelButtonTitle:nil
                      otherButtonTitles:@"확인", @"취소",nil] show];
}
-(void) alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 0)
    {
        NSLog(@"방 삭제");
        ASIFormDataRequest* request = [ NetworkTemplate requestForQuitRoomWithUserIdx : [UserInfo getUserIdx].stringValue
                                                                                paper : self.entity.idx.stringValue];
        [request setCompletionBlock:^{
            NSLog(@"%@",request.responseString);
            [self.navigationController popViewControllerAnimated:TRUE];
            if(self.listController)
               [self.listController refreshPaperList];
        }];
        [request setFailedBlock:^{
            [[[UIAlertView alloc] initWithTitle:@"에러"
                                        message:@"서버와의 통신에 실패했습니다.\n인터넷 연결 상태를 확인해주세요"
                                       delegate:self
                              cancelButtonTitle:nil
                              otherButtonTitles:@"확인", @"취소",nil] show];
        }];
        [request startAsynchronous];
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
    if(!friendPickerController){
        friendPickerController = [[FBFriendSearchPickerController alloc] init];
        friendPickerController.title    = @"친구 선택";
        friendPickerController.delegate = self;
        friendPickerController.allowsMultipleSelection = FALSE;
        
        [friendPickerController loadData];
        [friendPickerController clearSelection];
    }
    [self presentViewController:friendPickerController
                       animated:YES
                     completion:^{}];
}
- (BOOL)friendPickerViewController:(FBFriendPickerViewController *)friendPicker
                 shouldIncludeUser:(id<FBGraphUser>)user{
    return [friendPickerController delegateFriendPickerViewController:friendPicker
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
        friendPickerController = [[FBFriendSearchPickerController alloc] init];
        friendPickerController.title    = @"친구 선택";
        friendPickerController.delegate = self;
        friendPickerController.allowsMultipleSelection = TRUE;
        
        [friendPickerController loadData];
        [friendPickerController clearSelection];
    //}
    [self presentViewController:friendPickerController
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
-(void) facebookViewControllerCancelWasPressed:(id)sender{
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}
-(void) facebookViewControllerDoneWasPressed : (id)sender{
    for (id<FBGraphUser> user in friendPickerController.selection) {
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
-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;// | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}
@end
