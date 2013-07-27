#import "PaperSettingsViewController.h"
#import "RollingPaper.h"
#import "UIImageView+Vingle.h"
#import "PaperBackgroundPicker.h"
#import "FBFriendSearchPickerController.h"

@implementation PaperSettingsViewController

- (id)init
{
    self = [super init];
    if (self) {
        if (!_paper) {
            _paper = [[RollingPaper alloc]init];
        }
    }
    return self;
}
- (id)initWithPaper:(RollingPaper *)paper
{
    self = [super init];
    if(self){
        _paper = paper;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_scrollView addSubview:_containerView];
    [_scrollView setContentSize:[_containerView frame].size];
    [self setPaper:_paper];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self
                                                                                       action:@selector(hideKeyboard)];
    [_containerView addGestureRecognizer:gestureRecognizer];
}

- (void)setPaper:(RollingPaper *)paper
{
    _paper = paper;
    if ([paper id]) {
        [self setRecipient:(id)[paper recipientDictionary]];
        [_titleField setText:[paper title]];
        [_noticeField setText:[paper notice]];
        
        [self setBackground:[paper background]];
        [self setReceiveTime:[paper receive_time]];
    } else {
        
    }
}

- (void)setRecipient:(id<FBGraphUser>)recipient
{
    _recipient = recipient;
    [_recipientNameField setText:recipient[@"name"]];
}

- (void)setBackground:(NSString *)background
{
    _background = background;
    [_backgroundImageView setImageWithURL:background
                               withFadeIn:0.1f
                                  success:^(BOOL isCached, UIImage *image) {
                                      [_backgroundImageView setImage:nil];
                                      [_backgroundImageView setBackgroundColor:[UIColor colorWithPatternImage:image]];
                                  } failure:^(NSError *error) {
                                      
                                  }];
}

- (void)setReceiveTime:(NSString *)receiveTime
{
    NSDate *date = [[receiveTime toUTCDate] UTCTimeToLocalTime];
    NSString *dateString = [date description];
    [_receiveDateField setText:[dateString componentsSeparatedByString:@" "][0]];
    [_receiveTimeField setText:[dateString componentsSeparatedByString:@" "][1]];
}
- (NSString *)receiveTime
{
    NSString* time = [NSString stringWithFormat:@"%@ %@",[_receiveDateField text],[_receiveTimeField text]];
    NSDate * date = [[time toUTCDate] LocalTimeToUTCTime];
    return [date description];
}

- (void)hideKeyboard
{
    [[self view] endEditing:YES];
}

- (FBFriendSearchPickerController *)recipientPicker
{
    FBFriendSearchPickerController *recipientPicker = [[FBFriendSearchPickerController alloc] init];
    [recipientPicker setTitle:@"친구 선택"];
    [recipientPicker setDelegate:self];
    [recipientPicker setAllowsMultipleSelection:NO];
    [recipientPicker loadData];
    [recipientPicker clearSelection];
    return recipientPicker;
}

- (IBAction)onTouchPickRecipient:(id)sender {
    [self presentViewController:[self recipientPicker]
                       animated:YES
                     completion:^{}];
}

- (IBAction)onTouchSave:(id)sender
{
    [_paper setTitle:[_titleField text]];
    [_paper setNotice:[_noticeField text]];
    [_paper setBackground:[self background]];
    [_paper setReceive_time:[self receiveTime]];
    [_paper setRecipient:[self recipient]];
    
    NSString *errorMessage = [_paper validate];
    if (!errorMessage) {
        [_paper saveToServer:^{
            [[self navigationController] popViewControllerAnimated:YES];
        } failure:^(NSError *error) {
            NSLog(@"%@",error);
            [[[UIAlertView alloc]initWithTitle:@"에러"
                                       message:@"입력되지 않은 정보가 있습니다. 마져 채워주세요."
                                      delegate:nil
                             cancelButtonTitle:@"확인"
                             otherButtonTitles: nil] show];
        }];
    } else {
        [[[UIAlertView alloc]initWithTitle:nil message:@"입력되지 않은 정보가 있습니다. 마져 채워주세요" delegate:nil cancelButtonTitle:@"확인" otherButtonTitles: nil] show];
    }
}

- (IBAction)onTouchBackgroundButton:(id)sender {
    PaperBackgroundPicker *picker = [[PaperBackgroundPicker alloc] initWithInitialBackgroundName:[self background]
                                                                                        Delegate:self];
    [self presentViewController:picker animated:YES completion:^{
        
    }];
}

- (void)paperBackgroundPicker:(PaperBackgroundPicker *)picker didPickBackground:(NSString *)backgroundName
{
    [self setBackground:backgroundName];
    [self dismissViewControllerAnimated:YES completion:^{ }];
}
- (void)paperBackgroundPickerDidCancelPicking:(PaperBackgroundPicker *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{ }];
}

@end
