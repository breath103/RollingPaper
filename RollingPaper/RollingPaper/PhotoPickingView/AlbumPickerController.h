//
//  AlbumViewController.h
//  Madeleine
//
//  Created by 상현 이 on 12. 4. 1..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

#define ALBUM_TABLE_GRID_SIZE 3

@interface AlbumView : UIView
@property (nonatomic,strong) ALAssetsGroup* albumAssetsGroup;
@property (nonatomic,strong) UIImageView* thumbnailView;
@property (nonatomic,strong) UIButton* bgButton;
-(id) initWithFrame:(CGRect)frame albumAssetsGroup : (ALAssetsGroup*) aAlbumAssetsGroup;
@end



@class AlbumPickerController;

@protocol AlbumPickerControllerDelegate <NSObject>
-(void) albumPickerController : (AlbumPickerController*) albumPickerController 
                onSelectAlbum : (AlbumView*) albumView;

@end

@interface AlbumPickerController : UIViewController
{

}
@property (nonatomic,readonly) int numberOfAlbums;
@property (weak, nonatomic) IBOutlet UIScrollView *albumScrollView;
@property (nonatomic,weak) id<AlbumPickerControllerDelegate> delegate;
-(id) initWithDelegate : (id) delegate;
@end
