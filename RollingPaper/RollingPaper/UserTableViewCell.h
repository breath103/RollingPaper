#import <UIKit/UIKit.h>
#import "User.h"

@interface UserTableViewCell : UITableViewCell
@property (nonatomic, strong) User *user;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@end
