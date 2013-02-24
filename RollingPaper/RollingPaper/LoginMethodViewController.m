//
//  LoginViewController.m
//  RollingPaper
//
//  Created by 이상현 on 12. 12. 21..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//


#import "LoginMethodViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "FlowithAgent.h"
#import "RollingPaperListController.h"
#import <JSONKit.h>
#import "FacebookAgent.h"
#import "SignUpController.h"
#import "SignInController.h"

@interface LoginMethodViewController ()

@end

@implementation LoginMethodViewController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onTouchFacebookLogin:(id)sender {
    [[FacebookAgent sharedAgent] openSession:^(FBSession *session, FBSessionState status, NSError *error) {
        if (!error)
            [self onFacebookSessionActivated : session];
        else {
            [[[UIAlertView alloc] initWithTitle:@"Error"
                                        message:error.localizedDescription
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil]show];
        }
    }];
}

- (IBAction)onTouchLogin:(id)sender {
    SignInController* signInController = [[SignInController alloc] initWithDefaultNib];
    [self.navigationController pushViewController:signInController
                                         animated:TRUE];
}
- (IBAction)onTouchSignUp:(id)sender {
    SignUpController* signUpController = [[SignUpController alloc] initWithDefaultNib];
    [self.navigationController pushViewController : signUpController
                                         animated : TRUE];
}
-(void) onFacebookSessionActivated : (FBSession*) session{
    FBRequest* fbRequest = [FBRequest requestWithGraphPath:@"/me"
                                                parameters:[NSDictionary dictionaryWithObjectsAndKeys:@"id,picture,name,birthday,email",@"fields",nil]
                                                HTTPMethod:@"GET"];
    
    [fbRequest startWithCompletionHandler:^(FBRequestConnection *connection,id<FBGraphUser> me,NSError *error) {
        if(! error){
            [[FlowithAgent sharedAgent] joinWithFacebook:me
                                             accessToken:session.accessToken
                success:^(NSDictionary *response) {
                    NSString* resultType = [response objectForKey:@"result"];
                    if([resultType compare:@"login"] == NSOrderedSame){
                        NSLog(@"이미 가입되어 있는 페이스북 계정임으로 자동으로 로그인 합니다");
                        NSDictionary* logiendUser= [response objectForKey:@"user"];
                        NSLog(@"%@",logiendUser);
                        [self onLoginSuccess:logiendUser];
                    }
                    else if ([resultType compare:@"fail"] == NSOrderedSame){
                        NSLog(@"이미 가입되어있는 이메일 계정입니다");
                        NSLog(@"%@",[response objectForKey:@"email"]);
                    }
                    else if ([resultType compare:@"join"] == NSOrderedSame){
                        NSLog(@"가입 성공하였습니다");
                        NSDictionary* logiendUser= [response objectForKey:@"user"];
                        NSLog(@"%@",logiendUser);
                        [self onJoinSuccess:logiendUser];
                    }
                } failure:^(NSError *error) {
                    NSLog(@"%@",error);
                    NSLog(@"%@",@"<RollingPaper 서버와 통신 실패>");
                    [[[UIAlertView alloc]initWithTitle:@"에러" message:@"서버와 통신 실패" delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles: nil] show];

                }];
        }
        else {
            [[[UIAlertView alloc] initWithTitle : @"Error"
                                        message : error.localizedDescription
                                       delegate : nil
                              cancelButtonTitle : @"OK"
                              otherButtonTitles : nil] show];
        }
    }];
}
-(void) onJoinSuccess : (NSDictionary*) userDict {
    [self onLoginSuccess:userDict];
}
-(void) onLoginSuccess : (NSDictionary*) userDict {
    [[FlowithAgent sharedAgent] setUserInfo:userDict];
    NSLog(@"%@",[[FlowithAgent sharedAgent] getUserInfo]);
    [self showPaperList];
}
- (void)showPaperList {
    RollingPaperListController* controller = [[RollingPaperListController alloc] initWithNibName:NSStringFromClass(RollingPaperListController.class)
                                                                                          bundle:NULL];
    [self.navigationController pushViewController:controller
                                         animated:TRUE];
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
