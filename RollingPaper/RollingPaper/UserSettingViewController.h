#import <UIKit/UIKit.h>

@interface UserSettingViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;

- (IBAction)onTouchShowNotice:(id)sender;
- (IBAction)onTouchFeedbackButton:(id)sender;
- (IBAction)onTouchLogout:(id)sender;

@end
