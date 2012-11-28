//
//  AlbumViewController.m
//  Madeleine
//
//  Created by 상현 이 on 12. 4. 1..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import "AlbumPickerController.h"
#import "PhotoPickerController.h"
#import "UEAssets.h"
#import "macro.h"

@implementation AlbumView
@synthesize thumbnailView;
@synthesize albumAssetsGroup;
@synthesize bgButton;

-(id) initWithFrame:(CGRect)frame albumAssetsGroup : (ALAssetsGroup*) aAlbumAssetsGroup
{
    self = [self initWithFrame:frame];
    if(self)
    {
        albumAssetsGroup = aAlbumAssetsGroup;
        
        thumbnailView = [[UIImageView alloc]initWithImage:[UIImage imageWithCGImage:aAlbumAssetsGroup.posterImage]];
        UIViewSetSize(thumbnailView, frame.size);
        [self addSubview:thumbnailView];
        
        self.bgButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.bgButton.backgroundColor = [UIColor clearColor];
        UIViewSetSize(self.bgButton, frame.size);
        [self addSubview:self.bgButton];
    }
    return self;
}

@end




@interface AlbumPickerController ()

@end

@implementation AlbumPickerController
@synthesize delegate;
@synthesize numberOfAlbums;
@synthesize albumScrollView;

-(id) initWithDelegate : (id) aDelegate{
    self = [self initWithNibName:@"AlbumPickerController" bundle:NULL];
    if(self){
        self.delegate = aDelegate;
    }
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(IBAction)onTouchAlbumView:(id)sender
{
    AlbumView* albumView = (AlbumView*)((UIButton*)sender).superview;
 
    [delegate albumPickerController:self onSelectAlbum:albumView];
}
- (void) addAlbumView : (ALAssetsGroup*) albumAssetsGroup
{
    CGImageRef postImageRef = albumAssetsGroup.posterImage;
    if(postImageRef) 
    {
        CGSize albumViewSize = CGSizeMake(320/ALBUM_TABLE_GRID_SIZE,320/ALBUM_TABLE_GRID_SIZE);
        CGRect rect = CGRectMake(numberOfAlbums%ALBUM_TABLE_GRID_SIZE * albumViewSize.width,
                                 numberOfAlbums/ALBUM_TABLE_GRID_SIZE * albumViewSize.height,
                                 albumViewSize.width,
                                 albumViewSize.height);
        
        AlbumView* albumView = [[AlbumView alloc]initWithFrame:rect albumAssetsGroup:albumAssetsGroup];
        [albumView.bgButton addTarget:self action:@selector(onTouchAlbumView:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:albumView];
    }
    
    
    numberOfAlbums++;
}


- (void)viewDidLoad
{

    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    ALAssetsLibrary* assetsLibrary = [UEAssets defaultAssetsLibrary];
    //ALAssetsLibrary* assetsLibrary = [[ALAssetsLibrary alloc] init];//[UEAssets defaultAssetsLibrary];
    [assetsLibrary enumerateGroupsWithTypes : ALAssetsGroupAll
                                 usingBlock : ^(ALAssetsGroup *group, BOOL *stop){
                                     NSLog(@"%@",group);
                                    if(group)
                                    {
                                        [self addAlbumView:group];
                                    }
                                    else {
                                        CGFloat scrollViewWidth = self.albumScrollView.frame.size.width;
                                        self.albumScrollView.contentSize = 
                                        CGSizeMake(scrollViewWidth,
                                                   (numberOfAlbums/ ALBUM_TABLE_GRID_SIZE + 1 ) * scrollViewWidth/ALBUM_TABLE_GRID_SIZE);
                                    }                              
                                }
                               failureBlock : ^(NSError *error) {
                                   NSLog(@"-%@",error);
                               }];  
}

- (void)viewDidUnload
{
    [self setAlbumScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
