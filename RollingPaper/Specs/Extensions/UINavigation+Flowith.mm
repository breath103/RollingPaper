#import "UINavigationController+Flowith.h"

using namespace Cedar::Matchers;

SPEC_BEGIN(UINavigationController_Flowith)
describe(@"UINavigationController+Flowith", ^{
    __block UINavigationController* navigationController;
    /*
    -(NSInteger) removeViewControllersFromStackWithFilter : (BOOL(^)(UIViewController* viewController)) filter;
    -(NSInteger) removeViewControllersFromStackWithClass : (Class*) controllerClass;
    -(NSInteger) removeViewControllersFromStackAboveViewController : (UIViewController*) controller;
    -(NSInteger) removeViewControllersFromStackBellowViewController : (UIViewController*) controller;
    -(BOOL) addViewControllersToStackAboveViewController : (UIViewController*) controller;
    -(BOOL) addViewControllersToStackBellowViewController : (UIViewController*) controller;
     */
    
    beforeEach(^{
        navigationController = [[UINavigationController alloc] initWithRootViewController:[[UIViewController alloc]init]
                                ];
    });
   
    
    describe(@"removeViewControllerFromStack", ^{
        it(@"should return false and do notting if view controller is not exist in stack",^{
            UIViewController* nonStackedController = [[UIViewController alloc] init];
            [navigationController setViewControllers:@[
                [[UIViewController alloc] init],
                [[UIViewController alloc] init]
            ]];
            expect([navigationController removeViewControllerFromStack:nonStackedController])
                    .to(equal(NO));
        });
        it(@"should return true and remove view controller if it's in stack",^{
            
            UIViewController* stackedViewController = [[UIViewController alloc] init];
            [navigationController setViewControllers:@[
                [[UIViewController alloc] init],
                stackedViewController,
                [[UIViewController alloc] init]
             ]];
            it(@"should return YES", ^{
                expect([navigationController removeViewControllerFromStack:stackedViewController])
                .to(equal(TRUE));
            });
            it(@"should viewController removed",^{
                expect([navigationController.viewControllers containsObject:stackedViewController])
                .to(equal(FALSE));
            });
            
        });
    });
    });

SPEC_END




