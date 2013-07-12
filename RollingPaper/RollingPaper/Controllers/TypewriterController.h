//
//  TypewriterViewController.h
//  RollingPaper
//
//  Created by 이상현 on 12. 12. 16..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ColorPalette.h"

@class TypewriterController;

@protocol TypewriterControllerDelegate <NSObject>
-(void) typewriterController : (TypewriterController*) typewriterController
                endEditImage : (UIImage*) image;
-(void) typewriterControllerDidCancelTyping:(TypewriterController *)typewriterController;
@end

@interface TypewriterController : UIViewController<UITextViewDelegate,ColorPaletteDelegate>
{
    @private
    BOOL isInEditing;
}
@property (weak,nonatomic) id<TypewriterControllerDelegate> delegate;
@property (weak,nonatomic) IBOutlet UIButton *doneButton;
@property (weak,nonatomic) IBOutlet UITextView *textView;
@property (weak,nonatomic) IBOutlet ColorPalette *colorPalette;
@property (weak,nonatomic) IBOutlet UIView *fontPalette;
@property (weak,nonatomic) IBOutlet UIButton *textAlignButton;
@property (weak,nonatomic) IBOutlet UIView *colorPaletteContainer;
@property (weak,nonatomic) IBOutlet UIView *textAlignContainer;
@property (weak, nonatomic) IBOutlet UIButton *colorButton;
- (IBAction)onTouchAlignButton:(id)sender;
- (IBAction)onTouchDone:(id)sender;
- (IBAction)onTouchCancel:(id)sender;
- (IBAction)onTouchFontButton:(id)sender;
- (IBAction)onTouchColor:(id)sender;
- (IBAction)onTouchTextAlignOptionButtons:(id)sender;
-(id) initWithDelegate : (id<TypewriterControllerDelegate>) delegate;
@end
