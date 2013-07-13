#import "LoginViewController.h"
#import "MainPaperViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <JSONKit.h>
#import "FlowithAgent.h"
#import "FacebookAgent.h"
#import <MBProgressHUD/MBProgressHUD.h>

@implementation LoginViewController

- (IBAction)onTouchFacebookLogin:(id)sender
{
    MBProgressHUD *view = [MBProgressHUD showHUDAddedTo:[self view] animated:YES];
    [view setMode:MBProgressHUDModeIndeterminate];
    [view setLabelText:@"Sign in..."];
    [[FacebookAgent sharedAgent] openSession:^(FBSession *session, FBSessionState status, NSError *error) {
        if (!error)
            [self onFacebookSessionActivated:session];
        else {
            [MBProgressHUD hideAllHUDsForView:[self view] animated:YES];
            [[[UIAlertView alloc] initWithTitle:@"Error"
                                        message:error.localizedDescription
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil]show];
        }
    }];
}

- (void)onFacebookSessionActivated:(FBSession *)session
{
    FBRequest* fbRequest = [FBRequest requestWithGraphPath:@"/me"
                                                parameters:@{@"fields":@"id,picture,name,birthday,email"}
                                                HTTPMethod:@"GET"];
    
    [fbRequest startWithCompletionHandler:^(FBRequestConnection *connection, id<FBGraphUser> me, NSError *error) {
        if(! error){
            [[FlowithAgent sharedAgent] joinWithFacebook:me
            accessToken:[[session accessTokenData] accessToken]
            success:^(NSDictionary *user) {
                [MBProgressHUD hideAllHUDsForView:[self view] animated:YES];
                [[FlowithAgent sharedAgent] setUserInfo:user];
                MainPaperViewController* controller = [[MainPaperViewController alloc] init];
                [[self navigationController] setViewControllers:@[controller] animated:YES];
            } failure:^(NSError *error) {
                [MBProgressHUD hideAllHUDsForView:[self view] animated:YES];
                [[[UIAlertView alloc]initWithTitle:@"에러" message:@"서버와 통신 실패" delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles: nil] show];
            }];
        } else {
            [MBProgressHUD hideAllHUDsForView:[self view] animated:YES];
            [[[UIAlertView alloc] initWithTitle : @"Error"
                                        message : error.localizedDescription
                                       delegate : nil
                              cancelButtonTitle : @"OK"
                              otherButtonTitles : nil] show];
        }
    }];
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
