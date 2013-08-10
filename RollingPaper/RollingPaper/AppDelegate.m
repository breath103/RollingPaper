#import "AppDelegate.h"

#import "SplashViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "MainPaperViewController.h"
#import "User.h"
#import "RollingPaper.h"
#import "Notification.h"

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

    
    [NSURLCache setSharedURLCache:[[NSURLCache alloc]initWithMemoryCapacity:1024*5
                                                               diskCapacity:1024*10
                                                                   diskPath:@"rollingpaper"]];
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
    [[[UIAlertView alloc]initWithTitle:nil
                               message:[userInfo description]
                              delegate:nil
                     cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    
    Notification *notification = [Notification fromAPNDictionary:userInfo];
    if ([[notification notificationType] isEqualToString:@"paper_needs_to_be_sended"]) {
        RollingPaper *paper = [[RollingPaper alloc]init];
        [paper setId:userInfo[@"source_id"]];
        [paper reload:^{
            [paper presentFacebookDialog];
        } failure:^(NSError *error) {
            [[[UIAlertView alloc]initWithTitle:nil
                                       message:[error description]
                                      delegate:nil
                             cancelButtonTitle:@"OK" otherButtonTitles:nil] show];

        }];
    } else {
        
    }
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
