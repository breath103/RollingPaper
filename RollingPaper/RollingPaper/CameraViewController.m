//
//  CameraViewController.m
//  RollingPaper
//
//  Created by 이상현 on 12. 12. 15..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import "CameraViewController.h"

@implementation CameraViewController
@synthesize delegate;
@synthesize imagePickerController;
-(id) initWithDelegate : (id<CameraViewControllerDelegate>) aDelegate{
    self = [self initWithNibName:@"CameraViewController" bundle:NULL];
    if(self){
        self.delegate = aDelegate;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(!self.imagePickerController)
    {
        self.imagePickerController = [[UIImagePickerController alloc]init];
        self.imagePickerController.delegate = self;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark UIImagePickerController가 PresentViewController에 의해 나타났을때
/* UINavigationControllDelegate */
-(void) navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated{
}
-(void) navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated{
}



/* UIImagePickerControllerDelegate */
-(void) imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info{
    self.imageView.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    [self dismissViewControllerAnimated : TRUE
                             completion : ^{}];
}

-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:TRUE
                             completion:^{}];
}
//////////////////////////////////////
- (IBAction)pickImageWithCamera:(id)sender {
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController : self.imagePickerController
                       animated : FALSE
                     completion : ^{}];
}

- (IBAction)pickImageWithLibrary:(id)sender {
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:self.imagePickerController
                       animated:TRUE
                     completion:^{}];
}

- (IBAction)onTouchSelect:(id)sender {
    [self.delegate CameraViewController : self
                            onpickImage : self.imageView.image];
}


- (void)viewDidUnload {
    [self setImageView:nil];
    [super viewDidUnload];
}
@end
