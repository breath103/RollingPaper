 #import "NotificationsViewController.h"
#import "LoadingTableViewCell.h"
#import "UIView+VerticalLayout.h"
#import "User.h"
#import "NotificationCell.h"
#import "Notification.h"
#import "Invitation.h"
#import "UIAlertViewBlockDelegate.h"

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
    [self loadItems];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [[self navigationController] setNavigationBarHidden:YES];
}

- (void)loadItems
{
    if ([self isInLoading]) return;
    [self setInLoading:YES];
    User *user = [User currentUser];
    [user getNotifications:^(NSArray *notifications) {
        [self setItems:notifications];
        [self setInLoading:NO];
        [[self tableView] reloadData];
    } failure:^(NSError *error) {
        [self setInLoading:NO];
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

//- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (indexPath.section == 1){
//        return 32.0f;
//    }
//    return 0;
//}

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
    Notification *item = [self items][indexPath.row];
    if ([[item notificationType] isEqualToString:@"invitation_received"]) {
        [[[UIAlertViewBlock alloc]initWithTitle:@"확인"
        message:@"초대를 수락하시겠습니까?"
        blockDelegate:^(UIAlertView *alertView, int clickedButtonIndex) {
            Invitation *invitation = [[Invitation alloc]init];
            [invitation setId:[item sourceId]];
            if(clickedButtonIndex == 0) {
                [invitation accept:^{
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

@end
