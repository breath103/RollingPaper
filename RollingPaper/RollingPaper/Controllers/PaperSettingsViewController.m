#import "PaperSettingsViewController.h"
#import "RollingPaper.h"
#import "UIImageView+Vingle.h"
#import "PaperBackgroundPicker.h"
#import "FBFriendSearchPickerController.h"
#import "PaperParticipantsListController.h"
#import "User.h"
#import "UIImageView+Vingle.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <QuartzCore/QuartzCore.h>


@interface PaperSettingsViewController()
@end

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
    
    [_receiveDateField setInputView:_datePicker];
    [_receiveTimeField setInputView:_timePicker];

    _datePicker.timeZone = _timePicker.timeZone = [NSTimeZone localTimeZone];
    [_datePicker setTop:[[self view] getHeight]];
    [_timePicker setTop:[[self view] getHeight]];

    [_datePicker setMinimumDate:[NSDate date]];
    [_datePicker setMaximumDate:nil];
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self
                                                                                       action:@selector(hideKeyboard)];
    [_containerView addGestureRecognizer:gestureRecognizer];
    [[self view] setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"background_pattern"]]];
    
    
    UIImage* mask_image = [UIImage imageNamed:@"paper_cell_bg"];
    CGSize size = _backgroundImageView.frame.size;
    CALayer* maskLayer = [CALayer layer];
    maskLayer.frame = CGRectMake(0,0,size.width,size.height);
    maskLayer.contents = (__bridge id)[mask_image CGImage];
    _backgroundImageView.layer.mask = maskLayer;
    [_backgroundImageView setNeedsDisplay];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES];
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
        [self setFriendList:[paper participants]];

        [_exitButton setHidden:NO];
    
        if ([[[User currentUser] id] isEqualToNumber:[paper creatorId]]) {
            [_backgroundPickerButton setEnabled:YES];
        } else {
            [_recipientPickerButton setEnabled:NO];
            [_recipientNameField setEnabled:NO];
            [_titleField setEnabled:NO];
            [_noticeField setEnabled:NO];
            [_receiveDateField setEnabled:NO];
            [_receiveTimeField setEnabled:NO];
            [_backgroundPickerButton setEnabled:NO];
        }
    } else {
        [_showParticipantsButton setHidden:YES];
        [_exitButton setHidden:YES];
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
    } failure:^(NSError *error) {}];
}

- (void)setReceiveTime:(NSString *)receiveTime
{
    NSDate *date = [[receiveTime toUTCDate] UTCTimeToLocalTime];
    NSString *dateString = [date description];
    [_receiveDateField setText:[dateString componentsSeparatedByString:@" "][0]];
    [_receiveTimeField setText:[dateString componentsSeparatedByString:@" "][1]];
    
    [_datePicker setDate:[receiveTime toUTCDate]];
    [_timePicker setDate:[receiveTime toUTCDate]];
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

- (FBFriendSearchPickerController *)invitePicker
{
    if (!_invitePicker) {
        _invitePicker = [[FBFriendSearchPickerController alloc] init];
        [_invitePicker setTitle:@"친구 초대"];
        [_invitePicker setDelegate:self];
        [_invitePicker setAllowsMultipleSelection:YES];
        [_invitePicker loadData];
        [_invitePicker clearSelection];
    }
    return _invitePicker;
}
- (FBFriendSearchPickerController *)recipientPicker
{
    if (!_recipientPicker) {
        _recipientPicker = [[FBFriendSearchPickerController alloc] init];
        [_recipientPicker setTitle:@"친구 선택"];
        [_recipientPicker setDelegate:self];
        [_recipientPicker setAllowsMultipleSelection:NO];
        [_recipientPicker loadData];
        [_recipientPicker clearSelection];
    }
    return _recipientPicker;
}

- (IBAction)onTouchBack:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction)onTouchDone:(id)sender {
    if (![_paper id]) {
        [_paper setCreatorId:[[User currentUser] id]];
        [_paper setWidth:@(1440)];
        [_paper setHeight:@(960)];
    }
    [_paper setTitle:[_titleField text]];
    [_paper setNotice:[_noticeField text]];
    [_paper setBackground:[self background]];
    [_paper setReceive_time:[self receiveTime]];
    [_paper setRecipient:[self recipient]];
    
    NSString *errorMessage = [_paper validate];
    if (!errorMessage) {
        MBProgressHUD *view = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [_paper saveToServer:^{
            if([[_invitePicker selection] count] > 0) {
                [[User currentUser] inviteFriends:[_invitePicker selection]
                toPaper:_paper success:^{
                    [view hide:YES];
                    [[self navigationController] popViewControllerAnimated:YES];
                } failure:^(NSError *error) {
                    [view hide:YES];
                    [[[UIAlertView alloc]initWithTitle:@"에러"
                                               message:@"친구 초대실패"
                                              delegate:nil
                                     cancelButtonTitle:@"확인"
                                     otherButtonTitles:nil] show];
                }];
            } else {
                [view hide:YES];
                [[self navigationController] popViewControllerAnimated:YES];
            }
        } failure:^(NSError *error) {
            [view hide:YES];
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

- (IBAction)onTouchPickRecipient:(id)sender {
    [self presentViewController:[self recipientPicker]
                       animated:YES
                     completion:^{}];
}

- (IBAction)onPickDate:(UIDatePicker *)sender
{
    NSDate *date = [sender date];
    [_receiveDateField setText:[[date description] componentsSeparatedByString:@" "][0]];
}

- (IBAction)onPickTime:(UIDatePicker *)sender
{
    NSDate *date = [[sender date] UTCTimeToLocalTime]; 
    [_receiveTimeField setText:[[date description] componentsSeparatedByString:@" "][1]];
}

- (IBAction)onTouchInviteFriend:(id)sender {
    [self presentViewController:[self invitePicker] animated:YES completion:^{
        
    }];
}

- (IBAction)onTouchShowParticipantsList:(id)sender
{
    PaperParticipantsListController *controller = [[PaperParticipantsListController alloc]initWithPaper:_paper];
    [[self navigationController]pushViewController:controller animated:YES];
}

- (IBAction)onTouchQuit:(id)sender
{
    if ([_paper id])
    {
        MBProgressHUD *view = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[User currentUser] quitPaper:_paper
        success:^{
            [view hide:YES];
            [[self navigationController] popViewControllerAnimated:YES];
        }
        failure:^(NSError *error){
            [view hide:YES];
            [[[UIAlertView alloc]initWithTitle:@"에러"
            message:@"네트워크 상태를 확인해주세요"
            delegate:nil cancelButtonTitle:@"확인"
            otherButtonTitles: nil] show];
        }];
    }
}

- (IBAction)onTouchBackgroundButton:(id)sender {
    PaperBackgroundPicker *picker = [[PaperBackgroundPicker alloc] initWithInitialBackgroundName:[self background]
                                                                                        delegate:self];
    [self presentViewController:picker animated:YES completion:^{}];
}

#pragma mark PaperBackgroundPickerDelegate
- (void)paperBackgroundPicker:(PaperBackgroundPicker *)picker
            didPickBackground:(NSString *)backgroundName
{
    [self setBackground:backgroundName];
    [self dismissViewControllerAnimated:YES completion:^{ }];
}
- (void)paperBackgroundPickerDidCancelPicking:(PaperBackgroundPicker *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{ }];
}

#pragma mark FBFirendPickerDelegate
- (void)facebookViewControllerDoneWasPressed:(FBFriendSearchPickerController *)sender
{
    if (sender == _recipientPicker) {
        if([[_recipientPicker selection] count] > 0){
            [self setRecipient:[_recipientPicker selection][0]];
        }
    } else if (sender == _invitePicker) {
        if ([_paper id]) {
            MBProgressHUD *view = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            if([[_invitePicker selection] count] > 0) {
                [[User currentUser] inviteFriends:[_invitePicker selection]
                toPaper:_paper success:^{
                    _invitePicker = nil;
                    [view hide:YES];
                    [[[UIAlertView alloc]initWithTitle:nil
                    message:@"초대 되었습니다!\n 초대하신 친구들은 친구 목록에서 확인할 수 있습니다"
                                              delegate:nil
                                     cancelButtonTitle:@"확인"
                                     otherButtonTitles:nil] show];
                } failure:^(NSError *error) {
                    [view hide:YES];
                    [[[UIAlertView alloc]initWithTitle:@"에러"
                                             message:@"친구 초대실패"
                                            delegate:nil
                                   cancelButtonTitle:@"확인"
                                   otherButtonTitles:nil] show];
                }];
            }
        } else {
            [self setFriendList:[sender selection]];
        }
    }
    [self dismissViewControllerAnimated:YES completion:^{}];
}
- (void)facebookViewControllerCancelWasPressed:(FBFriendSearchPickerController *)sender
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark UITableViewDelegate,UITableViewDataSource
- (void)setFriendList:(NSArray *)friendList
{
    _friendList = friendList;
    [_participantsTableView reloadData];
    [_participantsTableView setHeight:[self tableView:nil
                                      numberOfRowsInSection:0] * 44];
    [_showParticipantsButton setTopBelow:_participantsTableView];
    [_bottomContainer setTopBelow:_showParticipantsButton margin:20];
    [_scrollView setContentSize:CGSizeMake([[self view] getWidth], [_bottomContainer getBottom])];
}
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([_paper id])
        return MIN([[self friendList] count],3);
    else
        return [[self friendList] count];
}

// TODO SPEC
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"UserCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    id data = [self friendList][indexPath.row];
    UIImageView *backgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"setting_img_textbox_middle"]];
    backgroundView.contentMode = UIViewContentModeScaleToFill;
    [backgroundView setWidth:[cell getWidth]];
    [cell setBackgroundView:backgroundView];
    [cell setBackgroundColor:[UIColor clearColor]];
    [[cell textLabel] setBackgroundColor:[UIColor clearColor]];
    if ([data isMemberOfClass:[User class]]) {
        User * user = data;
        cell.textLabel.text = [user username];
        [[cell imageView] setImageWithURL:[user picture] withFadeIn:0.1f];
    } else if ([data isKindOfClass:[NSDictionary class]]) {
        cell.textLabel.text = data[@"name"];
        [[cell imageView] setImageWithURL:data[@"picture"][@"data"][@"url"]
                               withFadeIn:0.1f];
    }
    return cell;
}
@end
