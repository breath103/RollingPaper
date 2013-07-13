#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "PaperBackgroundPicker.h"
@class RollingPaper;

@interface PaperSettingsViewController : UIViewController<PaperBackgroundPickerDelegate>
@property (nonatomic, strong) RollingPaper *paper;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *containerView;

@property (nonatomic, strong) id<FBGraphUser> recipient;
@property (weak, nonatomic) IBOutlet UITextField *recipientNameField;
@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UITextField *noticeField;

@property (nonatomic, strong) NSString *receiveTime;
@property (weak, nonatomic) IBOutlet UITextField *receiveDateField;
@property (weak, nonatomic) IBOutlet UITextField *receiveTimeField;

@property (nonatomic, strong) NSString *background;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
- (IBAction)onTouchBackgroundButton:(id)sender;

- (id)initWithPaper:(RollingPaper *)paper;
- (IBAction)onTouchSave:(id)sender;

@end