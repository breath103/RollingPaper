//
//  TypewriterViewController.m
//  RollingPaper
//
//  Created by 이상현 on 12. 12. 16..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import "TypewriterController.h"
#import "macro.h"
#import "UELib/UEImageLibrary.h"

#define KEYBOARD_HEIGHT (216.0f)

@interface TypewriterController ()

@end

@implementation TypewriterController
@synthesize delegate;
@synthesize textView;
- (IBAction)onTouchEndType:(id)sender {
    UIImage* image = [UEImageLibrary imageFromView:self.textView];
    [self.delegate typewriterController:self
                           endEditImage:image];
}

-(id)initWithDelegate:(id<TypewriterControllerDelegate>)aDelegate{
    self = [self initWithNibName:NSStringFromClass(self.class)
                          bundle:NULL];
    if(self){
        self.delegate = aDelegate;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.textView.delegate = self;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidUnload {
    [self setTextView:nil];
    [super viewDidUnload];
}

-(void) textViewDidBeginEditing:(UITextView *)aTextView{
    isInEditing = TRUE;
    [UIView animateWithDuration:0.5f animations:^{
        UIViewSetHeight(aTextView, self.view.frame.size.height - KEYBOARD_HEIGHT);
    } completion:^(BOOL finished) {
        
    }];
}
-(void) textViewDidEndEditing:(UITextView *)aTextView{
    isInEditing = FALSE;
    [UIView animateWithDuration:0.5f animations:^{
        UIViewSetHeight(aTextView, self.view.frame.size.height);
    } completion:^(BOOL finished) {
        
    }];
}
@end
