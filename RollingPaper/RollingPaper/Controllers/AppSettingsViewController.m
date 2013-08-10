#import "AppSettingsViewController.h"
#import "User.h"
#import "UIImageView+Vingle.h"
#import <FacebookSDK/FacebookSDK.h>
#import "LoginViewController.h"

@implementation AppSettingsViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    User *user = [User currentUser];
    [_profileImageView setImageWithURL:[user picture] withFadeIn:0.1f];
    [_usernameLabel setText:[user username]];
}
- (IBAction)onTouchBackButton:(id)sender
{
    [[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction)onTouchLogout:(id)sender
{
    [[FBSession activeSession] closeAndClearTokenInformation];
    [[self navigationController] setViewControllers:@[  [[LoginViewController alloc]init] ]
                                           animated:YES];
}
@end
