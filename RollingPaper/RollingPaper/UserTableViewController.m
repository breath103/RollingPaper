#import "UserTableViewController.h"
#import "UserTableViewCell.h"

static NSString *const UserTableViewCellReuseIdentifier = @"UserTableViewCellReuseIdentifier";
@implementation UserTableViewController
- (id)init
{
    self = [super init];
    if (self) {
        _users = @[];
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self tableView] registerNib:[UINib nibWithNibName:@"UserTableViewCell" bundle:nil] forCellReuseIdentifier:UserTableViewCellReuseIdentifier];
}
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger) tableView:(UITableView *)tableView
  numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0: return [_users count];
    }
    return 0;
}
- (User *)userForIndexPath:(NSIndexPath *)indexPath
{
    return _users[indexPath.row];
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:UserTableViewCellReuseIdentifier
                                                              forIndexPath:indexPath];
    [cell setUser:[self userForIndexPath:indexPath]];
    return cell;
}
@end
