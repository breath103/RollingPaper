#import <UIKit/UIKit.h>

@protocol AlbumControllerDelegate;
@class AlbumController;

@interface AlbumController : UIViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (nonatomic,strong) UIImagePickerController* imagePickerController;
@property (nonatomic,weak) id<AlbumControllerDelegate> delegate;
-(id) initWithDelegate : (id<AlbumControllerDelegate>) delegate;
@end

@protocol AlbumControllerDelegate <NSObject>
-(void) albumController : (AlbumController*) albumController
              pickImage : (UIImage*) image
               withInfo : (NSDictionary*) infodict;
-(void) albumControllerCancelPickingImage:(AlbumController *)albumController;
@end