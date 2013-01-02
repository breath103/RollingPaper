//
//  UIFreeTransformGestureRecognizer.h
//  RollingPaper
//
//  Created by 이상현 on 12. 12. 15..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import <UIKit/UIGestureRecognizerSubclass.h>

@interface UIFreeTransformGestureRecognizer : UIGestureRecognizer<UIGestureRecognizerDelegate>
{
    @private
        BOOL isTouchChanged;
}
@property (atomic) CGPoint translation;
@property (atomic) CGFloat scale;
@property (atomic) CGFloat rotation;

@end
