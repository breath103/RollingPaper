//
//  PhotoPickerController.h
//  Madeleine
//
//  Created by 상현 이 on 12. 3. 29..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>


#define PHOTO_TABLE_GRID_SIZE 6

@interface PhotoView : UIView
{
    ALAsset* photoAssets;
}
-(id) initWithFrame : (CGRect)frame photoAsset : (ALAsset*) aPhotoAsset;

@property (nonatomic,readonly,strong) ALAsset* photoAssets;
@property (nonatomic,strong) UIButton* buttonView;
@property (nonatomic,strong) UIImageView* imageView;
@property (nonatomic,assign) BOOL isSelected;

@end


@class PhotoPickerController;
@protocol PhotoPickerControllerDelegate <NSObject>
-(void) photoPickerController : (PhotoPickerController*) photoPickerController 
                 onSelectPhoto: (PhotoView*) photoView; 
@end


@interface PhotoPickerController : UIViewController
{
    ALAssetsGroup* albumAssetsGroup;
}
-(id)initWithAlbumAssetGroup : (ALAssetsGroup*) albumAssetsGroup
                    delegate : (id) delegate ;

@property (nonatomic,strong,readonly) ALAssetsGroup* albumAssetsGroup;
@property (weak, nonatomic) IBOutlet UIScrollView *photoScrollView;
@property ( nonatomic,weak) id<PhotoPickerControllerDelegate> delegate;
-(IBAction)onSelectPhoto:(id)sender;

@end

