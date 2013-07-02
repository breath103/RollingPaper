#import "PaperParticipantsListController.h"
#import "FlowithAgent.h"
#import "User.h"
#import <UIImageView+AFNetworking.h>

@interface PaperParticipantsListController ()

@end

@implementation PaperParticipantsListController

-(id) initWithPaper:(RollingPaper*) paper{
    self = [self initWithDefaultNib];
    if(self){
        self.paper = paper;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if(self.paper){
        [[FlowithAgent sharedAgent] getPaperParticipants:self.paper
        success:^(BOOL isCachedResponse, NSArray *participants) {
            self.users = [[NSMutableArray alloc] initWithArray:participants];
            [self.tableView reloadData];
        } failure:^(NSError *error) {
            [[[UIAlertView alloc]initWithTitle:@"경고"
                                       message:@"참여자들을 서버에서 가져오는데 실패했습니다"
                                      delegate:nil
                             cancelButtonTitle:@"확인"
                             otherButtonTitles:nil] show];
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableViewDelegate methods
#pragma mark - UITableViewDataSource methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"UserCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    User* user = [self.users objectAtIndex: [indexPath indexAtPosition:1]];
    cell.textLabel.text = [user username];
    [cell.imageView setImageWithURL:[NSURL URLWithString:user.picture]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}


@end
