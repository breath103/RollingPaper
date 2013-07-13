#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
@class RollingPaper;

@interface PaperSettingsViewController : UIViewController
@property (nonatomic, strong) RollingPaper *paper;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *containerView;

@property (nonatomic, strong) id<FBGraphUser> recipient;
@property (weak, nonatomic) IBOutlet UITextField *recipientNameField;
@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UITextField *noticeField;

@property (nonatomic, strong) NSString *background;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

- (id)initWithPaper:(RollingPaper *)paper;
- (void)setRecipient:(id<FBGraphUser>)recipient;

@end
