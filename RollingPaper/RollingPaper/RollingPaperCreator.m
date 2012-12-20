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


@interface RollingPaperCreator ()

@end

@implementation RollingPaperCreator
@synthesize titleText;
@synthesize emailInput;
@synthesize noticeInput;
@synthesize receiverName;
@synthesize receiveTime;
@synthesize fbIdLabel;
@synthesize friendPickerController;

@synthesize searchBar;
@synthesize searchText;

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
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = FALSE;
 
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:gestureRecognizer];
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
    [super viewDidUnload];
}
- (IBAction)onTouchSend:(id)sender {
    @autoreleasepool {
        ASIFormDataRequest* request = [NetworkTemplate requestForCreateRollingPaperWithUserIdx : [UserInfo getUserIdx]
                                                                                         title : titleText.text
                                                                                  target_email : emailInput.text
                                                                                        notice : noticeInput.text
                                                                                  receiverFBid : fbIdLabel.text
                                                                                  receiverName : receiverName.text
                                                                                  receieveTime : receiveTime.text];
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
                 shouldIncludeUser:(id<FBGraphUser>)user
{
    return [friendPickerController delegateFriendPickerViewController:friendPicker
                                                    shouldIncludeUser:user];
}
- (IBAction)onHideKeyboard:(id)sender {
    [self.view endEditing:TRUE];
}
-(void) facebookViewControllerDoneWasPressed : (id)sender{
    for (id<FBGraphUser> user in friendPickerController.selection) {
        NSLog(@"%@",user);
        fbIdLabel.text = user.id;
        receiverName.text = user.name;
    }
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}
@end
