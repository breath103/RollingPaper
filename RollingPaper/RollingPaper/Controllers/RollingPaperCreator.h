#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "RollingPaper.h"
#import "FBFriendSearchPickerController.h"
#import "MainPaperViewController.h"
#import "PaperBackgroundPicker.h"
#import "PaperParticipantsListController.h"


typedef enum ROLLING_PAPER_CONTROLLER_STYLE{
    PAPER_CONTROLLER_TYPE_CREATING,
    PAPER_CONTROLLER_TYPE_EDITING_CREATOR,
    PAPER_CONTROLLER_TYPE_EDITING_PARTICIPANTS
} ROLLING_PAPER_CONTROLLER_STYLE;



@interface RollingPaperCreator : UIViewController<FBFriendPickerDelegate,
                                                  UIAlertViewDelegate,
                                                  UISearchBarDelegate,
                                                  PaperBackgroundPickerDelegate>

@property (weak, nonatomic) IBOutlet UIView* contentContainer;
@property (weak, nonatomic) IBOutlet UITextField *titleText;
@property (weak, nonatomic) IBOutlet UITextField *emailInput;
@property (weak, nonatomic) IBOutlet UITextField *noticeInput;
@property (weak, nonatomic) IBOutlet UITextField *receiverName;
@property (weak, nonatomic) IBOutlet UITextField *receiveDate;
@property (weak, nonatomic) IBOutlet UITextField *receiveTime;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *timePicker;
@property (nonatomic,weak) IBOutlet UIScrollView* scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *paperCellImage;
@property (nonatomic,strong) NSString *selectedBackgroundName;
@property (nonatomic,readwrite) ROLLING_PAPER_CONTROLLER_STYLE controllerType;
@property (nonatomic,strong) RollingPaper* entity;
@property (weak, nonatomic) IBOutlet UIButton *finishButton;
@property (weak, nonatomic) IBOutlet UIView *bottomViewsContainer;
@property (weak, nonatomic) IBOutlet UIView *participantsContainer;
@property (nonatomic,strong) FBFriendSearchPickerController* receivingFriendPicker;
@property (nonatomic,strong) FBFriendSearchPickerController* invitingFreindPicker;
@property (nonatomic,strong) PaperParticipantsListController* participantsListController;
- (id) initForCreating;
- (id) initForEditing : (RollingPaper*) entity;


- (IBAction)onTouchPrevious:(id)sender;
- (IBAction)onTouchNext:(id)sender;
- (IBAction)onTouchSend:(id)sender;
- (IBAction)onTouchPickFriend:(id)sender;
- (IBAction)onHideKeyboard:(id)sender;
- (IBAction)onPickDate:(UIDatePicker *)sender;
- (IBAction)onPickTime:(UIDatePicker *)sender;
- (IBAction)onTouchReceiveDate:(id)sender;
- (IBAction)onTouchInvite:(id)sender;
- (IBAction)onTouchUserList:(id)sender;
- (IBAction)onTouchPickBackground:(id)sender;

@end
