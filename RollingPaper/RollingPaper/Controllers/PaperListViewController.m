#import "PaperListViewController.h"
#import "PaperTableViewCell.h"

static NSString * const PaperListCellIdentifier = @"PaperListCellIdentifier";

@implementation PaperListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self tableView] setBackgroundColor:[UIColor clearColor]];
    [[self tableView] registerNib:[UINib nibWithNibName:@"PaperTableViewCell" bundle:nil]
           forCellReuseIdentifier:PaperListCellIdentifier];
    [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_papers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PaperTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PaperListCellIdentifier
                                                               forIndexPath:indexPath];
    RollingPaper *paper = _papers[indexPath.row];
    [cell setPaper:paper];
    [cell setDelegate:self];
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 96.0f;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}
- (void)paperTableViewCell:(PaperTableViewCell *)cell settingTouched:(UIButton *)button
{
    [[self delegate] paperListViewController:self
                              settingTouched:[cell paper]];
}
- (void)paperTableViewCell:(PaperTableViewCell *)cell touchBackground:(UIView *)view
{
    [[self delegate] paperListViewController:self
                            backgroundToched:[cell paper]];
}

@end
