//
//  LoginViewController.m
//  RollingPaper
//
//  Created by 이상현 on 12. 12. 21..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//


#import "LoginMethodViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "NetworkTemplate.h"
#import "UserInfo.h"
#import "RollingPaperListController.h"
#import <JSONKit.h>

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
    if ( !FBSession.activeSession.isOpen) {
        NSArray* permissions = [NSArray arrayWithObjects:@"user_photos",@"publish_stream",@"publish_actions",@"email",@"user_likes",@"user_birthday",@"user_education_history",@"user_hometown",@"read_stream",@"user_about_me",@"read_friendlists",@"offline_access", nil];
        [FBSession openActiveSessionWithPermissions : permissions
                                       allowLoginUI : YES
                                  completionHandler : ^(FBSession *session, FBSessionState status, NSError *error) {
                                      NSLog(@"%@",session.accessToken);
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
}

- (IBAction)onTouchLogin:(id)sender {
}
-(void) onFacebookSessionActivated : (FBSession*) session{
    FBRequest* fbRequest = [FBRequest requestWithGraphPath:@"/me"
                                                parameters:[NSDictionary dictionaryWithObjectsAndKeys:@"id,picture,name,birthday,email",@"fields",nil]
                                                HTTPMethod:@"GET"];
    
    [fbRequest startWithCompletionHandler:^(FBRequestConnection *connection,id<FBGraphUser> me,NSError *error) {
        if(! error){
            ASIFormDataRequest* request = [NetworkTemplate requestForFacebookJoinWithMe:me
                                                                            accessToken:session.accessToken];
            [request setCompletionBlock:^{
                NSDictionary* response = [request.responseString objectFromJSONString];
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
            }];
            [request setFailedBlock:^{
                NSLog(@"%@",@"<RollingPaper 서버와 통신 실패>");
            }];
            [request startAsynchronous];
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
    [UserInfo setUserInfo:userDict];
    NSLog(@"%@",[UserInfo getUserInfo]);
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
