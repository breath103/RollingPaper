//
//  AlbumController.h
//  RollingPaper
//
//  Created by 이상현 on 12. 12. 16..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AlbumControllerDelegate;

@interface AlbumController : UIViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (nonatomic,strong) UIImagePickerController* imagePickerController;
@property (nonatomic,weak) id<AlbumControllerDelegate> delegate;
-(id) initWithDelegate : (id<AlbumControllerDelegate>) delegate;
@end

@protocol AlbumControllerDelegate <NSObject>
-(void) albumController : (AlbumController*) albumController
              pickImage : (UIImage*) image
               withInfo : (NSDictionary*) infodict;
@end