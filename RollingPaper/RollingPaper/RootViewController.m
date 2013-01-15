//
//  ViewController.m
//  RollingPaper
//
//  Created by 이상현 on 12. 10. 27..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import "RootViewController.h"
#import "ASI/ASIFormDataRequest.h"
#import "ASI/ASIProgressDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import "SBJSON/SBJSON.h"
#import "UserInfo.h"
#import "NetworkTemplate.h"
#import <math.h>
#import "RollingPaperCreator.h"
#import "RollingPaperListController.h"
#import "BlockSupport/NSObject+block.h"
#import "PaperViewController.h"
#import "macro.h"
#import "LoginMethodViewController.h"


@interface RootViewController ()

@end

@implementation RootViewController
@synthesize loadingImageView;
@synthesize paperPlaneView;
@synthesize paperImageView;
- (void)viewDidLoad
{
    [super viewDidLoad];
}
- (void)viewDidAppear:(BOOL)animated
{
    [UIView animateWithDuration:1
                          delay:1
                        options:0
                     animations:^{
            UIViewSetOrigin(paperPlaneView, CGPointMake(-134,347));
            paperPlaneView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            paperPlaneView.hidden = TRUE;
            
            if([UserInfo getUserInfo]){
                NSLog(@"다음 아이디로 이미 로그인 된 상태 : %@",[UserInfo getUserInfo]);
                [self onTouchLoginWithFacebook];
            }
            else {
                NSLog(@"아직 로그인 안됨");
                LoginMethodViewController* loginViewController = [[LoginMethodViewController alloc] initWithNibName:NSStringFromClass(LoginMethodViewController.class)
                                                                                                 bundle:NULL];
                [self.navigationController pushViewController:loginViewController animated:TRUE];
            }
        }];    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (void)showPaperList {
    RollingPaperListController* controller = [[RollingPaperListController alloc] initWithNibName:@"RollingPaperListController" bundle:NULL];
    [self.navigationController pushViewController:controller animated:TRUE];
}
- (void)onTouchLoginWithFacebook {
    if ( !FBSession.activeSession.isOpen) {
        NSArray* permissions = [NSArray arrayWithObjects:@"user_photos",@"publish_stream",@"publish_actions",@"email",
                                                         @"user_likes",@"user_birthday",@"user_education_history",
                                                         @"user_hometown",@"read_stream",@"user_about_me",
                                                         @"read_friendlists",@"offline_access", nil];
        [FBSession openActiveSessionWithPermissions : permissions
                                       allowLoginUI : YES
                                  completionHandler : ^(FBSession *session, FBSessionState status, NSError *error) {
                                      NSLog(@"%@",session.accessToken);
                                      if (!error){
                                          [self onLoginSuccess:[UserInfo getUserInfo]];
                                      }else {
                                          [[[UIAlertView alloc] initWithTitle:@"Error"
                                                                      message:error.localizedDescription
                                                                     delegate:nil
                                                            cancelButtonTitle:@"OK"
                                                            otherButtonTitles:nil]show];
                                      }
                                  }];
    }
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
                 SBJsonParser* parser = [[SBJsonParser alloc] init];
                 NSDictionary* response = [parser objectWithString:request.responseString];
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
- (void)viewDidUnload {
    self.loadingImageView = NULL;
    self.paperPlaneView   = NULL;
    self.paperImageView   = NULL;
    [super viewDidUnload];
}

-(BOOL)shouldAutorotate
{
    return YES;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}
@end
