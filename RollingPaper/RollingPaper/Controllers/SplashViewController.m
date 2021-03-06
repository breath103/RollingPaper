#import "SplashViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "FlowithAgent.h"
#import <math.h>
#import "RollingPaperCreator.h"
#import "MainPaperViewController.h"
#import "PaperViewController.h"
#import "LoginViewController.h"


@interface SplashViewController ()

@end

@implementation SplashViewController
@synthesize loadingImageView;
@synthesize paperPlaneView;
@synthesize paperImageView;
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden =YES;
    
    UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nextArrow"]];
    imageView.frame = CGRectMake(0, 0, 32/2, 39/2);
    UIBarButtonItem* nextButton = [[UIBarButtonItem alloc] initWithCustomView:imageView];
    self.navigationItem.rightBarButtonItem = nextButton;
}
- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
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
            paperPlaneView.hidden = YES;
            if (!FBSession.activeSession.isOpen){
                LoginViewController* loginViewController = [[LoginViewController alloc]init];
                [[self navigationController] setViewControllers:@[loginViewController]
                                                       animated:YES];
            } else {
            
            }
        }];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (void)showPaperList {
    MainPaperViewController* controller = [[MainPaperViewController alloc] init];
    [self.navigationController setViewControllers:@[controller] animated:YES];
}
- (void)onTouchLoginWithFacebook {
    if ( !FBSession.activeSession.isOpen) {
        NSArray* permissions = @[@"user_photos",@"publish_stream",@"publish_actions",@"email",
                                 @"user_likes",@"user_birthday",@"user_education_history",
                                 @"user_hometown",@"read_stream",@"user_about_me",
                                 @"read_friendlists",@"offline_access"];
        [FBSession openActiveSessionWithPermissions:permissions
        allowLoginUI : YES
        completionHandler : ^(FBSession *session, FBSessionState status, NSError *error) {
            if (!error){
                [self onLoginSuccess:[[FlowithAgent sharedAgent] getUserInfo]];
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
                                parameters:@{@"fields":@"id,picture,name,birthday,email"}
                                                HTTPMethod:@"GET"];
    [fbRequest startWithCompletionHandler:^(FBRequestConnection *connection,id<FBGraphUser> me,NSError *error)
    {
        if(! error){
            [[FlowithAgent sharedAgent] joinWithFacebook:me
            accessToken:[[session accessTokenData] accessToken]
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
    [self showPaperList];
}
- (void)viewDidUnload {
    self.loadingImageView = NULL;
    self.paperPlaneView   = NULL;
    self.paperImageView   = NULL;
    [super viewDidUnload];
}

#pragma rotation
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
