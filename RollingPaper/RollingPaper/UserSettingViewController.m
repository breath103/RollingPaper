//
//  UserSettingViewController.m
//  RollingPaper
//
//  Created by 이상현 on 12. 12. 22..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import "UserSettingViewController.h"
#import "FlowithAgent.h"
#import "NoticeTableController.h"

@interface UserSettingViewController ()

@end

@implementation UserSettingViewController
@synthesize userImageView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[FlowithAgent sharedAgent] getProfileImage:^(BOOL isCachedResponse, UIImage *image) {
        self.userImageView.image = image;
    }];
    // Do any additional setup after loading the view from its nib.
}
-(void) viewDidAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = FALSE;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setUserImageView:nil];
    [super viewDidUnload];
}
- (IBAction)onTouchShowNotice:(id)sender {
    NoticeTableController* noticeTableController = [[NoticeTableController alloc] initWithDefaultNib];
    [self.navigationController pushViewController:noticeTableController
                                         animated:TRUE];
}

- (IBAction)onTouchFeedbackButton:(id)sender {
    [TestFlight openFeedbackView];
}

- (IBAction)onTouchLogout:(id)sender {
    [[FlowithAgent sharedAgent] setUserInfo:NULL];
    [self.navigationController popToRootViewControllerAnimated:TRUE];
    
}
@end
