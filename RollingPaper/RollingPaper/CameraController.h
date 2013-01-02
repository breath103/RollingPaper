
#import <UIKit/UIKit.h>
#import "AVCamCaptureManager.h"
#import "AVCamRecorder.h"
#import <AVFoundation/AVFoundation.h>

@class CameraController;

@protocol CameraContorllerDelegate <NSObject>
-(void) cameraController : (CameraController*) camera
             onPickImage : (UIImage*) image;
-(void) cameraControllerCancelPicking : (CameraController*) camera;
@end

@interface CameraController : UIViewController {
}
@property (nonatomic,weak) id<CameraContorllerDelegate> delegate;
@property (nonatomic,strong) AVCamCaptureManager *captureManager;
@property (nonatomic,strong) IBOutlet UIView *videoPreviewView;
@property (nonatomic,strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic,weak) IBOutlet UIImageView *stillImagePreview;

#pragma mark Toolbar Actions
-(IBAction)captureStillImage:(id)sender;
-(IBAction)toggleCamera:(id)sender;
-(IBAction)onSelectImage:(id)sender;
-(id) initWithDelegate : (id<CameraContorllerDelegate>) delegate;
@end

