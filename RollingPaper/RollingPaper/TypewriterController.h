//
//  TypewriterViewController.h
//  RollingPaper
//
//  Created by 이상현 on 12. 12. 16..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import <UIKit/UIKit.h>


@class TypewriterController;

@protocol TypewriterControllerDelegate <NSObject>
-(void) typewriterController : (TypewriterController*) typewriterController
                endEditImage : (UIImage*) image;
@end

@interface TypewriterController : UIViewController<UITextViewDelegate>
{
    @private
    BOOL isInEditing;
}
@property (nonatomic,weak) id<TypewriterControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextView *textView;
- (IBAction)onTouchEndType:(id)sender;
-(id) initWithDelegate : (id<TypewriterControllerDelegate>) delegate;
@end
