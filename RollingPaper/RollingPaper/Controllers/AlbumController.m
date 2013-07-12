//
//  AlbumController.m
//  RollingPaper
//
//  Created by 이상현 on 12. 12. 16..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import "AlbumController.h"

@interface AlbumController ()

@end

@implementation AlbumController
@synthesize delegate;
@synthesize imagePickerController;
- (id)initWithDelegate:(id<AlbumControllerDelegate>)aDelegate{
    self = [self initWithNibName:NSStringFromClass(AlbumController.class) bundle:NULL];
    if(self){
        self.delegate = aDelegate;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!self.imagePickerController) {
        self.imagePickerController = [[UIImagePickerController alloc] init];
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        self.imagePickerController.allowsEditing = TRUE;
        self.imagePickerController.delegate = self;
    }
    self.definesPresentationContext = TRUE;
    [self presentViewController:self.imagePickerController
                                            animated:TRUE
                                          completion:^{
                                            
                                          }];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(BOOL) shouldAutorotate {return false;}
@end

@implementation AlbumController (UIImagePickerControllerDelegate)
-(void) imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSLog(@"%@",info);
    [self.parentViewController dismissViewControllerAnimated:TRUE completion:^{
        [self.delegate albumController:self
                             pickImage:[info objectForKey:UIImagePickerControllerEditedImage]
                              withInfo:info ];
    }];
}
-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self.parentViewController dismissViewControllerAnimated:TRUE completion:^{
        [self.delegate albumControllerCancelPickingImage:self];
    }];
}
@end