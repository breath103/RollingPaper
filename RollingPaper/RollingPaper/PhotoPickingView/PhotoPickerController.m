//
//  PhotoPickerController.m
//  Madeleine
//
//  Created by 상현 이 on 12. 3. 29..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//


#import "PhotoPickerController.h"
#import "macro.h"
#import "UEAssets.h"


@implementation PhotoView

@synthesize photoAssets;
@synthesize imageView;
@synthesize buttonView;
@synthesize isSelected;
-(id) initWithFrame : (CGRect)frame photoAsset : (ALAsset*) aPhotoAsset
{
    self = [super initWithFrame:frame];
    if(self)
    {
        photoAssets = aPhotoAsset;
        
        self.imageView = [[UIImageView alloc]initWithImage:[UIImage imageWithCGImage:photoAssets.thumbnail]];
        UIViewSetSize(self.imageView, frame.size);
        [self addSubview:self.imageView];
        
        self.buttonView = [UIButton buttonWithType:UIButtonTypeCustom];
        UIViewSetSize(self.buttonView, frame.size);
        [self addSubview:self.buttonView];
        
    }
    return self;
} 
-(void) setIsSelected:(BOOL)aIsSelected
{
    isSelected = aIsSelected;
    if(isSelected){
        self.alpha = 0.3;
    }
    else {
        self.alpha = 1.0;
    }
}
@end 





@interface PhotoPickerController ()

@end

@implementation PhotoPickerController

@synthesize delegate;
@synthesize albumAssetsGroup;
@synthesize photoScrollView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(id)initWithAlbumAssetGroup : (ALAssetsGroup*) aAlbumAssetsGroup
                    delegate : (id) aDelegate ;

{
    self = [super initWithNibName:@"PhotoPickerController" bundle : NULL];
    if(self)
    {
        albumAssetsGroup = aAlbumAssetsGroup;
        self.delegate = aDelegate;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(albumAssetsGroup)
    {
        [albumAssetsGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop){
            if(result)
            {
                NSString* assetType = [result valueForProperty:ALAssetPropertyType];
                
                //일단은 사진만 추가
                if( [assetType compare:@"ALAssetTypePhoto"] == NSOrderedSame)
                {
                    int gridSize = PHOTO_TABLE_GRID_SIZE;
                    CGSize photoViewSize = CGSizeMake(320/gridSize,320/gridSize);
                    CGRect photoViewRect = CGRectMake(index%gridSize * photoViewSize.width,index/gridSize * photoViewSize.height,
                                                      photoViewSize.height,photoViewSize.width);
                    
                    PhotoView* photoView = [[PhotoView alloc]initWithFrame:photoViewRect
                                                                photoAsset:result];
                    [photoView.buttonView addTarget:self action:@selector(onSelectPhoto:) forControlEvents:UIControlEventTouchUpInside];
                    [self.photoScrollView addSubview:photoView];
                }
                else {
                    NSLog(@"%@",assetType);
                }
            }
            else {
                self.photoScrollView.contentSize = 
                CGSizeMake(self.photoScrollView.frame.size.width, 
                           (albumAssetsGroup.numberOfAssets / PHOTO_TABLE_GRID_SIZE + 1 ) * 320/PHOTO_TABLE_GRID_SIZE);
            }
        }];
    }
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setPhotoScrollView:nil];
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"view Did Disappear");
}

-(IBAction)onSelectPhoto:(id)sender
{
    PhotoView* photoView = (PhotoView*)((UIButton*)sender).superview;
    /*
    if( !photoView.isSelected)
        [selectedPhotoAssets addObject:photoView.photoAssets];
    else 
        [selectedPhotoAssets removeObject:photoView.photoAssets];
       
    photoView.isSelected = !photoView.isSelected;
 
    NSLog(@"%@",photoView.photoAssets);
     */
    [delegate photoPickerController:self onSelectPhoto:photoView];
}



@end
