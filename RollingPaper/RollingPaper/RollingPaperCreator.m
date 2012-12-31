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
#import <QuartzCore/QuartzCore.h>

@interface RollingPaperCreator ()

@end

@implementation RollingPaperCreator
@synthesize titleText;
@synthesize emailInput;
@synthesize noticeInput;
@synthesize receiverName;
@synthesize fbIdLabel;
@synthesize friendPickerController;
@synthesize receiveTime;

-(void) viewDidAppear:(BOOL)animated{

    self.navigationController.navigationBarHidden = FALSE;
}
-(void) viewWillDisappear:(BOOL)animated{
    self.navigationController.navigationBarHidden = TRUE;
}
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
-(void) scrollviewAutoContentSize{
    CGFloat scrollViewHeight = 0.0f;
    for (UIView* view in self.scrollView.subviews)
    {
        if (!view.hidden)
        {
            CGFloat y = view.frame.origin.y;
            CGFloat h = view.frame.size.height;
            if (y + h > scrollViewHeight)
            {
                scrollViewHeight = h + y;
            }
        }
    }
    [self.scrollView setContentSize:(CGSizeMake(self.scrollView.frame.size.width, scrollViewHeight))];
    NSLog(@"%@",NSStringFromCGSize(self.scrollView.contentSize));
    NSLog(@"%@",self.scrollView);
    
    
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
    
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = FALSE;
 
    /*
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:gestureRecognizer];
    */
     
    [self scrollviewAutoContentSize];
    
    //self.datePicker.minimumDate = [NSDate date];
    
    //self.receiveDate.inputView = self.datePicker;
    //self.receiveTime.inputView = self.timePicker;
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
    [self setFbIdLabel :nil];
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
- (IBAction)onTouchSend:(id)sender {
    if([self confirmInputs])
    {
        @autoreleasepool {
            ASIFormDataRequest* request = [NetworkTemplate requestForCreateRollingPaperWithUserIdx : [UserInfo getUserIdx].stringValue
                                                                                             title : titleText.text
                                                                                      target_email : emailInput.text
                                                                                            notice : noticeInput.text
                                                                                      receiverFBid : fbIdLabel.text
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
        friendPickerController.title    = @"Pick Friends";
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
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* date = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
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
-(NSString*) facebookBirthdayToLocal : (NSString*) str{
    NSArray* array = [str componentsSeparatedByString:@"/"];
    return [NSString stringWithFormat:@"%@-%@-%@",[array objectAtIndex:2],[array objectAtIndex:0],[array objectAtIndex:1]];
}

-(NSString*) buildRequestDate{
    return [NSString stringWithFormat:@"%@ %@",self.receiveDate.text,self.receiveTime.text];
}
-(void) facebookViewControllerDoneWasPressed : (id)sender{
    for (id<FBGraphUser> user in friendPickerController.selection) {
        NSLog(@"%@",user);
        FBRequest* request = [FBRequest requestForGraphPath:[user id]];
        [request startWithCompletionHandler:^(FBRequestConnection *connection, id<FBGraphUser> result, NSError *error) {
             self.receiveDate.text = [self facebookBirthdayToLocal:[result birthday]];
             self.receiveTime.text = @"00:00:00";
        }];
        fbIdLabel.text = user.id;
        receiverName.text = user.name;
    }
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}
@end
