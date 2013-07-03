#import "AppDelegate.h"

#import "SplashViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "RollingPaperListController.h"
#import "User.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    self.coreData = [UECoreData sharedInstance];
    
    CGRect bounds = [[UIScreen mainScreen] bounds];
    self.window = [[UIWindow alloc] initWithFrame:bounds];
    self.rootViewController = [[SplashViewController alloc] init];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.rootViewController];

    UINavigationBar* navigationBar = self.navigationController.navigationBar;
    [navigationBar setBackgroundImage:[UIImage imageNamed:@"status_bar"]
                        forBarMetrics:UIBarMetricsDefault];
    
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];

#define TESTING 1
#ifdef TESTING
    [TestFlight setDeviceIdentifier:[[[UIDevice currentDevice] identifierForVendor] UUIDString]];
#endif
    [TestFlight takeOff:@"134d6c9817a6a69e9e1cf71568dfc69c_MTg3OTgzMjAxMy0wMi0xNiAwOTo1NDo1Mi4xNTg5MzA"];
   

    
    return YES;
}

#pragma APN
- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken: %@", deviceToken);
    [[User currentUser] setAPNKey:[deviceToken description] success:^{
        NSLog(@"registered");
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

- (void)application:(UIApplication *)application
didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"didFailToRegisterForRemoteNotificationsWithError: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"%@",userInfo);
}


- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [FBSession.activeSession handleOpenURL:url];
}

- (void)applicationWillResignActive:(UIApplication *)application { }
- (void)applicationDidEnterBackground:(UIApplication *)application {
   // [[UECoreData sharedInstance]saveContext];
}
- (void)applicationWillEnterForeground:(UIApplication *)application {}
- (void)applicationDidBecomeActive:(UIApplication *)application {}
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    NSLog(@"MEMORY WARNING : %@",application);
}
- (void)applicationWillTerminate:(UIApplication *)application
{
    [[UECoreData sharedInstance] saveContext];
}
- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskLandscapeLeft|
           UIInterfaceOrientationMaskLandscapeRight|
           UIInterfaceOrientationMaskPortrait|
           UIInterfaceOrientationMaskPortraitUpsideDown;
}

@end
