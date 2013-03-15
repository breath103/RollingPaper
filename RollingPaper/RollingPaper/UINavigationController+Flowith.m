//
//  UINavigationController+Flowith.m
//  RollingPaper
//
//  Created by 이상현 on 13. 2. 24..
//  Copyright (c) 2013년 ‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚Äö√†√∂¬¨√Ü‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚Äö√†√∂¬¨¬¢‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚Äö√†√∂‚àö¬±‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚Äö√†√∂‚Äö√Ñ¬¢‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚Äö√Ñ√∂‚àö¬¢¬¨√ü‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚Äö√†√∂¬¨¬• ‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚Äö√†√∂¬¨√Ü‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚âà√¨‚àö√ë¬¨¬®¬¨¬Æ‚Äö√Ñ√∂‚àö√ë¬¨¬¢. All rights reserved.
//

#import "UINavigationController+Flowith.h"

@implementation UINavigationController (Flowith)
-(BOOL)shouldAutorotate
{
    return [[self topViewController] shouldAutorotate];
}

-(NSUInteger)supportedInterfaceOrientations
{
    if(![self isKindOfClass:UIImagePickerController.class])
        return [[self topViewController] supportedInterfaceOrientations];
    else
        return [super supportedInterfaceOrientations];
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    if(![self isKindOfClass:UIImagePickerController.class])
        return [[self topViewController] preferredInterfaceOrientationForPresentation];
    else
        return [super preferredInterfaceOrientationForPresentation];
}


-(BOOL) removeViewControllerFromStack : (UIViewController*) controller{
    return [self removeViewControllersFromStackWithFilter:
            ^BOOL(UIViewController *viewController,NSUInteger idx, BOOL *stop) {
                return viewController == controller;
            }] > 0;
}


-(NSInteger) removeViewControllersExceptTop{
    return [self removeViewControllersFromStackBellowViewController:self.topViewController];
}

-(NSInteger) removeViewControllersFromStackWithFilter:
            (BOOL(^)(UIViewController* viewController,NSUInteger idx, BOOL *stop)) filter{
    NSMutableArray* stack = [NSMutableArray arrayWithArray:self.viewControllers];
    NSIndexSet* indexSet =
    [stack indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return filter(obj,idx,stop);
    }];
    [stack removeObjectsAtIndexes:indexSet];
    [self setViewControllers:stack];
    return indexSet.count;
}
-(NSInteger) removeViewControllersFromStackIdentifyWithClass : (__unsafe_unretained  Class) controllerClass{
    return [self removeViewControllersFromStackWithFilter:
            ^BOOL(UIViewController *viewController,NSUInteger idx, BOOL *stop) {
                return [viewController isMemberOfClass:controllerClass];
            }];
}
-(NSInteger) removeViewControllersFromStackAboveViewController : (UIViewController*) controller{
    NSInteger index = [self.viewControllers indexOfObject:controller];
    if(index != NSNotFound){
        return [self removeViewControllersFromStackWithFilter:
                ^BOOL(UIViewController *viewController,NSUInteger idx, BOOL *stop) {
                    return index < idx; //더 위에 있는 것들을 삭제
                }];
    }
    else {
        return 0;
    }
}
-(NSInteger) removeViewControllersFromStackBellowViewController : (UIViewController*) controller{
    NSInteger index = [self.viewControllers indexOfObject:controller];
    if(index != NSNotFound){
        return [self removeViewControllersFromStackWithFilter:
                ^BOOL(UIViewController *viewController,NSUInteger idx, BOOL *stop) {
                    return index > idx; //더 위에 있는 것들을 삭제
                }];
    }
    else {
        return 0;
    }
}
-(BOOL) addViewControllers : (NSArray*) newViewControllers
ToStackAboveViewController : (UIViewController*) controller{
    
}
-(BOOL) addViewControllers : (NSArray*) newViewControllers
ToStackBellowViewController : (UIViewController*) controller{
    
}
-(BOOL) addViewController : (UIViewController*) newViewController
ToStackAboveViewController : (UIViewController*) controller{
    return [self addViewControllers:@[newViewController] ToStackAboveViewController:controller];
}
-(BOOL) addViewController : (UIViewController*) newViewController
ToStackBellowViewController : (UIViewController*) controller{
    return [self addViewControllers:@[newViewController] ToStackBellowViewController:controller];
}


@end
