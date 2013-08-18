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
        self.imagePickerController.allowsEditing = YES;
        self.imagePickerController.delegate = self;
    }
    self.definesPresentationContext = YES;
    [self presentViewController:self.imagePickerController
                                            animated:YES
                                          completion:^{
                                            
                                          }];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(BOOL) shouldAutorotate {return NO;}
@end

@implementation AlbumController (UIImagePickerControllerDelegate)
-(void) imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [self.parentViewController dismissViewControllerAnimated:YES completion:^{
        [self.delegate albumController:self
                             pickImage:[info objectForKey:UIImagePickerControllerEditedImage]
                              withInfo:info ];
    }];
}
-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self.parentViewController dismissViewControllerAnimated:YES completion:^{
        [self.delegate albumControllerCancelPickingImage:self];
    }];
}
@end
