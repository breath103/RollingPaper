//
//  AppDelegate.h
//  RollingPaper
//
//  Created by 이상현 on 12. 10. 27..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "UECoreData.h"
@class RootViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (weak,nonatomic) UECoreData* coreData;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController* navigationController;
@property (strong, nonatomic) RootViewController *rootViewController;

@end
