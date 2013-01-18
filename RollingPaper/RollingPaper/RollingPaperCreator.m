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
-(void) initScrollView{
    [self.scrollView addSubview:self.contentContainer];
    self.scrollView.contentSize = self.contentContainer.frame.size;
    /*
    for(int i=0;i<5;i++){
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(58 * i, 409.5,46,46);
        button.layer.cornerRadius = 2.5;
        button.layer.shadowColor = [UIColor blackColor].CGColor;
        button.layer.shouldRasterize = TRUE;
        button.layer.shadowRadius = 1.0f;
        button.layer.shadowOpacity = 1.0f;
        button.layer.rasterizationScale = [UIScreen mainScreen].scale;
        button.backgroundColor = [UIColor brownColor];
        
        [self.scrollView addSubview:button];
    }
    */
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
    
    self.datePicker.minimumDate = [NSDate date];
   
    self.receiveDate.inputView = self.datePicker;
    self.receiveTime.inputView = self.timePicker;
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
                                                                                      receieveTime : [self buildRequestDate]];
            [request setCompletionBlock:^{
                NSLog(@"%@",request.responseString);
                [self performBlockInMainThread:^{
                    [self.navigationController popViewControllerAnimated:TRUE];
                } waitUntilDone:TRUE];
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

- (IBAction)onPickDate:(UIDatePicker *)sender {
    NSDateComponents* date = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
                                                             fromDate:sender.date]; // Get necessary date components
    self.receiveDate.text = [NSString stringWithFormat:@"%d-%02d-%02d",date.year,date.month,date.day];
    NSLog(@"%@",self.receiveDate);
}
-(IBAction)onPickTime:(UIDatePicker *)sender{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* date = [calendar components:NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit
                                         fromDate:sender.date]; // Get necessary date components
    self.receiveTime.text = [NSString stringWithFormat:@"%02d:%02d:%02d",date.hour,date.minute,date.second];
    NSLog(@"%@",self.receiveTime);
    
}
- (IBAction)onTouchReceiveDate:(id)sender {
    
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
@end
