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
    
    self.colorPalette.delegate = self;
    NSMutableArray* colors = [NSMutableArray arrayWithObjects: UIColorXRGB(0,0,0),
                              UIColorXRGB(255,30,0),
                              UIColorXRGB(246,207,40),
                              UIColorXRGB(94,116,62),
                              UIColorXRGB(58,81,96),
                              UIColorXRGB(98,77,149),
                              UIColorXRGB(255,0,102), nil];
    [self.colorPalette createColorButtonsWithColors:colors];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidUnload {
    [self setTextView:nil];
    [self setColorPalette:nil];
    [super viewDidUnload];
}
-(void) animateOnKeyboardShow : (BOOL) show{
    if(show){
        [UIView animateWithDuration:0.5f animations:^{
            UIViewSetHeight(self.containerView, self.view.frame.size.height - KEYBOARD_HEIGHT);
        } completion:^(BOOL finished) {
            
        }];
    }
    else{
        [UIView animateWithDuration:0.5f animations:^{
            UIViewSetHeight(self.containerView, self.view.frame.size.height);
        } completion:^(BOOL finished) {
            
        }];
    }   
}
-(void) textViewDidBeginEditing:(UITextView *)aTextView{
    isInEditing = TRUE;
    [self animateOnKeyboardShow:TRUE];
}
-(void) textViewDidEndEditing:(UITextView *)aTextView{
    isInEditing = FALSE;
    [self animateOnKeyboardShow:FALSE];
   
}
-(void) colorPalette:(ColorPalette *)palette
         selectColor:(UIColor *)color{
    
}

@end
