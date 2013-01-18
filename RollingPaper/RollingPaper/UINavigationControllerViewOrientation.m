//
//  UINavigationControllerViewOrientation.c
//  RollingPaper
//
//  Created by 이상현 on 12. 12. 29..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <UIKit/UINavigationController.h>

@implementation UINavigationController (Rotation_IOS6)
-(BOOL)shouldAutorotate
{
    return [[self topViewController] shouldAutorotate];
}

-(NSUInteger)supportedInterfaceOrientations
{
//    NSLog(@"%@",self.topViewController);
    if(![self isKindOfClass:UIImagePickerController.class])
        return [[self topViewController] supportedInterfaceOrientations];
    else
        return [super supportedInterfaceOrientations];
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
//    NSLog(@"%@",self.topViewController);
    if(![self isKindOfClass:UIImagePickerController.class])
        return [[self topViewController] preferredInterfaceOrientationForPresentation];
    else
        return [super preferredInterfaceOrientationForPresentation];
}
@end