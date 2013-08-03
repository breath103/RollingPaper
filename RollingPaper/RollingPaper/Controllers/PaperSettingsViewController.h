#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "PaperBackgroundPicker.h"
#import "FBFriendSearchPickerController.h"
@class RollingPaper;

@interface PaperSettingsViewController : UIViewController<PaperBackgroundPickerDelegate,FBFriendPickerDelegate,
                                                           UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) RollingPaper *paper;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *containerView;

@property (nonatomic, strong) id<FBGraphUser> recipient;
@property (weak, nonatomic) IBOutlet UITextField *recipientNameField;
@property (weak, nonatomic) IBOutlet UIButton *recipientPickerButton;
@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UITextField *noticeField;

@property (nonatomic, strong) NSString *receiveTime;
@property (weak, nonatomic) IBOutlet UITextField *receiveDateField;
@property (weak, nonatomic) IBOutlet UITextField *receiveTimeField;

@property (weak, nonatomic) IBOutlet UIButton *inviteFriendButton;
@property (weak, nonatomic) IBOutlet UITableView *participantsTableView;
@property (weak, nonatomic) IBOutlet UIButton *showParticipantsButton;

@property (weak, nonatomic) IBOutlet UIView *bottomContainer;
@property (nonatomic, strong) NSString *background;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *backgroundPickerButton;

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *timePicker;
@property (weak, nonatomic) IBOutlet UIButton *exitButton;

@property (nonatomic, strong) FBFriendSearchPickerController *invitePicker;
@property (nonatomic, strong) FBFriendSearchPickerController *recipientPicker;
@property (nonatomic, strong) NSArray *friendList;

- (id)initWithPaper:(RollingPaper *)paper;

- (FBFriendSearchPickerController *)invitePicker;
- (FBFriendSearchPickerController *)recipientPicker;

- (IBAction)onTouchBack:(id)sender;
- (IBAction)onTouchDone:(id)sender;

- (IBAction)onTouchPickRecipient:(id)sender;
- (IBAction)onPickDate:(UIDatePicker *)sender;
- (IBAction)onPickTime:(UIDatePicker *)sender;
- (IBAction)onTouchInviteFriend:(id)sender;
- (IBAction)onTouchShowParticipantsList:(id)sender;
- (IBAction)onTouchBackgroundButton:(id)sender;
- (IBAction)onTouchQuit:(id)sender;

@end
