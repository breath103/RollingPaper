#import "NotificationsViewController.h"
#import "LoadingTableViewCell.h"
#import "UIView+VerticalLayout.h"
#import "User.h"
#import "NotificationCell.h"
#import "Notification.h"
#import "Invitation.h"
#import "UIAlertViewBlockDelegate.h"
#import "PaperViewController.h"

static NSString * const NotificationCellIdentifier = @"NotificationCellIdentifier";

@implementation NotificationsViewController

- (id)init
{
    self = [super init];
    if (self) {
        [self setInLoading:NO];
        [self setItems:@[]];
        [self setHasMoreItems:YES];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self tableView] registerNib:[UINib nibWithNibName:@"NotificationCell" bundle:nil]
           forCellReuseIdentifier:NotificationCellIdentifier];
    UIView *overlayWhite = [[UIView alloc]initWithFrame:CGRectMake(0, -1000, [[self tableView] getWidth], 1000)];
    UIImageView *line = [[UIImageView alloc]initWithFrame:CGRectMake(0, 1000, [[self tableView] getWidth], 3)];
    [line setImage:[UIImage imageNamed:@"alert_img_line"]];
    [overlayWhite addSubview:line];
    
    [overlayWhite setBackgroundColor:UIColorWA(255, 0.4)];
    [[self tableView] addSubview:overlayWhite];
    [[self tableView] setContentInset:UIEdgeInsetsMake(1, 0, 0, 0)];
    [[self tableView] setBackgroundView:[[UIImageView alloc]initWithImage:[UIImage  
imageNamed:@"alert_img_background"]]];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self
                       action:@selector(onPullToRefresh:)
             forControlEvents:UIControlEventValueChanged];
    [[self tableView] addSubview:_refreshControl];
    
    [self loadItems];
}

- (IBAction)onPullToRefresh:(id)sender
{
    [self loadItems];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (IBAction)onTouchBack:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)loadItems
{
    if ([self isInLoading]) return;
    [self setInLoading:YES];
    
    User *user = [User currentUser];
    [user getNotifications:^(NSArray *notifications) {
        [self setItems:notifications];
        [self setInLoading:NO];
        [_refreshControl endRefreshing];
        [[self tableView] reloadData];
        
        
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    } failure:^(NSError *error) {
        [self setInLoading:NO];
        [_refreshControl endRefreshing];
        [[self tableView] reloadData];
    }];
}

#pragma UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    float yOffset = offset.y + bounds.size.height - inset.bottom;
    float height = size.height;
    float tolerance = bounds.size.height * 2.0f;
    if (yOffset > height - tolerance) {
        [self loadItems];
    }
}


#pragma UITableViewController override
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    if(_inLoading)
        return 2;
    else
        return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0: return [_items count];
        case 1: return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1){
        return [[LoadingTableViewCell alloc]initWithFrame:CGRectMake(0, 0, [tableView getWidth], 32.0f)];
    } else {
        Notification *notification = [self items][indexPath.row];
        NotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:NotificationCellIdentifier forIndexPath:indexPath];
        [cell setNotification:notification];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    Notification *item = [self items][indexPath.row];
    if ([[item notificationType] isEqualToString:@"invitation_received"]) {
        [[[UIAlertViewBlock alloc]initWithTitle:@"확인"
        message:@"초대를 수락하시겠습니까?"
        blockDelegate:^(UIAlertView *alertView, int clickedButtonIndex) {
            Invitation *invitation = [[Invitation alloc]init];
            [invitation setId:[item sourceId]];
            if(clickedButtonIndex == 0) {
                [invitation accept:^{
                    RollingPaper *paper = [[RollingPaper alloc]init];
                    [paper setId:[item sourceId]];
                    PaperViewController *paperViewController = [[PaperViewController alloc]initWithEntity:paper];
                    
                    NSMutableArray *viewControllers =
                    [[NSMutableArray alloc]initWithArray:[[self navigationController] viewControllers]];
                    [viewControllers removeLastObject];
                    [viewControllers addObject:paperViewController];
                    
                    [[self navigationController] setViewControllers:viewControllers animated:YES];
                    
                    NSLog(@"accepted");
                } failure:^(NSError *error) {
                    NSLog(@"%@",error);
                }];
            } else if(clickedButtonIndex == 1) {
                [invitation reject:^{
                    NSLog(@"rejected");
                } failure:^(NSError *error) {
                    NSLog(@"%@",error);
                }];
            }
        } cancelButtonTitle:@"수락"
        otherButtonTitles:@"거절", nil] show];
    } else {
        
    }
}

#pragma mark NotifcationCellDelegate
- (void)notificationCell:(NotificationCell *)cell
       touchDetailButton:(UIButton *)button
{
    
}

@end
