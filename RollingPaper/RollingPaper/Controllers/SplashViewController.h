#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface SplashViewController : UIViewController<FBFriendPickerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *loadingImageView;
@property (weak, nonatomic) IBOutlet UIImageView *paperPlaneView;
@property (weak, nonatomic) IBOutlet UIImageView *paperImageView;
@end
