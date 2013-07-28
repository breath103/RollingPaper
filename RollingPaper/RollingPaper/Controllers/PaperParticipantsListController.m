#import "PaperParticipantsListController.h"
#import "FlowithAgent.h"
#import "User.h"
#import "Invitation.h"
#import "UIImageView+Vingle.h"
#import "RollingPaper.h"

@implementation PaperParticipantsListController

-(id) initWithPaper:(RollingPaper*) paper{
    self = [self init];
    if(self){
        _paper = paper;
        self.paper = paper;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(_paper){
        [_paper getParticipants:^(NSArray *participants) {
            _users = [[NSMutableArray alloc] initWithArray:participants];
            [[self tableView] reloadData];
        } failure:^(NSError *error) {
            [[[UIAlertView alloc]initWithTitle:@"경고"
                                       message:@"참여자들을 서버에서 가져오는데 실패했습니다"
                                      delegate:nil
                             cancelButtonTitle:@"확인"
                             otherButtonTitles:nil] show];
        }];
        
        [_paper getInvitations:^(NSArray *invitations) {
            _invitations = invitations;
            [[self tableView] reloadData];
        } failure:^(NSError *error) {
            [[[UIAlertView alloc]initWithTitle:@"경고"
                                       message:@"참여자들을 서버에서 가져오는데 실패했습니다"
                                      delegate:nil
                             cancelButtonTitle:@"확인"
                             otherButtonTitles:nil] show];
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:NO];
}

#pragma mark - UITableViewDelegate methods
#pragma mark - UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return [[self users] count];
    else if (section == 1) return[[self invitations] count];
    else return 0;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"참여중인 친구들";
    } else if (section == 1){
        return @"초대된 친구들";
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 0){
        static NSString *CellIdentifier = @"UserCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:CellIdentifier];
        }
        User* user = _users[indexPath.row];
        cell.textLabel.text = [user username];
        [cell.imageView setImageWithURL:user.picture withFadeIn:0.1f];
        return cell;
    } else if ([indexPath section] == 1){
        static NSString *CellIdentifier = @"InvitationCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:CellIdentifier];
        }
        Invitation *invitation = [self invitations][indexPath.row];
        cell.textLabel.text = [invitation receiverName];
        [cell.imageView setImageWithURL:invitation.receiverPicture withFadeIn:0.1f];
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
