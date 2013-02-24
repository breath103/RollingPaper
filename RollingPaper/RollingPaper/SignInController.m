#import "SignInController.h"
#import "FlowithAgent.h"
#import "RollingPaperListController.h"
#import "UIAlertViewBlockDelegate.h"

@interface SignInController ()

@end

@implementation SignInController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    // Do any additional setup after loading the view from its nib.
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:tapGesture];
}
-(void) viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:FALSE animated:TRUE];
}

-(void) hideKeyboard{
    [self.view endEditing:TRUE];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)showPaperList {
    RollingPaperListController* controller = [[RollingPaperListController alloc] initWithDefaultNib];
    [self.navigationController pushViewController:controller
                                         animated:TRUE];
}
- (IBAction)onTouchSignIn:(id)sender {
    [[FlowithAgent sharedAgent] loginWithEmail:self.emailInput.text
                                      password:self.passwordInput.text
                                       success:^(User *user) {
                                           [[FlowithAgent sharedAgent] setCurrentUser:user];
                                           [self showPaperList];
                                       } failure:^(NSError *error) {
                                           [[[UIAlertViewBlock alloc] initWithTitle:@"에러"
                                                                            message:error.description
                                                                      blockDelegate:^(UIAlertView *alertView, int clickedButtonIndex) {
                                                                          if(clickedButtonIndex == 1){
                                                                              [self onTouchSignIn:NULL];
                                                                          }
                                                                      }
                                                                  cancelButtonTitle:@"확인"
                                                                  otherButtonTitles:@"재시도", nil]show];
                                       }];
}
@end
