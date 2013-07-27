#import "PaperSettingsViewController.h"
#import "RollingPaper.h"
#import "UIImageView+Vingle.h"
#import "PaperBackgroundPicker.h"

@implementation PaperSettingsViewController

- (id)initWithPaper:(RollingPaper *)paper
{
    self = [super init];
    if(self){
        _paper = paper;
    }
    return self;
}

- (void)setRecipient:(id<FBGraphUser>)recipient
{
    _recipient = recipient;
    [_recipientNameField setText:[recipient name]];
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

- (void)setPaper:(RollingPaper *)paper
{
    _paper = paper;
//    id<FBGraphUser> user = @{@"id": paper.friend_facebook_id,@"name" : paper.recipient_name};
//    [self setRecipient:user];
    [_recipientNameField setText:[paper recipient_name]];
    [_titleField setText:[paper title]];
    [_noticeField setText:[paper notice]];

    [self setBackground:[paper background]];
    [self setReceiveTime:[paper receive_time]];
}

- (void)hideKeyboard
{
    [[self view] endEditing:YES];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [_scrollView addSubview:_containerView];
    [_scrollView setContentSize:[_containerView frame].size];
    if (_paper)
        [self setPaper:_paper];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self
                                                                                       action:@selector(hideKeyboard)];
    [_containerView addGestureRecognizer:gestureRecognizer];
}

- (IBAction)onTouchSave:(id)sender {
    [_paper setTitle:[_titleField text]];
    [_paper setNotice:[_noticeField text]];
    
    [_paper setBackground:[self background]];
    [_paper setReceive_time:[self receiveTime]];
    
    [_paper saveToServer:^{
        [[self navigationController] popViewControllerAnimated:YES];
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
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
