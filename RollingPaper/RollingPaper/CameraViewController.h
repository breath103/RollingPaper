//
//  CameraViewController.h
//  RollingPaper
//
//  Created by 이상현 on 12. 12. 15..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CameraViewController;
@protocol CameraViewControllerDelegate<NSObject>
-(void) CameraViewController : (CameraViewController*) recoder
        onpickImage : (UIImage*) image;
@end



@interface CameraViewController : UIViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (nonatomic,weak) id<CameraViewControllerDelegate> delegate;
@property (nonatomic,strong) UIImagePickerController* imagePickerController;
@property (nonatomic,weak) IBOutlet UIImageView *imageView;

-(id) initWithDelegate : (id<CameraViewControllerDelegate>) aDelegate;

- (IBAction)pickImageWithCamera:(id)sender;
- (IBAction)pickImageWithLibrary:(id)sender;
- (IBAction)onTouchSelect:(id)sender;

@end
