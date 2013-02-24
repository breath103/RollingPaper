#import "SignUpController.h"

#import "FlowithAgent.h"
#import "User.h"
#import "UIAlertViewBlockDelegate.h"

@interface SignUpController ()

@end

@implementation SignUpController

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
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:tapGesture];
    
}
-(void) hideKeyboard{
    [self.view endEditing:TRUE];
}
-(void) viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:FALSE animated:TRUE];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL) checkInputs {
    return TRUE;
}
- (IBAction)onTouchSignUp:(id)sender {
    if([self checkInputs]){
        User* user = [[User alloc] init];
        [user setName:self.nameInput.text];
        [user setEmail:self.emailInput.text];
        [[FlowithAgent sharedAgent] joinWithUser:user
        password:self.passwordInput.text
        success:^(User *user) {
            
        } failure:^(NSError *error) {
            [[[UIAlertViewBlock alloc] initWithTitle:@"에러"
                                             message:error.domain
                                       blockDelegate:^(UIAlertView *alertView, int clickedButtonIndex) {
                                           if(clickedButtonIndex == 1){
                                               [self onTouchSignUp:NULL];
                                           }
                                       }
                                   cancelButtonTitle:@"확인"
                                   otherButtonTitles:@"재시도", nil]show];
        }];
    }
}
@end
