//
//  AppDelegate.m
//  RollingPaper
//
//  Created by 이상현 on 12. 10. 27..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import "AppDelegate.h"

#import "RootViewController.h"
#import <FacebookSDK/FacebookSDK.h>

@implementation AppDelegate

@synthesize navigationController;
@synthesize coreData;
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    NSLog(@"%@",url);
    return [FBSession.activeSession handleOpenURL:url];
}


- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    self.coreData = [UECoreData sharedInstance];
    
    CGRect bounds = [[UIScreen mainScreen] bounds];
    self.window = [[UIWindow alloc] initWithFrame:bounds];
    self.rootViewController = [[RootViewController alloc] initWithDefaultNib];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.rootViewController];
    //UIBarMetricsLandscapePhone
    
    UINavigationBar* navigationBar = self.navigationController.navigationBar;
    [navigationBar setBackgroundImage:[UIImage imageNamed:@"status_bar"]
                        forBarMetrics:UIBarMetricsDefault];
    /*
    UINavigationItem* navigationItem = self.navigationController.navigationItem;
    NSLog(@"%@",navigationItem);
    navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"backButton"] style:UIBarButtonItemStyleBordered target:NULL action:NULL];
    NSLog(@"%@",navigationItem);
     */
    self.navigationController.navigationBarHidden =TRUE;
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskLandscapeLeft|
           UIInterfaceOrientationMaskLandscapeRight|
           UIInterfaceOrientationMaskPortrait|
           UIInterfaceOrientationMaskPortraitUpsideDown;
}

@end
