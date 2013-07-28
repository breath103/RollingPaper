#import <UIKit/UIKit.h>

@class User;
@class RollingPaper;
@interface PaperParticipantsListController:UIViewController<UITableViewDelegate,UITableViewDataSource>

-(id) initWithPaper:(RollingPaper*) paper;
@property (nonatomic, strong) RollingPaper* paper;
@property (nonatomic, strong) NSMutableArray* users;
@property (nonatomic, strong) NSArray *invitations;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
