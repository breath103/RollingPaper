
#import "UserTableViewCell.h"
#import "UIImageView+Vingle.h"

@implementation UserTableViewCell
- (void)setUser:(User *)user
{
    _user = user;
    [_profileImageView setImageWithURL:[user picture]
                            withFadeIn:0.1f];
    [_usernameLabel setText:[user username]];
}
- (void)setInvitation:(Invitation *)invitation
{
    _invitation = invitation;
    [_profileImageView setImageWithURL:[invitation receiverPicture] withFadeIn:0.1f];
    [_usernameLabel setText:[invitation receiverName]];
}
@end
