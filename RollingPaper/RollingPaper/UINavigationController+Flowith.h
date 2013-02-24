//
//  UINavigationController+Flowith.h
//  RollingPaper
//
//  Created by 이상현 on 13. 2. 24..
//  Copyright (c) 2013년 ‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚Äö√†√∂¬¨√Ü‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚Äö√†√∂¬¨¬¢‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚Äö√†√∂‚àö¬±‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚Äö√†√∂‚Äö√Ñ¬¢‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚Äö√Ñ√∂‚àö¬¢¬¨√ü‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚Äö√†√∂¬¨¬• ‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚Äö√†√∂¬¨√Ü‚Äö√Ñ√∂‚àö‚Ä†‚àö‚àÇ‚âà√¨‚àö√ë¬¨¬®¬¨¬Æ‚Äö√Ñ√∂‚àö√ë¬¨¬¢. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (Flowith)

-(NSInteger) removeViewControllersExceptTop;
-(BOOL) removeViewControllerFromStack : (UIViewController*) controller;
-(NSInteger) removeViewControllersFromStackWithFilter
    :   (BOOL(^)(UIViewController* viewController,NSUInteger idx, BOOL *stop)) filter;
-(NSInteger) removeViewControllersFromStackIdentifyWithClass : (__unsafe_unretained  Class) controllerClass;

-(NSInteger) removeViewControllersFromStackAboveViewController : (UIViewController*) controller;
-(NSInteger) removeViewControllersFromStackBellowViewController : (UIViewController*) controller;
-(BOOL) addViewControllersToStackAboveViewController : (UIViewController*) controller;
-(BOOL) addViewControllersToStackBellowViewController : (UIViewController*) controller;

@end
