#import <UIKit/UIKit.h>

@interface SignInController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *emailInput;
@property (weak, nonatomic) IBOutlet UITextField *passwordInput;
- (IBAction)onTouchSignIn:(id)sender;

@end
