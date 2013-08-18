#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "UECoreData.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (weak,nonatomic) UECoreData* coreData;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController* navigationController;
@property (strong, nonatomic) UIViewController *rootViewController;
@end
