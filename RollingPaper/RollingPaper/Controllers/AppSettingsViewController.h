#import <UIKit/UIKit.h>

@interface AppSettingsViewController : UIViewController
@property (nonatomic, weak) IBOutlet UIImageView *profileImageView;
@property (nonatomic, weak) IBOutlet UILabel *usernameLabel;
@property (nonatomic, weak) IBOutlet UISwitch *notificiationSwithView;

- (IBAction)onTouchBackButton:(id)sender;
- (IBAction)onTouchLogout:(id)sender;
@end
