#import <UIKit/UIKit.h>
#import "User.h"
#import "Invitation.h"

@interface UserTableViewCell : UITableViewCell
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) Invitation *invitation;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@end
