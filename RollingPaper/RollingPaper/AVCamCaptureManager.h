#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class AVCamRecorder;
@protocol AVCamCaptureManagerDelegate;

@interface AVCamCaptureManager : NSObject {
}
@property (nonatomic,strong) AVCaptureSession *session;
@property (nonatomic,assign) AVCaptureVideoOrientation orientation;
@property (nonatomic,strong) AVCaptureDeviceInput *videoInput;
@property (nonatomic,strong) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic,assign) id deviceConnectedObserver;
@property (nonatomic,assign) id deviceDisconnectedObserver;
@property (nonatomic,assign) UIBackgroundTaskIdentifier backgroundRecordingID;
@property (nonatomic,assign) id <AVCamCaptureManagerDelegate> delegate;
- (BOOL) setupSession;
- (void) captureStillImage;
- (BOOL) toggleCamera;
- (NSUInteger) cameraCount;
- (NSUInteger) micCount;
- (void) autoFocusAtPoint:(CGPoint)point;
- (void) continuousFocusAtPoint:(CGPoint)point;

@end
// These delegate methods can be called on any arbitrary thread. If the delegate does something with the UI when called, make sure to send it to the main thread.
@protocol AVCamCaptureManagerDelegate <NSObject>
@optional
- (void) captureManager:(AVCamCaptureManager *)captureManager
       didFailWithError:(NSError *)error;
- (void) captureManagerRecordingBegan:(AVCamCaptureManager *)captureManager;
- (void) captureManagerRecordingFinished:(AVCamCaptureManager *)captureManager;
- (void) captureManager : (AVCamCaptureManager *)captureManager
     StillImageCaptured : (UIImage*) image;
- (void) captureManagerDeviceConfigurationChanged:(AVCamCaptureManager *)captureManager;
@end
